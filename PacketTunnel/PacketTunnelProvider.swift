import NetworkExtension
import OpenVPNAdapter

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    lazy var vpnAdapter: OpenVPNAdapter = {
        let adapter = OpenVPNAdapter()
        adapter.delegate = self
        
        return adapter
    }()
    
    let vpnReachability = OpenVPNReachability()
    
    var startHandler: ((Error?) -> Void)?
    var stopHandler: (() -> Void)?
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        guard
            let protocolConfiguration = protocolConfiguration as? NETunnelProviderProtocol,
            let providerConfiguration = protocolConfiguration.providerConfiguration
            else {
                fatalError()
        }
        
        guard let ovpnFileContent: Data = providerConfiguration["ovpn"] as? Data else {
            fatalError()
        }
        
        let configuration = OpenVPNConfiguration()
        configuration.fileContent = ovpnFileContent
        configuration.disableClientCert = true
        configuration.forceCiphersuitesAESCBC = false
        //  configuration.proto = OpenVPNTransportProtocol.UDP
        // configuration.tlsCertProfile = OpenVPNTLSCertProfile.preferred
        // configuration.settings = [Any]
        
        // Apply OpenVPN configuration
        let properties: OpenVPNProperties
        do {
            properties = try vpnAdapter.apply(configuration: configuration)
        } catch {
            completionHandler(error)
            return
        }
        
        // Provide credentials if needed
        
        if !properties.autologin {
            if let username: String = providerConfiguration["username"] as? String, let password: String = providerConfiguration["password"] as? String {
                let credentials = OpenVPNCredentials()
                credentials.username = username
                credentials.password = password
                do {
                    try vpnAdapter.provide(credentials: credentials)
                } catch {
                    completionHandler(error)
                    return
                }
            }
        }
        
        vpnReachability.startTracking { [weak self] status in
            guard status != .notReachable else { return }
            self?.vpnAdapter.reconnect(afterTimeInterval: 5)
        }
        
        // Establish connection and wait for .connected event
        startHandler = completionHandler
        vpnAdapter.connect()
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        stopHandler = completionHandler
        
        if vpnReachability.isTracking {
            vpnReachability.stopTracking()
        }
        
        vpnAdapter.disconnect()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)? = nil) {
        if String(data: messageData, encoding: .utf8) == "SOME_STATIC_KEY" {
            let bytesIn = self.vpnAdapter.transportStatistics.bytesIn
            let bytesOut = self.vpnAdapter.transportStatistics.bytesOut
            let dict = ["bytesIn":"\(bytesIn)","bytesOut":"\(bytesOut)"]
            let data = NSKeyedArchiver.archivedData(withRootObject: dict) // here you are archieving data
            completionHandler?(data)
        }
    }


    
}

extension PacketTunnelProvider: OpenVPNAdapterDelegate {
    
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, configureTunnelWithNetworkSettings networkSettings: NEPacketTunnelNetworkSettings?, completionHandler: @escaping (OpenVPNAdapterPacketFlow?) -> Void) {
        
        networkSettings?.dnsSettings?.matchDomains = [""]
        
        // Specify the network settings for the current tunneling session.
        setTunnelNetworkSettings(networkSettings) { (error) in
            completionHandler(error == nil ? self.packetFlow : nil)
        }
        self.packetFlow.readPackets { [weak self] (packets: [Data], protocols: [NSNumber]) in
            print("packets=\(packets)")
        }
    }
    
    // Process events returned by the OpenVPN library
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleEvent event: OpenVPNAdapterEvent, message: String?) {
        switch event {
        case .connected:
            if reasserting {
                reasserting = false
            }
            
            guard let startHandler = startHandler else { return }
            
            startHandler(nil)
            self.startHandler = nil
            
        case .disconnected:
            guard let stopHandler = stopHandler else { return }
            
            if vpnReachability.isTracking {
                vpnReachability.stopTracking()
            }
            
            stopHandler()
            self.stopHandler = nil
            
        case .reconnecting:
            reasserting = true
            
        default:
            break
        }
    }
    
    // Handle errors thrown by the OpenVPN library
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleError error: Error) {
        // Handle only fatal errors
        guard let fatal = (error as NSError).userInfo[OpenVPNAdapterErrorFatalKey] as? Bool, fatal == true else {
            return
        }
        
        if vpnReachability.isTracking {
            vpnReachability.stopTracking()
        }
        
        if let startHandler = startHandler {
            startHandler(error)
            self.startHandler = nil
        } else {
            cancelTunnelWithError(error)
        }
    }
    
    // Use this method to process any log message returned by OpenVPN library.
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleLogMessage logMessage: String) {
        // Handle log messages
    }
    
}

extension NEPacketTunnelFlow: OpenVPNAdapterPacketFlow {}
