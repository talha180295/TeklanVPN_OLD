//
//  SplashViewController.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 23/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var versionStr:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionStr.text = "Version \(appVersion ?? "")"
        
//        let loginResponse = HelperFunc().getUserDefaultData(dec: LoginResponse.self, title: User_Defaults.user)
       
        let userCredentials = HelperFunc().getUserDefaultData(dec: UserCredentials.self, title: User_Defaults.userCredentials)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            if userCredentials != nil {
//                self.openHomeScreen(loginResponse: loginResponse!)
                self.login(username: userCredentials?.username ?? "", password:  userCredentials?.password ?? "")
            }
            else{
                self.openLoginScreen()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    

    func openLoginScreen(){
        var vc = LoginViewController()
        if #available(iOSApplicationExtension 13.0, *) {
            vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as! LoginViewController

        } else {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func openHomeScreen(loginResponse:LoginResponse){
//
//        var vc = VPNViewController()
//        if #available(iOSApplicationExtension 13.0, *) {
//            vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VPNViewController") as! VPNViewController
//
//        } else {
//            vc = self.storyboard?.instantiateViewController(withIdentifier: "VPNViewController") as! VPNViewController
//        }
//
//        vc.serverList = loginResponse.server ?? [Server]()
//        vc.username = loginResponse.username
//        vc.password = loginResponse.password
////        vc.usagelimit = Double(loginResponse.usage?.usagelimit ?? "0")
////        vc.usageRemaining = Double(loginResponse.usage?.remaining ?? 0)
//
//        self.navigationController?.pushViewController(vc, animated: true)
//    }

    
    func login(username:String, password:String){
        
        let params = ["username":username,"password":password]
        
        let request = APIRouter.login(params)
        NetworkService.serverRequest(url: request, dec: LoginResponse.self, view: self.view) { (loginResponse, error) in
            
            if loginResponse?.success == "true"{
                
                var vc = VPNViewController()
                if #available(iOSApplicationExtension 13.0, *) {
                    vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VPNViewController") as! VPNViewController
                    
                } else {
                    vc = self.storyboard?.instantiateViewController(withIdentifier: "VPNViewController") as! VPNViewController
                }
                
                vc.serverList = loginResponse?.server ?? [Server]()
                vc.username = loginResponse?.username
                vc.password = loginResponse?.password
//                vc.usagelimit = Double(loginResponse?.usage?.usagelimit ?? "0")
//                vc.usageRemaining = Double(loginResponse?.usage?.remaining ?? 0)
                
                let userCredentials = UserCredentials.init(username: username, password: password)
                HelperFunc().deleteUserDefaultData(title: User_Defaults.userCredentials)
                HelperFunc().saveUserDefaultData(data: userCredentials, title: User_Defaults.userCredentials)
                
                HelperFunc().deleteUserDefaultData(title: User_Defaults.user)
                HelperFunc().saveUserDefaultData(data: loginResponse, title: User_Defaults.user)
                self.navigationController?.pushViewController(vc, animated: true)
 
            }
            
        }
        
    }

}
