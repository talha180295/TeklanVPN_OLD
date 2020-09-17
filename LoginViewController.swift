//
//  LoginViewController.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 16/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTF:UITextField!
    @IBOutlet weak var passwordTF:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTF.text  = "test@user.com"
        passwordTF.text  = "q0D5whHYs"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func loginBtn(_ sender:UIButton){
        let params = ["username":usernameTF.text!,"password":passwordTF.text!]
        
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
                self.navigationController?.pushViewController(vc, animated: true)
 
            }
            
        }
        
    }
    
    
}
