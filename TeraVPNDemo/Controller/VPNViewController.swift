//
//  VPNViewController.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 17/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import UIKit
import SideMenu
import CoreLocation
import NetworkExtension
import SDWebImage
import LMGaugeViewSwift

class VPNViewController: UIViewController {
    
    var userData: LoginResponse!
    
    var timer : Timer?
    var timer2 : Timer?
    //    var usage:UsageResponse!
    // = 30210912720
    
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    var usagelimitInMbs:Double = 0.0// =      32210912720
    var usageRemainingInMbs: Double = 0.0// = 30210912720
    var selectedServer:Server!
    
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var flag:UIImageView!
    @IBOutlet weak var countryName:UILabel!
    @IBOutlet weak var cityName:UILabel!
    @IBOutlet weak var timerClock:UILabel!
    @IBOutlet weak var connectionBtn:UIButton!
    @IBOutlet weak var serverIP:UILabel!
    @IBOutlet weak var dataRecieved:UILabel!
    @IBOutlet weak var dataSent:UILabel!
    @IBOutlet weak var connectionStatus:UILabel!
    
    //Intent Variables
    var serverList = [Server]()
    var username:String!
    var password:String!
    var usagelimit:Double!// =      32210912720
    var usageRemaining: Double!
    
    
    //VPN Data Variables
    var dataSentInMbs = 0.0
    var dataRecievedInMbs = 0.0
    
    //VPN Var
    let tunnelBundleId = "\(Bundle.main.bundleIdentifier!).PacketTunnel"

    var providerManager = NETunnelProviderManager()
    var selectedIP : String!
    var isVPNConnected : Bool = false
   
    
    func startTimerTrafficStats () {
        guard timer == nil else { return }
        
        timer =  Timer.scheduledTimer(
            timeInterval: TimeInterval(0.3),
            target      : self,
            selector    : #selector(getTrafficStats),
            userInfo    : nil,
            repeats     : true)
    }
    
    
    func stopTrafficTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimerLabel () {
        self.timerClock.isHidden = false
        guard timer2 == nil else { return }
        
        timer2 =  Timer.scheduledTimer(
            timeInterval: TimeInterval(1),
            target      : self,
            selector    : #selector(VPNViewController.update),
            userInfo    : nil,
            repeats     : true)
    }
    func stopTimerLabel() {
        self.timerClock.isHidden = true
        timer2?.invalidate()
        timer2 = nil
        self.hours = 0
        self.minutes = 0
        self.seconds = 0
        
        self.timerClock.text = "00:00:00"
    }
    
    @objc func update() {
        
        let conTime = self.providerManager.connection.connectedDate ?? Date()
        let nowT = Date()
        
        let dif = nowT.timeIntervalSince1970 - conTime.timeIntervalSince1970
        
        let hour = dif / 3600;
        let minute = dif.truncatingRemainder(dividingBy: 3600) / 60
        let second = dif.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60)
        
        
        var h = ""
        var m = ""
        var s = ""
        
        if hour < 10{
            h = "0"
        }
        if minute < 10{
            m = "0"
        }
        if second < 10{
            s = "0"
        }
        
