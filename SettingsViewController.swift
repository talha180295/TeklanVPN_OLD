//
//  SettingsViewController.swift
//  TeraVPNDemo
//
//  Created by talha on 20/10/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var expiryLable:UILabel!
    @IBOutlet weak var packageLable:UILabel!
    @IBOutlet weak var adSwitch:UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userData = HelperFunc().getUserDefaultData(dec: LoginResponse.self, title: User_Defaults.user)
        
        self.expiryLable.text = "Account Expires: \(userData?.nextdue ?? "")"
        self.packageLable.text = "Package: \(userData?.package ?? "")"
        self.adSwitch.isOn = false
    }
    
    @IBAction func switchChange(_ sender:UISwitch){
        
        UserDefaults.standard.set(sender.isOn, forKey: User_Defaults.adBlocker)
    }
    
    //For logout
    @IBAction func logoutBtn(_ sender:UIButton){
        
        let alert = UIAlertController(title: "LOGOUT", message: "Are you sure to logout?", preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) { _ in
            self.logout()
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil)
        
        // relate actions to controllers
        alert.addAction(yesAction)
        
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func logout(){
        
        HelperFunc().deleteUserDefaultData(title: User_Defaults.user)
        HelperFunc().deleteUserDefaultData(title: User_Defaults.userCredentials)
        
        openLoginScreen()
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
    
}
