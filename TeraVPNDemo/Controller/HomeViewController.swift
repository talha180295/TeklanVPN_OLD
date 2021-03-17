//
//  HomeViewController.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 17/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import UIKit
import SideMenu
import CoreLocation
//import MBProgressHUD
import NetworkExtension
import SDWebImage



class HomeViewController: UIViewController {
    
    @IBOutlet weak var serverIP:UILabel!
    
    var serverList = [Server]()
    
    
    
    //VPN Var
    var countryip : String!
    var countryname : String!
    var countryping : String!
    var countrytype : String!
    var countryarray : Array<Any> = []
    var locationManager = CLLocationManager()
    var flag : Bool = false
    var dic : [String : String]!
    var providerManager : NETunnelProviderManager!
    let tunnelBundleId = "abc.org.TeraVPNDemo.PacketTunnel"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UserDefaults.standard.setValue("cyber.geek@techie.com", forKey: "user")
        UserDefaults.standard.setValue("password$_&", forKey: "pass")
        //        btncount.setImage(UIImage.init(named: "unconnect.png"), for: .normal)
        //        displayimg.image  = UIImage.init(named: "tap.png")
        //        statuslbl.text = "DISCONNECTED"
        //        iplbl.text = getIP()
        
        self.providerManager = NETunnelProviderManager()
        //        btnmenu.addTarget(self, action: #selector(self.btnmenu(_:)), for: .touchUpInside)
        //        btncount.addTarget(self, action: #selector(self.btncount(_:)), for: .touchUpInside)
        //        btnsel.addTarget(self, action: #selector(self.btnsel(_:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.VPNStatusDidChange(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setToPeru(notification:)), name: Notification.Name("check"), object: nil)
        
        if (UserDefaults.standard.value(forKey: "selectvalue") != nil) {
            print(UserDefaults.standard.value(forKey: "selectvalue") as Any)
            dic = UserDefaults.standard.value(forKey: "selectvalue") as? [String : String]
            
            //            vpncountrylbl.text = dic["server_location"]
            //            vpniplbl.text = "IP: " + "5.153.234.91 443" //dic["server_ip"]!
            countryname = dic["server_location"]
            countryip = "5.153.234.91 443"//dic["server_ip"]
            
            //            counicon.sd_setImage(with: URL(string: dic["image_url"]!), placeholderImage: UIImage(named: "placeholder.png"))
            //            counicon.layer.cornerRadius = counicon.frame.size.width / 2
            self.confapi()
        }
        else {
            self.mvalue()
        }
        self.countryck()
        
        //        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //        self.navigationController?.navigationBar.shadowImage = UIImage()
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
    
    @IBAction func connectVPNBtn(_ sender:UIButton){
        btncount(sender)
    }
    