        print("HH:MM:SS = \(h)\(Int(hour)):\(m)\(Int(minute)):\(s)\(Int(second))")
        self.timerClock.text = "\(h)\(Int(hour)):\(m)\(Int(minute)):\(s)\(Int(second))"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.disconnected()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        
        self.userData = HelperFunc().getUserDefaultData(dec: LoginResponse.self, title: User_Defaults.user)
        
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        gaugeView.divisionsRadius = 1.25 * ratio
        gaugeView.divisionsPadding = 8
        gaugeView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeView.ringThickness = 10 * ratio
        gaugeView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(16 * ratio))!
        gaugeView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(11 * ratio))!
        gaugeView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(9 * ratio))!
        gaugeView.unitOfMeasurement = "Remaining MB/S"
        gaugeView.showMinMaxValue = false
        self.setupGaugeValue(maxValue: 100, value: 100)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VPNViewController.VPNStatusDidChange(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        
        
        self.title = "Teklan VPN"
        
        self.selectedIP = "\(serverList[0].serverIP ?? "0") \(serverList[0].serverPort ?? "0")"
        self.serverIP.text = "\(serverList[0].serverIP ?? "0")"//" \(serverList[0].serverPort ?? "0")"
        self.countryName.text = "\(serverList[0].country ?? "")"
        self.cityName.text = "\(serverList[0].city ?? "")"
        self.flag.image = UIImage.init(named: serverList[0].flag ?? "")
//        self.connectionStatus.text = "Disconnected"
        self.connectionStatus.text = "Tap to Connect"
//        self.connectionStatus.textColor = .red
//        self.connectionBtn.backgroundColor = UIColor(hexString: "3CB371")
        self.connectionBtn.setImage(UIImage.init(named: "disconnected"), for: .normal)
        
        self.dataSent.text = "--"//"\(self.dataSentInMbs) MBs"
        self.dataRecieved.text = "--"//"\(self.dataRecievedInMbs) MBs"
        
        
        if let _ = self.usagelimit{
            self.usagelimitInMbs = self.usagelimit / 1000000.00 // Convert bytes into Mbs
            self.usageRemainingInMbs =  self.usageRemaining / 1000000.00 // Convert bytes into Mbs
           
            gaugeView.isHidden = false
            
        }
        else{
            gaugeView.isHidden = true

        }
        self.selectedServer = serverList.first
        
        self.loadProviderManager {
            if self.checkConnectionOnstartup(){
                if self.providerManager.connection.status == .disconnected || self.providerManager.connection.status == .invalid {
                    self.connectVpn()
                }
            }
            if self.providerManager.connection.status == .connected {
                if let connectedServer = self.getConnectedVpnData(){

                    self.connected()
                    self.selectedIP = "\(connectedServer.serverIP ?? "0")"//" \(server.serverPort ?? "0")"
                    self.serverIP.text = connectedServer.serverIP
                    self.countryName.text = "\(connectedServer.country ?? "") , \(connectedServer.city ?? "")"
                    self.flag.image = UIImage.init(named: connectedServer.flag ?? "")

                    self.selectedServer = connectedServer
                    self.connectionStatus.text = "Connected"
                    self.isVPNConnected = true

                }
            }
        }
        
        
        
        //        self.connectionBtn.setGradiantColors(colours: [UIColor(hexString: "#2B1468").cgColor, UIColor(hexString: "#70476F").cgColor])
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    
    @IBAction func connectionBtn(_ sender:UIButton){
        self.connectVpn()
//        if isVPNConnected == true {
//            self.connectVpn()
//        }
//        else{
//            self.checkUsage()
//        }
//
       
        
    }
    
    
    @IBAction func sideMenuBtn(_ sender:UIButton){
        
        openLocationScreen()
    }
    
    
    //For logout
    @IBAction func settingsBtn(_ sender:UIButton){
        
        self.openSettingsScreen()
       
    }
    
    @IBAction func locationBtn(_ sender:UIButton){
        
        openLocationScreen()
        
    }
    
    func openSettingsScreen(){
        var vc = SettingsViewController()
        if #available(iOSApplicationExtension 13.0, *) {
            vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "SettingsViewController") as! SettingsViewController

        } else {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openLocationScreen(){
        
        var vc = LocationVC()
        if #available(iOSApplicationExtension 13.0, *) {
            vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LocationVC") as! LocationVC
        } else {
            vc = storyboard?.instantiateViewController(withIdentifier: "LocationVC") as! LocationVC
        }
        vc.serverList = self.serverList
        vc.delegate = self
        // Define the menu
        let leftMenuNavigationController = SideMenuNavigationController(rootViewController: vc)
        SideMenuManager.default.leftMenuNavigationController = leftMenuNavigationController
        
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        leftMenuNavigationController.statusBarEndAlpha = 0
        leftMenuNavigationController.menuWidth = 280
        present(leftMenuNavigationController, animated: true, completion: nil)
    }
    
}


//VPN
extension VPNViewController{
    
