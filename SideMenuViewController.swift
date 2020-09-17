//
//  SideMenuViewController.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 17/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import UIKit

protocol ServerListProtocol {
    func selectServer(server:Server)
}

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var serverNameTbl:UITableView!
    
    var serverList = [Server]()
    var delegate:ServerListProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        HelperFunc().registerTableCell(tableView: serverNameTbl, nibName: "MenuCell", identifier: "MenuCell")
        serverNameTbl.delegate = self
        serverNameTbl.dataSource = self
    }
    
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.name.text = serverList[indexPath.item].country
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.selectServer(server: serverList[indexPath.item])
        //        var varr = [String : Any]()
        do{
            let varr = try serverList[indexPath.row].asDictionary()
            
            
            UserDefaults.standard.set(varr, forKey: "selectvalue")
            UserDefaults.standard.synchronize()
            
            print(UserDefaults.standard.value(forKey: "selectvalue") as Any)
            
            //        let ViewCont =   self.storyboard?.instantiateViewController(withIdentifier: "main") as! MainController
            //        self.navigationController?.pushViewController(ViewCont, animated: false)
        }
        catch{
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
