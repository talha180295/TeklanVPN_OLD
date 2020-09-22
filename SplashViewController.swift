//
//  SplashViewController.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 23/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginResponse = HelperFunc().getUserDefaultData(dec: LoginResponse.self, title: User_Defaults.user)
       
        if loginResponse != nil && loginResponse?.success == "true"{
            openHomeScreen(loginResponse: loginResponse!)
        }
        else{
            openLoginScreen()
        }
        
        
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
    
    func openHomeScreen(loginResponse:LoginResponse){
        
        var vc = VPNViewController()
        if #available(iOSApplicationExtension 13.0, *) {
            vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VPNViewController") as! VPNViewController
            
        } else {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "VPNViewController") as! VPNViewController
        }
        
        vc.serverList = loginResponse.server ?? [Server]()
        vc.username = loginResponse.username
        vc.password = loginResponse.password
        vc.usagelimit = Double(loginResponse.usage?.usagelimit ?? "0")
        vc.usageRemaining = Double(loginResponse.usage?.remaining ?? 0)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