    func checkUsage(){
        
        
        let params = ["user":"\(userData?.username ?? "")"]
        
        let request = APIRouter.usage(params)
        NetworkService.serverRequest(url: request, dec: UsageResponse.self, view: self.view) { (usageResponse, error) in
     
            if usageResponse != nil{
                print("**********usageResponse**********")
                print(usageResponse!)
                print("**********usageResponse**********")
            }
            else if error != nil{
                print("**********usageResponse**********")
                print(error!)
                print("**********usageResponse**********")
            }
            
            if usageResponse?.success == "true"{
                
                self.usagelimit = Double(usageResponse?.usagelimit ?? "0")
                self.usageRemaining =  Double(usageResponse?.remaining ?? "0")
                
                self.usagelimitInMbs = self.usagelimit / 1000000.00 // Convert bytes into Mbs
                self.usageRemainingInMbs =  self.usageRemaining / 1000000.00 // Convert bytes into Mbs
                
                self.setupGaugeValue(maxValue: self.usagelimitInMbs, value: self.usageRemainingInMbs)
                self.gaugeView.maxValue = self.usagelimitInMbs

                
                
                self.gaugeView.isHidden = false
                self.connectVpn()
                
            }
            
        }
    }
    
    func connectVpn(){
        
        if isVPNConnected == true {
            
            self.providerManager.connection.stopVPNTunnel()
//            let alert = UIAlertController(title: "Cancel Confirmation", message: "Disconnect the connected VPN cancel the connection attempt?", preferredStyle: UIAlertController.Style.alert)
//
//            let disconnectAction = UIAlertAction(title: "DISCONNECT", style: UIAlertAction.Style.destructive) { _ in
//                self.providerManager.connection.stopVPNTunnel()
//
//            }
//
//            let dismiss = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
//
//            // relate actions to controllers
//            alert.addAction(disconnectAction)
//
//            alert.addAction(dismiss)
//
//            present(alert, animated: true, completion: nil)
        }
        else{
            
            let password = self.userData?.password ?? ""
            let username = self.userData?.username ?? ""
            self.loadProviderManager {
//                self.configureVPN(serverAddress: "", username: username, password:password)
                
                self.connectionBtn.isEnabled = false
                self.configureVPN(serverAddress: "", username: username, password:password)
                self.connecting()
                
            }
            
//            let otherAlert = UIAlertController(title: "Teklan VPN", message: "Please click Yes to proceed with VPN connection", preferredStyle: UIAlertController.Style.alert)
//
//            let connectAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) { _ in
//
//                let password = self.userData?.password ?? ""
//                let username = self.userData?.username ?? ""
//                self.loadProviderManager {
////                    self.configureVPN(serverAddress: self.selectedIP, username: self.username, password: "dcd76cbc5ad008a")dfe334f1a50535f
//                    self.configureVPN(serverAddress: "", username: username, password:password)
//
//                }
//
//            }
//
//            let dismiss = UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: nil)
//
//            // relate actions to controllers
//            otherAlert.addAction(connectAction)
//
//            otherAlert.addAction(dismiss)
//
//            present(otherAlert, animated: true, completion: nil)
            
            
        }
        
    }
    
