//
//  APIRouter.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 16/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import Foundation
//
//  APIRouter.swift
//  Bidkum
//
//  Created by dev on 26/02/2020.
//  Copyright © 2020 bidkum. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    
    
    case login([String:Any])
    case usage([String:Any])
    case signup([String:Any])
    case getShopList
    case getCategoryProduct([String:Any])
    case getshopadvertise([String:Any])
    case Getappleveladvertisement
    case suggestion([String:Any])
    case getMyNotification
    case order(data:Data)
    case GetCharity
    case orderhistory([String:Any])
    case firebasetoken([String:Any])
    case updateprofile([String:Any])
    case uploadprofileimg([String:Any])
    case loginwithSocialMedia([String:Any])
    case produtReview([String:Any])
    case changepassword([String:Any])
    case Forgetpassword([String:Any])
//    case cancelSellerParking(id:Int)
//    case assignBuyer(id:Int,[String:Any])
    
    
//    private var accessToken:String{
//        return  UserDefaults.standard.string(forKey: "auth_token") ?? ""
//    }
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        
            
        case .login ,.signup ,.getCategoryProduct, .suggestion, .order, .firebasetoken, .updateprofile, .uploadprofileimg, .loginwithSocialMedia, .produtReview, .changepassword, .usage:
            return .post
        case .getShopList, .getshopadvertise, .Getappleveladvertisement, .getMyNotification, .GetCharity, .orderhistory, .Forgetpassword:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
       
        switch self {
       
        case .login:
            return "login.php"
        case .usage:
            return "usage.php"
        case .signup:
            return "signup"
        case .getShopList:
            return "shoplist"
        case .getCategoryProduct(_):
            return "categoryproduct"
        case .getshopadvertise(_):
            return "shopadvertise"
        case .Getappleveladvertisement:
            return "Getappleveladvertisement"
        case .suggestion:
            return "suggestion"
        case .getMyNotification:
            return "getMyNotification"
        case .order:
            return "order"
        case .GetCharity:
            return "GetCharity"
        case .orderhistory:
            return "orderhistory"
        case .firebasetoken:
            return "firebasetoken"
        case .updateprofile:
            return "updateprofile"
        case .uploadprofileimg:
            return "uploadprofileimg"
        case .loginwithSocialMedia:
            return "loginwithSocialMedia"
        case .produtReview:
            return "produtReview"
        case .changepassword:
            return "changepassword"
        case .Forgetpassword:
            return "Forgetpassword"
        }
    }
    
//    private var contentType: String? {
//
//        switch self {
//        case .login ,.signup ,.getCategoryProduct, .suggestion, .firebasetoken, .updateprofile, .uploadprofileimg, .loginwithSocialMedia, .produtReview, .changepassword:
//                return "application/x-www-form-urlencoded"
//            case .order:
//                return "application/json"
//        case .getShopList, .getshopadvertise, .Getappleveladvertisement, .getMyNotification, .GetCharity, .orderhistory, .Forgetpassword:
//            return nil
//
//        }
//
//    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
       
        case .login(let params):
            return (params)
        case .usage(let params):
            return (params)
        case .signup(let params):
            return (params)
        
        case .getShopList:
            return nil
        case .getCategoryProduct(let params):
            return (params)
        case .getshopadvertise(let params):
            return (params)
        case .Getappleveladvertisement:
            return nil
        case .suggestion(let params):
            return (params)
        case .getMyNotification:
            return nil
        case .order:
            return nil
        case .GetCharity:
            return nil
        case .orderhistory(let params):
            return (params)
        case .firebasetoken(let params):
            return (params)
        case .updateprofile(let params):
            return (params)
        case .uploadprofileimg(let params):
            return (params)
        case .loginwithSocialMedia(let params):
            return (params)
        case .produtReview(let params):
            return (params)
        case .changepassword(let params):
            return (params)
        case .Forgetpassword(let params):
            return (params)
        }
    }
    
    // MARK: - HTTPMethod
    private var urlEncoding: URLEncoding {
        switch self {
        
        case .login ,.usage, .signup, .getCategoryProduct, .suggestion, .order,.firebasetoken, .updateprofile,.uploadprofileimg, .loginwithSocialMedia, .produtReview, .changepassword:
            return .httpBody
        case .getShopList, .getshopadvertise ,.Getappleveladvertisement, .getMyNotification, .GetCharity, .orderhistory, .Forgetpassword:
            return .default
        }
    }
    
    // MARK: - HTTPMethod
//    private var body: Data? {
//        switch self {
//        
//        case .getShopList, .getshopadvertise ,.Getappleveladvertisement, .getMyNotification,.orderhistory, .GetCharity ,.signup, .getCategoryProduct, .suggestion, .firebasetoken, .updateprofile, .uploadprofileimg, .loginwithSocialMedia, .produtReview, .changepassword, .Forgetpassword:
//            return nil
//        case .order(let data):
//            return data
//        case .login:
//            return nil
//       
//        }
//    }

    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try AppConstants.API.BASE_URL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
//        // Common Headers
//        urlRequest.setValue("application/json", forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
//
       
//        urlRequest.allHTTPHeaderFields = ["Content-Type" : "application/x-www-form-urlencoded"]

//        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")

        
//        urlRequest.httpBody = body

       
//        urlRequest.allHTTPHeaderFields = ["Authorization" : K.AccessToken]
        

        return try urlEncoding.encode(urlRequest, with: parameters)
//        return urlRequest
    }
}
