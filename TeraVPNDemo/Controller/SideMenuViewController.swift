//
//  SideMenuViewController.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 17/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import UIKit

//protocol ServerListProtocol {
//    func selectServer(server:Server)
//}

class SideMenuViewController: UIViewController {
    
//    @IBOutlet weak var menuTble:UITableView!
    
    var serverList = [Server]()
    var delegate:ServerListProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
//        
//        HelperFunc().registerTableCell(tableView: menuTble, nibName: "MenuCell", identifier: "MenuCell")
//        menuTble.delegate = self
//        menuTble.dataSource = self
    }
    
    @IBAction func settingsBtn(_ sender:UIBarButtonItem){
        
        self.openSettingsScreen()
       
    }
    
    @IBAction func locationBtn(_ sender:UIButton){
        
        var vc = LocationVC()
        if #available(iOSApplicationExtension 13.0, *) {
            vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LocationVC") as! LocationVC
            
        } else {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "LocationVC") as! LocationVC
        }
        
        vc.serverList = self.serverList
        vc.delegate = self.delegate
        
        self.navigationController?.pushViewController(vc, animated: true)
        
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
        HelperFunc().deleteUserDefaultData(title: User_Defaults.adBlocker)
        
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
//
//extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return serverList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
//        cell.flag.image = UIImage.init(named: serverList[indexPath.item].flag ?? "")
//        cell.countryName.text = serverList[indexPath.item].country
//        cell.cityName.text = serverList[indexPath.item].city
//        cell.time.text = ""
//        return cell
//    }
//
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        delegate?.selectServer(server: serverList[indexPath.item])
//        //        var varr = [String : Any]()
//        do{
//            let varr = try serverList[indexPath.row].asDictionary()
//
//
//            UserDefaults.standard.set(varr, forKey: "selectvalue")
//            UserDefaults.standard.synchronize()
//
//            print(UserDefaults.standard.value(forKey: "selectvalue") as Any)
//
//            //        let ViewCont =   self.storyboard?.instantiateViewController(withIdentifier: "main") as! MainController
//            //        self.navigationController?.pushViewController(ViewCont, animated: false)
//        }
//        catch{
//
//        }
//        dismiss(animated: true, completion: nil)
//
//    }
//
//}
//
//extension Encodable {
//    func asDictionary() throws -> [String: Any] {
//        let data = try JSONEncoder().encode(self)
//        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
//            throw NSError()
//        }
//        return dictionary
//    }
//}