    func loadProviderManager(completion:@escaping () -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if error == nil {
                self.providerManager = managers?.first ?? NETunnelProviderManager()
                completion()
            }
        }
    }
    
    func configureVPN(serverAddress: String, username: String, password: String) {
        
        
        guard let configurationFileContent = self.getFileData(path: "nopie") else { return }
        
        self.providerManager.loadFromPreferences { error in
            if error == nil {
                let tunnelProtocol = NETunnelProviderProtocol()
//                tunnelProtocol.username = username
                tunnelProtocol.serverAddress = serverAddress
                tunnelProtocol.providerBundleIdentifier = self.tunnelBundleId// bundle id of the network extension target
                //                tunnelProtocol.providerConfiguration = ["ovpn": configurationFileContent as NSData,"u":"test@user.com" as! String ,"p":"dcd76cbc5ad008a" as! String]
                
                tunnelProtocol.providerConfiguration = ["ovpn": configurationFileContent, "username": username, "password": password]
                
                tunnelProtocol.disconnectOnSleep = false
                self.providerManager.protocolConfiguration = tunnelProtocol
                self.providerManager.localizedDescription = "TeklanVPN" // the title of the VPN profile which will appear on Settings
                self.providerManager.isEnabled = true
                self.providerManager.saveToPreferences(completionHandler: { (error) in
                    if error == nil  {
                        self.providerManager.loadFromPreferences(completionHandler: { (error) in
                            do {
                                try self.providerManager.connection.startVPNTunnel() // starts the VPN tunnel.
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        })
                    }
                })
            }
            else{
                print(error.debugDescription)
            }
        }
    }
    
    func getFileData(path: String) -> Data?{
        
        var constr : String!
        
        guard let content = self.readFile(path: path) else { return nil }
        
        constr = content
        
        constr = constr.replacingOccurrences(of: "remote ip", with: "remote \(self.selectedIP ?? "")")
        
        let proto = UserDefaults.standard.value(forKey: User_Defaults.proto) as? String ?? "udp"
        
        
        if proto == Proto_type.tcp.rawValue{
            constr = constr.replacingOccurrences(of: "proto", with: "proto \(proto)")
        }
        else if proto == Proto_type.udp.rawValue{
            constr = constr.replacingOccurrences(of: "proto", with: "proto \(proto)\n\("explicit-exit-notify")")
        }
        
        
        print("selectedIP=\(self.selectedIP ?? "")")
//        constr = constr.replacingOccurrences(of: "remote ip", with: "remote \(self.selectedIP ?? "") 443"
        constr = constr.replacingOccurrences(of: "\r\n", with: "\n")
        
        if let adBlocker = UserDefaults.standard.value(forKey: User_Defaults.adBlocker) as? Bool{
            
            if adBlocker{
                constr = constr.replacingOccurrences(of: "dhcp-option", with: "pull-filter ignore \"dhcp-option DNS\"\nredirect-gateway\ndhcp-option DNS \(self.userData.adblocker ?? "")")
            }
            else{
                constr = constr.replacingOccurrences(of: "dhcp-option", with: "")
            }
            
        }
        
        
        print("constr=\(constr as String)")
        return (constr as String).data(using: String.Encoding.utf8)! as Data
        
        
    }
    
    func readFile(path: String) -> String? {
        
//        let port = UInt16(1994)
//        print(isPortOpen(port:port))
        
        if let filepath = Bundle.main.path(forResource: path, ofType: "ovpn") {
            do {
                let contents = try String(contentsOfFile: filepath)
                
                return contents
                
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            
        }
        
        
        return nil
    }
    
    func isPortOpen(port: in_port_t) -> Bool {

        let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        if socketFileDescriptor == -1 {
            return false
        }

        var addr = sockaddr_in()
        let sizeOfSockkAddr = MemoryLayout<sockaddr_in>.size
        addr.sin_len = __uint8_t(sizeOfSockkAddr)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
        addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        var bind_addr = sockaddr()
        memcpy(&bind_addr, &addr, Int(sizeOfSockkAddr))

        if Darwin.bind(socketFileDescriptor, &bind_addr, socklen_t(sizeOfSockkAddr)) == -1 {
            return false
        }
        if listen(socketFileDescriptor, SOMAXCONN ) == -1 {
            return false
        }
        return true
    }
    
    @objc func VPNStatusDidChange(_ notification: Notification?) {
        print("VPN Status changed:")
        
        let status = self.providerManager.connection.status
        switch status {
        case .connecting:
            isVPNConnected = true
            print("Connecting...")
            self.connectionStatus.text = "Connecting..."
            self.connectionBtn.setImage(UIImage.init(named: "connecting"), for: .normal)
            self.stopTrafficTimer()
            self.stopTimerLabel()
            break
        case .connected:
            isVPNConnected = true
            print("Connected...")
            
          
            self.connectionBtn.isEnabled = true
            

            self.connected()
            self.saveConnectedVpnData(connectedServer: self.selectedServer)
            
            
            break
        case .disconnecting:
            print("Disconnecting...")
            self.connectionStatus.text = "Disconnecting..."
            self.stopTimerLabel()
            break
        case .disconnected:
            isVPNConnected = false
            print("Disconnected...")
            self.connectionStatus.text = "Disconnected"
//            self.connectionStatus.text = "Tap to Connect"
//            self.connectionStatus.textColor = .red
//            self.connectionBtn.setTitle("Start Connection", for: .normal)
//            self.connectionBtn.backgroundColor = UIColor(hexString: "3CB371")
            self.connectionBtn.setImage(UIImage.init(named: "disconnected"), for: .normal)
            
            self.disconnected()
            self.deleteConnectedVpnData()
            break
        case .invalid:
            print("Invliad")
            break
        case .reasserting:
            print("Reasserting...")
            self.connectionStatus.text = "Titles.VPN_STATE_RECONNECTING.rawValue.localiz().uppercased()"
            self.connectionBtn.isEnabled = false
            self.reconnecting()
            break
        @unknown default:
            print("Fatel Error...")
            break
        }
    }
}


extension VPNViewController:ServerListProtocol{
    
    func selectServer(server: Server) {
        if isVPNConnected{
            self.providerManager.connection.stopVPNTunnel()
        }
        
        self.selectedIP = "\(server.serverIP ?? "0") \(server.serverPort ?? "0")"
        self.serverIP.text = server.serverIP
        self.countryName.text = "\(server.country ?? "")"
        self.cityName.text = "\(server.city ?? "")"
        self.flag.image = UIImage.init(named: server.flag ?? "")
        
        self.selectedServer = server
    }
    
    
}


//Gauge View
extension VPNViewController{
    
    func setupGaugeValue(maxValue:Double,value:Double){
    
        gaugeView.minValue = 0
        gaugeView.maxValue = maxValue
        gaugeView.value = value
        
        // Create a timer to update value for gauge view
        //        Timer.scheduledTimer(timeInterval: 2,
        //                             target: self,
        //                             selector: #selector(updateGaugeTimer),
        //                             userInfo: nil,
        //                             repeats: true)
    }
    // MARK: GAUGE VIEW DELEGATE
    
    func ringStokeColor(gaugeView: GaugeView, value: Double) -> UIColor {
        
        //        if nightModeSwitch.isOn {
        //            return UIColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1)
        //        }
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
    }
    
    // MARK: EVENTS
    
    @objc func updateGaugeTimer() {
        
//        usageRemainingInMbs -= 1
        print(usageRemainingInMbs)
        // Set value for gauge view
        gaugeView.value = usageRemainingInMbs
    }
    
    @objc func getTrafficStats() {
        if let session = self.providerManager.connection as? NETunnelProviderSession {
            do {
                try session.sendProviderMessage("SOME_STATIC_KEY".data(using: .utf8)!) { (data) in
                    // here you can unarchieve your data and get traffic stats as dict
                    
                    if let _ = data{
                        //                        let decodedString = String(data: data!, encoding: .utf8)!
                        //
                        //                        print("jsonString=\(decodedString)")
                        
                        if let bytesData = String(data: data!, encoding: . utf8){
                            //                            print("bytesData=\(bytesData)")
                            
                            let dict = self.convertToDictionary(text: bytesData)
                            
                            let bytesIn = dict?["bytesIn"] as! String
                            let bytesOut = dict?["bytesOut"] as! String
                            
                            self.dataRecieved.text = self.getFormatedbytes(bytes: Double(bytesIn) ?? 0.0)
                            self.dataSent.text = self.getFormatedbytes(bytes: Double(bytesOut) ?? 0.0)
                            
//                            self.dataRecieved.text = "\(Int(bytesIn)!/1000) KB"
//                            self.dataSent.text = "\(Int(bytesOut)!/1000) KB"

                            //                            print("\(Int(bytesIn)!/1000000) MBs")
                            self.usageRemainingInMbs -= Double(bytesOut)!/1000000.00  + Double(bytesIn)!/1000000.00
//                            self.updateGaugeTimer()
                            
                        }
                    }
                    
                    
                    
                                        
                }
            } catch {
                // some error
            }
        }
    }
    
//    @objc func getTrafficStats() {
//        if let session = self.providerManager.connection as? NETunnelProviderSession {
//            do {
//                try session.sendProviderMessage("SOME_STATIC_KEY".data(using: .utf8)!) { (data) in
//                    // here you can unarchieve your data and get traffic stats as dict
//
//                    if let _ = data{
//                        //                        let decodedString = String(data: data!, encoding: .utf8)!
//                        //
//                        //                        print("jsonString=\(decodedString)")
//
//                        if let bytesData = String(data: data!, encoding: . utf8){
//                            //                            print("bytesData=\(bytesData)")
//
//                            let dict = self.convertToDictionary(text: bytesData)
//
//                            let bytesIn = dict?["bytesIn"] as! String
//                            let bytesOut = dict?["bytesOut"] as! String
//
//                            self.dataRecieved.text = "\(Int(bytesIn)!/1000) KB"
//                            self.dataSent.text = "\(Int(bytesOut)!/1000) KB"
//                            //                            print("\(Int(bytesIn)!/1000000) MBs")
//                            self.usageRemainingInMbs -= Double(bytesOut)!/1000000.00  + Double(bytesIn)!/1000000.00
//                            self.updateGaugeTimer()
//
//                        }
//                    }
//
//
//
//
//                }
//            } catch {
//                // some error
//            }
//        }
//    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}


extension VPNViewController{
    

    func reconnecting(){
//        circularView.progressLayer.strokeColor = UIColor.ButtonDisconnected.cgColor
//        signal1.setImageTintColor(UIColor.AntennaDisconnected)
//        signal2.setImageTintColor(UIColor.AntennaDisconnected)
//        signal3.setImageTintColor(UIColor.AntennaDisconnected)
//        connectionBtn.setImageTintColor(UIColor.ButtonDisconnected)
//        pauseTimerLabel()
        self.timerClock.isHidden = true
        self.connectionStatus.text = "Connecting..."
        self.connectionStatus.isHidden = false
        self.connectionBtn.setImage(UIImage.init(named: "connecting"), for: .normal)
    }
    
    func connecting(){
//        stopCircularTimer()
//        stopSignalTimer()
//
//        circularView.progressLayer.isHidden = false
//        circularView.progressLayer.strokeColor = UIColor.AntennaConnecting.cgColor
//        self.connectionBtn.setImageTintColor(UIColor.ButtonConnecting)
//        circularProgrress()
//        startCircularTimer()
//        startSignalTimer()
        self.connectionStatus.isHidden = false
        self.connectionStatus.text = "Connecting..."
        stopTimerLabel()
        
    }
    func connected(){
        self.connectionStatus.isHidden = true
        self.connectionStatus.text = "Connected"
        self.connectionBtn.setImage(UIImage.init(named: "connected"), for: .normal)
        self.startTimerTrafficStats()
        self.startTimerLabel()
//        startTimerLabel()
        self.serverIP.text = getIPAddress()
        
//        self.saveConnectedVpnData(connectedServer: self.selectedServer)
    }
    func disconnected(){

//        connectionBtn.setImageTintColor(UIColor.ButtonDisconnected)
        self.stopTrafficTimer()
        self.stopTimerLabel()
        self.connectionBtn.isEnabled = true
        self.serverIP.text = getIPAddress()
        
//        self.deleteConnectedVpnData()
    }
    
    
    func saveConnectedVpnData(connectedServer:Server){

        HelperFunc().saveUserDefaultData(data: connectedServer, title: User_Defaults.connectedServer)
    }
    
    func deleteConnectedVpnData(){

        HelperFunc().deleteUserDefaultData(title: User_Defaults.connectedServer)
    }
    
    func getConnectedVpnData() -> Server?{
        let connectedServer = HelperFunc().getUserDefaultData(dec: Server.self, title: User_Defaults.connectedServer)
        return connectedServer
    }
    
    
    func checkConnectionOnstartup() -> Bool{
        let startupSwitch = UserDefaults.standard.value(forKey: User_Defaults.startupSwitch) as? Bool
        
        return startupSwitch ?? false
    }
    
    func getIPAddress() -> String {
        var publicIP = ""
        do {
            try publicIP = String(contentsOf: URL(string: "https://www.bluewindsolution.com/tools/getpublicip.php")!, encoding: String.Encoding.utf8)
            publicIP = publicIP.trimmingCharacters(in: CharacterSet.whitespaces)
        }
        catch {
            print("Error: \(error)")
        }
        return publicIP
    }
}


extension VPNViewController{
    func getFormatedbytes(bytes:Double) -> String{

        if(bytes < 1024){
            return  "\(floor(bytes)) B";
        }
        else if ((bytes >= 1024) && (bytes < 1048_576)) {
            return  "\(floor( bytes / 1024)) KB"
        }
        else if (bytes < (pow(1024,3)) ) {
            return "\(floor(bytes / 1048_576)) MB"
        }
        else{
            return "\(floor(bytes / (pow(1024,3)))) GB"
        }
    }
}


extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
