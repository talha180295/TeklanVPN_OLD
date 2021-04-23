//
//  LocationVC.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 20/03/2021.
//  Copyright © 2021 abc. All rights reserved.
//

import UIKit

protocol ServerListProtocol {
    func selectServer(server:Server)
}

class LocationVC: UIViewController {
    
    @IBOutlet weak var serverNameTbl:UITableView!
    
    var serverList = [Server]()
    var delegate:ServerListProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Servers"
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        HelperFunc().registerTableCell(tableView: serverNameTbl, nibName: "MenuCell", identifier: "MenuCell")
        serverNameTbl.delegate = self
        serverNameTbl.dataSource = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
}

extension LocationVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.flag.image = UIImage.init(named: serverList[indexPath.item].flag ?? "")
        cell.countryName.text = serverList[indexPath.item].country
        cell.cityName.text = serverList[indexPath.item].city
        cell.time.text = ""
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
//        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
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
