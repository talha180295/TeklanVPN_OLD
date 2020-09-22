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
    
    
  
//    var usage:UsageResponse!
    var usagelimit:Double!// =      32210912720
    var usageRemaining: Double!// = 30210912720
    
    
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var flag:UIImageView!
    @IBOutlet weak var countryName:UILabel!
    @IBOutlet weak var cityName:UILabel!
    @IBOutlet weak var timmer:UILabel!
    @IBOutlet weak var connectionBtn:GradientButton!
    @IBOutlet weak var serverIP:UILabel!
    @IBOutlet weak var dataRecieved:UILabel!
    @IBOutlet weak var dataSent:UILabel!
    @IBOutlet weak var connectionStatus:UILabel!
    
    //Intent Variables
    var serverList = [Server]()
    var username:String!
    var password:String!
    
    
    
    //VPN Var
    let tunnelBundleId = "abc.org.TeraVPNDemo.PacketTunnel"
    var providerManager = NETunnelProviderManager()
    var selectedIP : String!
    var isVPNConnected : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(VPNViewController.VPNStatusDidChange(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        
        setupGaugeView()
        self.title = "TeraVPN"
        
        self.selectedIP = "\(serverList[0].serverIP ?? "0") \(serverList[0].serverPort ?? "0")"
        self.serverIP.text = "\(serverList[0].serverIP ?? "0") \(serverList[0].serverPort ?? "0")"
        self.countryName.text = "\(serverList[0].country ?? "")"
        self.cityName.text = "\(serverList[0].city ?? "")"
        self.flag.image = UIImage.init(named: serverList[0].flag ?? "")
        self.connectionStatus.text = "Disconnected"
        self.connectionStatus.textColor = .red
        self.connectionBtn.backgroundColor = UIColor(hexString: "3CB371")
        //        self.connectionBtn.setGradiantColors(colours: [UIColor(hexString: "#2B1468").cgColor, UIColor(hexString: "#70476F").cgColor])
        
    }

    
    func checkUsage(){
        
        let userData = HelperFunc().getUserDefaultData(dec: LoginResponse.self, title: User_Defaults.user)
        let params = ["user":"\(userData?.username ?? "")"]
        
        let request = APIRouter.usage(params)
        NetworkService.serverRequest(url: request, dec: UsageResponse.self, view: self.view) { (usageResponse, error) in
            
            if usageResponse?.success == "true"{
                
                self.usagelimit = Double(usageResponse?.usagelimit ?? "0")
                self.usageRemaining =  Double(usageResponse?.remaining ?? "0")
                self.connectVpn()
                
            }
            
        }
    }
    
    func connectVpn(){
        
        if isVPNConnected == true {
            
            let alert = UIAlertController(title: "Cancel Confirmation", message: "Disconnect the connected VPN cancel the connection attempt?", preferredStyle: UIAlertController.Style.alert)
            
            let disconnectAction = UIAlertAction(title: "DISCONNECT", style: UIAlertAction.Style.destructive) { _ in
                self.providerManager.connection.stopVPNTunnel()
                
            }
            
            let dismiss = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
            
            // relate actions to controllers
            alert.addAction(disconnectAction)
            
            alert.addAction(dismiss)
            
            present(alert, animated: true, completion: nil)
        }
        else{
            
            let otherAlert = UIAlertController(title: "Tera VPN", message: "Are you sure access VPN Connection", preferredStyle: UIAlertController.Style.alert)
            
            let connectAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) { _ in
                
                self.loadProviderManager {
                    self.configureVPN(serverAddress: self.selectedIP, username: self.username, password: "dcd76cbc5ad008a")
                }
                
            }
            
            let dismiss = UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: nil)
            
            // relate actions to controllers
            otherAlert.addAction(connectAction)
            
            otherAlert.addAction(dismiss)
            
            present(otherAlert, animated: true, completion: nil)
            
            
        }
        
    }
    
    @IBAction func connectBtn(_ sender:UIButton){
        
        self.checkUsage()
        
    }
    
    func getTrafficStats() {
        if let session = self.providerManager.connection as? NETunnelProviderSession {
            do {
                try session.sendProviderMessage("SOME_STATIC_KEY".data(using: .utf8)!) { (data) in
                    // here you can unarchieve your data and get traffic stats as dict
                }
            } catch {
                // some error
            }
        }
    }
    
    @IBAction func sideMenuBtn(_ sender:UIBarButtonItem){
        
        var vc = SideMenuViewController()
        if #available(iOSApplicationExtension 13.0, *) {
            vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "SideMenuViewController") as! SideMenuViewController
        } else {
            vc = storyboard?.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
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
    
    @IBAction func settingsBtn(_ sender:UIBarButtonItem){
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
        
        
        guard let configurationFileContent = self.getFileData(path: "vpn-01") else { return }
        
        self.providerManager.loadFromPreferences { error in
            if error == nil {
                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.username = username
                tunnelProtocol.serverAddress = serverAddress
                tunnelProtocol.providerBundleIdentifier = self.tunnelBundleId// bundle id of the network extension target
                //                tunnelProtocol.providerConfiguration = ["ovpn": configurationFileContent as NSData,"u":"test@user.com" as! String ,"p":"dcd76cbc5ad008a" as! String]
                
                tunnelProtocol.providerConfiguration = ["ovpn": configurationFileContent, "username": username, "password": password]
                
                tunnelProtocol.disconnectOnSleep = false
                self.providerManager.protocolConfiguration = tunnelProtocol
                self.providerManager.localizedDescription = "TeraVPN" // the title of the VPN profile which will appear on Settings
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
        }
    }
    func getFileData(path: String) -> Data?{
        
        var constr : String!
        
        guard let content = self.readFile(path: path) else { return nil }
        
        constr = content
        
        constr = constr.replacingOccurrences(of: "remote ip", with: "remote \(self.selectedIP ?? "")")
        constr = constr.replacingOccurrences(of: "\r\n", with: "\n")
        
        return (constr as String).data(using: String.Encoding.utf8)! as Data
        
        
    }
    func readFile(path: String) -> String? {
        
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
    
    @objc func VPNStatusDidChange(_ notification: Notification?) {
        print("VPN Status changed:")
        
        let status = self.providerManager.connection.status
        switch status {
        case .connecting:
            print("Connecting...")
            self.connectionStatus.text = "Connecting..."
            break
        case .connected:
            isVPNConnected = true
            print("Connected...")
            self.connectionStatus.text = "Connected"
            self.connectionStatus.textColor = .green
            self.connectionBtn.setTitle("Stop Connection", for: .normal)
            self.connectionBtn.backgroundColor = .red
            
            break
        case .disconnecting:
            print("Disconnecting...")
            self.connectionStatus.text = "Disconnecting..."
            break
        case .disconnected:
            isVPNConnected = false
            print("Disconnected...")
            self.connectionStatus.text = "Disconnected"
            self.connectionStatus.textColor = .red
            self.connectionBtn.setTitle("Start Connection", for: .normal)
            self.connectionBtn.backgroundColor = UIColor(hexString: "3CB371")
            break
        case .invalid:
            print("Invliad")
            break
        case .reasserting:
            print("Reasserting...")
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
        
    }
    
    
}


//Gauge View
extension VPNViewController{
    
    func setupGaugeView(){
        
        // Configure gauge view
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        gaugeView.divisionsRadius = 1.25 * ratio
        gaugeView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeView.ringThickness = 16 * ratio
        gaugeView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(16 * ratio))!
        gaugeView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(9 * ratio))!
        gaugeView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(9 * ratio))!
        gaugeView.unitOfMeasurement = "Remaining MB/S"
        
        // Update gauge view
        gaugeView.minValue = 0
        gaugeView.maxValue = usagelimit
//        gaugeView.limitValue = 50
        gaugeView.showMinMaxValue = false
        gaugeView.value = usageRemaining
        
        // Create a timer to update value for gauge view
        Timer.scheduledTimer(timeInterval: 2,
                             target: self,
                             selector: #selector(updateGaugeTimer),
                             userInfo: nil,
                             repeats: true)
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

        usageRemaining -= 111254720
        
        // Set value for gauge view
        gaugeView.value = usageRemaining
    }
}
