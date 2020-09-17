//
//  NetworkService.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 16/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import Foundation
import Alamofire


class NetworkService{
    
    static func serverRequest<T:Decodable>(url:URLRequestConvertible,dec:T.Type, view:UIView?,completion:@escaping (T? ,Error?)->Void) {
        
        print("url==\(String(describing: try? url.asURLRequest()))")
        
//        var hud = MBProgressHUD()
        if let myView = view {
            HelperFunc().showSpinner(view: myView)
//            hud = MBProgressHUD.showAdded(to: myView, animated: true)
        }
        
        Alamofire.request(url).responseJSON { (response) in
            
            print(response.data)
            if let myView = view {
                HelperFunc().hideSpinner(view: myView)
            }
            
            
            switch response.result {
            case .success:
                if(response.response?.statusCode ?? 0 >= 200 && response.response?.statusCode ?? 0  <= 299){
                    
                    if response.result.isSuccess {
                        
                        
                        do {
                            //here dataResponse received from a network request
                            if let jsonData = response.data{
                                let response = try JSONDecoder().decode(dec.self, from:jsonData) //Decode JSON Response Data
                                
                                completion(response, nil)
                            }
                        } catch let parsingError {
                            print("Error", parsingError)
                            completion(nil,parsingError)
                        }
                        
                        
                    }
                    else{

                        completion(nil,response.error!)
                    }
                }
                else if(response.response?.statusCode ?? 0 == 401){
                    
                    //refresh Token
                    completion(nil,nil)
                }
                break
            case .failure(let error):
                completion(nil,error)
                break
            }
   
        }
    }
    
}
