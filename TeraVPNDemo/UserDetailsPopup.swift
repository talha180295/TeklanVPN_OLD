//
//  UserDetailsPopup.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 21/03/2021.
//  Copyright © 2021 abc. All rights reserved.
//

import UIKit

class UserDetailsPopup: UIViewController {

    @IBOutlet weak var expiryLable:UILabel!
    @IBOutlet weak var packageLable:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userData = HelperFunc().getUserDefaultData(dec: LoginResponse.self, title: User_Defaults.user)
        
        if userData?.nextdue == "0000-00-00"{
            self.expiryLable.text = "never"
        }
        else{
            self.expiryLable.text = userData?.nextdue ?? ""
        }
        
        self.packageLable.text = userData?.package ?? ""
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
