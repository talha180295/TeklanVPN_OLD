//
//  AppConstants.swift
//  Bidkum
//
//  Created by dev on 16/02/2020.
//  Copyright © 2020 bidkum. All rights reserved.
//

import Foundation
import UIKit

class AppConstants {
        
    static let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)    
    
    struct API {
        static let BASE_URL = "https://cloud.teravpn.com/api/app/"
        static let IMG_URL = "http://app.bidkum.com/uploads/"
        
    }
    
    
    static let msk = "0rDfLKFURLJQEZKp6iEOmTxOTGftAq5BSJRDuwxlihcXgWmnf0bCTIqNpGh07nCZ7tCBZaXir9fH6B5mCgYvZpjo5BocZ1c6uOHu"

    static let me = "info@bidkum.com"
   
    
    static let user = "User"
    static let cartItems = "Cart_Items"
    static let favItems = "fav_Items"
    static let orderModel = "orderModel"
    static let cartModel = "cartModel"
}

class AppLanguage{
    
    static let AppLang = "AppLang"
    static let english = "en"
    static let arabic = "ar"
   
    static func getAppLang() -> String{
        
       return  UserDefaults.standard.string(forKey: AppLanguage.AppLang) ?? "en"
    }
    static func setAppLang(lang:String){
        
        UserDefaults.standard.set(lang, forKey: AppLanguage.AppLang)
    }

}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}