    func btncount(_ sender:UIButton) {
        if flag == true {
            // countdownTimer.invalidate()
            //timer.invalidate()
            // self.providerManager?.connection.stopVPNTunnel()
            let otherAlert = UIAlertController(title: NSLocalizedString("Cancel Confirmation", comment: ""), message: NSLocalizedString("Disconnect the connected VPN cancel the connection attempt?", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            let printSomething = UIAlertAction(title: NSLocalizedString("DISCONNECT", comment: ""), style: UIAlertAction.Style.default) { _ in
                print("We can run a block of code." )
                //                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                //                appdelegate.dval()
                
                //self.countdownTimer.invalidate()
                // self.timer.invalidate()
                self.providerManager?.connection.stopVPNTunnel()
                if (UserDefaults.standard.value(forKey: "vpnconnect") != nil) {
                    UserDefaults.standard.removeObject(forKey: "vpnconnect")
                    UserDefaults.standard.removeObject(forKey: "auto")
                    self.confapi()
                }
                
                
                
            }
            
            
            
            let dismiss = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
            
            // relate actions to controllers
            otherAlert.addAction(printSomething)
            
            otherAlert.addAction(dismiss)
            
            present(otherAlert, animated: true, completion: nil)
        }
        else{
            
            let otherAlert = UIAlertController(title: NSLocalizedString("ROOVPN", comment: ""), message: NSLocalizedString("Are you sure access VPN Connection", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            let printSomething = UIAlertAction(title: NSLocalizedString("YES", comment: ""), style: UIAlertAction.Style.default) { _ in
                print("We can run a block of code." )
                
                
                self.providerManager?.loadFromPreferences(completionHandler: { (error) in
                    guard error == nil else {
                        // Handle an occurred error
                        return
                    }
                    
                    do {
                        //                        self.statuslbl.text = "CONNECTING..."
                        try self.providerManager?.connection.startVPNTunnel()
                        // self.VPNStatusDidChange(nil)
                    } catch {
                        // Handle an occurred error
                    }
                    
                    
                    // Do any additional setup after loading the view, typically from a nib.
                })
                
            }
            
            
            
            let dismiss = UIAlertAction(title: NSLocalizedString("NO", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
            
            // relate actions to controllers
            otherAlert.addAction(printSomething)
            
            otherAlert.addAction(dismiss)
            
            present(otherAlert, animated: true, completion: nil)
            
            
        }
    }
    
    func confapi() {
        //self.providerManager.removeFromPreferences(completionHandler: nil)
        //self.providerManager.connection.stopVPNTunnel()
        self.providerManager = NETunnelProviderManager()
        //        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
        //            guard error == nil else {
        //                // Handle an occurred error
        //                return
        //            }
        //
        //            self.providerManager = managers?.first ?? NETunnelProviderManager()
        //        }
        //
        //        //        The next step is to provide VPN settings to the instance of NETunnelProviderManager. Setup the NETunnelProviderProtocol object with appropriate values and save it in preferences.
        //
        //        self.providerManager?.loadFromPreferences(completionHandler: { (error) in
        //            guard error == nil else {
        //                // Handle an occurred error
        //                return
        //            }
        
        
        //            guard
        //                let configurationFileURL = Bundle.main.url(forResource: "new", withExtension: "ovpn"),
        // let configurationFileContent = self.confstring.data(using: String.Encoding.utf8)
        
        
        //                else {
        //                    fatalError()
        //            }
        self.providerManager = NETunnelProviderManager()
        let tunnelProtocol = NETunnelProviderProtocol()
        var constr : String!
        var configurationFileContent = NSData()
        
        if let filepath = Bundle.main.path(forResource: "vpn-01", ofType: "ovpn") {
            do {
                let contents = try String(contentsOfFile: filepath)
                
                constr = contents
                
                
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        //        let strs = "remote " + dic["server_ip"]! as String + " " + dic["server_port"]! as String
        //        print("strs:",strs)
        //        constr = constr!.replacingOccurrences(of: "remote lon-ovtcp-01.roovpn.net 443", with: strs, options: .literal, range: nil)
        constr = constr!.replacingOccurrences(of: "\r\n", with: "\n")
        
        // contentss.replacingOccurrences(of: strs, with: "remote lon-ovtcp-01.roovpn.net 443")
        // contentss.replacingOccurrences(of: "remote lon-ovtcp-01.roovpn.net 443", with: strs, options: .regularExpression)
        //replacingOccurrences(of: "remote lon-ovtcp-01.roovpn.net 443", with: str)
        print("contentss:",constr)
        configurationFileContent = (constr as String).data(using: String.Encoding.utf8)! as NSData
        
        //        guard
        //            let configurationFileURL = Bundle.main.url(forResource: "vpn-01", withExtension: "ovpn"),
        //
        //
        //
        //            let configurationFileContent = NSData(contentsOf:  configurationFileURL)
        //            else {
        //                fatalError()
        //        }
        // If the ovpn file doesn't contain server address you can use this property
        // to provide it. Or just set an empty string value because `serverAddress`
        // property must be set to a non-nil string in either case.
        tunnelProtocol.serverAddress = "5.153.234.91 443"//self.countryip
        
        // The most important field which MUST be the bundle ID of our custom network
        // extension target.
        tunnelProtocol.providerBundleIdentifier = "abc.org.TeraVPNDemo.PacketTunnel"
        
        // Use `providerConfiguration` to save content of the ovpn file.
        tunnelProtocol.providerConfiguration = ["ovpn": configurationFileContent as NSData,"u":
            "test@user.com" as! String ,"p":"dcd76cbc5ad008a" as! String]
        
        // Provide user credentials if needed. It is highly recommended to use
        // keychain to store a password.
        tunnelProtocol.username = "test@user.com" //UserDefaults.standard.value(forKey: "user") as? String
        tunnelProtocol.identityDataPassword = "dcd76cbc5ad008a" //UserDefaults.standard.value(forKey: "pass") as? String
        let passstr = "dcd76cbc5ad008a" // UserDefaults.standard.value(forKey: "pass") as? String
        
        tunnelProtocol.passwordReference = passstr.data(using: String.Encoding.utf8)
        //tunnelProtocol.passwordReference = ... // A persistent keychain reference to an item containing the password
        
        // Finish configuration by assigning tunnel protocol to `protocolConfiguration`
        // property of `providerManager` and by setting description.
        let now = Date()
        
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        let dateString = formatter.string(from: now)
        self.providerManager?.protocolConfiguration = tunnelProtocol
        self.providerManager?.localizedDescription = self.countryname
        //  self.providerManager?.localizedDescription = dateString
        tunnelProtocol.disconnectOnSleep = false
        self.providerManager?.isEnabled = true
        
        // Save configuration in the Network Extension preferences
        self.providerManager?.saveToPreferences(completionHandler: { (error) in
            if error != nil  {
                // Handle an occurred error
            }
            self.providerManager?.loadFromPreferences(completionHandler: { (error) in
                guard error == nil else {
                    // Handle an occurred error
                    return
                }
                if((UserDefaults.standard.value(forKey: "connected")) != nil){
                    
                    
                    
                    do {
                        try self.providerManager?.connection.startVPNTunnel()
                        
                        // self.VPNStatusDidChange(nil)
                    } catch {
                        // Handle an occurred error
                    }
                    
                }
                else{
                    
                    if((UserDefaults.standard.value(forKey: "auto")) != nil){
                        
                        
                        
                        do {
                            try self.providerManager?.connection.startVPNTunnel()
                            
                            // self.VPNStatusDidChange(nil)
                        } catch {
                            // Handle an occurred error
                        }
                        
                    }
                }
                // Do any additional setup after loading the view, typically from a nib.
            })
        })
        
    }
    
    func mvalue() {
        self.confapi()
        
        //        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        var Url : String!
        
        Url = String(format: "http://serv-api.roovpn.com/API/Servers/allservers")
        
        // let Url = String(format: Mainlist)
        guard let serviceUrl = URL(string: Url) else { return }
        //        let parameterDictionary = ["user" : self.user.text, "pass" : self.pass.text]
        let request = URLRequest(url: serviceUrl)
        //        request.httpMethod = "POST"
        //        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        //        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
        //            return
        //        }
        //        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let response = response {
                print(response)
                
            }
            if let data = data {
                
                var str = String(decoding: data, as: UTF8.self)
                //
                str = str.replacingOccurrences(of: "\n", with: "")
                //  print(str)
                do {    if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>] {
                    
                    
                    for myDic in jsonArray{
                        
                        let status = myDic["status"] as! String
                        let stype = myDic["server_type"] as! String
                        //do anything with data
                        if status == "1" && stype == "4" {
                            self.countryarray.append(myDic)
                        }
                        print("myDic:",self.countryarray)
                        print("myDic",myDic)
                        print("myDi1",status)
                        print("myDi2",stype)
                        
                    }
                    
                    print("mynewDi",self.countryarray)
                    DispatchQueue.main.async {
                        
                        //                        self.hud.hide(animated: true)
                        
                        if self.countryarray.count > 0 {
                            
                            self.dic = self.countryarray[0] as? [String : String]
                            
                            //                            self.vpncountrylbl.text = self.dic["server_location"]
                            //                            self.vpniplbl.text = "IP: " + "5.153.234.91 443" //self.dic["server_ip"]!
                            self.countryname = self.dic["server_location"]
                            self.countryip = "5.153.234.91 443"//self.dic["server_ip"]
                            
                            //                            self.counicon.sd_setImage(with: URL(string: self.dic["image_url"]!), placeholderImage: UIImage(named: "placeholder.png"))
                            //                            self.counicon.layer.cornerRadius = self.counicon.frame.size.width / 2
                            self.confapi()
                        }
                        
                    }
                    
                    }} catch let error as NSError {
                        print(error)
                }
                
                
                //                print(formattedArray[0])
                //                let fstr = formattedArray[0] as String
                //                let formattedArrays = fstr.components(separatedBy: ":") as Array
                //                print(formattedArrays)
                //                print(formattedArrays[0])
                
                //                do {
                //                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSString
                //
                //
                //
                //
                
                //                } catch {
                //                    print(error)
                //                }
            }
            
        }.resume()
        
    }
    
    
    
    
    @objc func VPNStatusDidChange(_ notification: Notification?) {
        print("VPN Status changed:")
        
        
        
        
        
        let status = self.providerManager.connection.status
        switch status {
        case .connecting:
            print("Connecting...")
            //            statuslbl.text = "CONNECTING..."
            //  connectlbl.text = NSLocalizedString("Connecting", comment: "")
            //  connectButton.setTitle("Disconnect", for: .normal)
            break
        case .connected:
            print("Connected...")
            //            self.countrylbl.text = self.dic["server_location"]
            UserDefaults.standard.setValue("connected", forKey: "connected")
            UserDefaults.standard.synchronize()
            //            iplbl.text =  dic["server_ip"]!
            //            btncount.setImage(UIImage.init(named: "connect.png"), for: .normal)
            //            displayimg.image  = UIImage.init(named: "tapdis.png")
            //            statuslbl.text = "CONNECTED"
            // connectlbl.text = NSLocalizedString("Connected", comment: "")
            //self.countryck()
            flag = true
            // let releaseDateFormatter = DateFormatter()
            //  releaseDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            // let releaseDateString = releaseDateFormatter.string(from: Date())
            //  releaseDate = releaseDateFormatter.date(from: releaseDateString)! as NSDate
            
            // countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            
            
            // timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainController.timerAction), userInfo: nil, repeats: true)
            // https://www.iplocation.net/
            //                let svc = SFSafariViewController(url: URL(string: "https://www.iplocation.net/")!)
            //                svc.delegate = self
            //                present(svc, animated: false, completion: nil)
            // connectButton.setTitle("Disconnect", for: .normal)
            break
        case .disconnecting:
            print("Disconnecting...")
            break
        case .disconnected:
            print("Disconnected...")
            flag = false
            //            iplbl.text = getIP()
            // connectlbl.text = NSLocalizedString("Tap To Connect", comment: "")
            //            btncount.setImage(UIImage.init(named: "unconnect.png"), for: .normal)
            //            displayimg.image  = UIImage.init(named: "tap.png")
            //            statuslbl.text = "DISCONNECTED"
            if ((UserDefaults.standard.value(forKey: "connected")) != nil) {
                UserDefaults.standard.removeObject(forKey: "connected")
                
            }
            self.countryck()
            
            //connectButton.setTitle("Connect", for: .normal)
            break
        case .invalid:
            print("Invliad")
            break
        case .reasserting:
            print("Reasserting...")
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                
                print("placemarks",placemarks!)
                let pm = placemarks?[0]
                print(pm?.locality as! String)
                //                self.countrylbl.text = pm?.country as! String
            } else {
                print("Problem with the data received from geocoder")
            }
            self.locationManager.stopUpdatingLocation()
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
    
//    func getIP()-> String? {
//
//        var address: String?
//        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
//        if getifaddrs(&ifaddr) == 0 {
//
//            var ptr = ifaddr
//            while ptr != nil {
//                defer { ptr = ptr?.pointee.ifa_next } // memory has been renamed to pointee in swift 3 so changed memory to pointee
//
//                let interface = ptr?.pointee
//                let addrFamily = interface?.ifa_addr.pointee.sa_family
//                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
//
//                    if let name: String = String(cString: (interface?.ifa_name)!), name == "en0" {  // String.fromCString() is deprecated in Swift 3. So use the following code inorder to get the exact IP Address.
//                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
//                        address = String(cString: hostname)
//                    }
//
//                }
//            }
//            freeifaddrs(ifaddr)
//        }
//
//        return address
//    }
    
    
    
    
    @objc func setToPeru(notification: NSNotification) {
        let status = self.providerManager.connection.status
        switch status {
        case .connecting:
            print("Connecting...")
            
            //  connectButton.setTitle("Disconnect", for: .normal)
            break
        case .connected:
            print("Connected...")
            
            let otherAlert = UIAlertController(title: NSLocalizedString("Cancel Confirmation", comment: ""), message: NSLocalizedString("Disconnect the connected VPN cancel the connection attempt?", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            let printSomething = UIAlertAction(title: NSLocalizedString("DISCONNECT", comment: ""), style: UIAlertAction.Style.default) { _ in
                print("We can run a block of code." )
                if ((UserDefaults.standard.value(forKey: "connected")) != nil) {
                    UserDefaults.standard.removeObject(forKey: "connected")
                }
                
                self.providerManager?.connection.stopVPNTunnel()
                
                UserDefaults.standard.removeObject(forKey: "userid")
                //                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                //                appdelegate.login()
                
            }
            
            
            
            let dismiss = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
            
            // relate actions to controllers
            otherAlert.addAction(printSomething)
            
            otherAlert.addAction(dismiss)
            
            present(otherAlert, animated: true, completion: nil)
            
            
            
            // connectButton.setTitle("Disconnect", for: .normal)
            break
        case .disconnecting:
            print("Disconnecting...")
            break
        case .disconnected:
            print("Disconnected...")
            if ((UserDefaults.standard.value(forKey: "connected")) != nil) {
                UserDefaults.standard.removeObject(forKey: "connected")
            }
            if (UserDefaults.standard.value(forKey: "locationstr") != nil) {
                UserDefaults.standard.removeObject(forKey: "locationstr")
                
            }
            UserDefaults.standard.removeObject(forKey: "userid")
            //            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            //            appdelegate.login()
            //connectButton.setTitle("Connect", for: .normal)
            break
        case .invalid:
            print("Invliad")
            break
        case .reasserting:
            print("Reasserting...")
            break
        }
        
        
    }
    
    
    func countryck() {
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied ||  CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        } else {
            print("PLease turn on location services or GPS")
        }
    }
    
}

extension HomeViewController:ServerListProtocol{
    
    func selectServer(server: Server) {
        serverIP.text = server.serverIP
    }
    
    
}
