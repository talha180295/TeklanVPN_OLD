//
//  HelperFunc.swift
//  Bidkum
//
//  Created by dev on 22/02/2020.
//  Copyright © 2020 bidkum. All rights reserved.
//

import Foundation
import UIKit
import iProgressHUD
import EzPopup

class HelperFunc{
    
    let iprogress: iProgressHUD = iProgressHUD()
   
    lazy var userIsLogin:Bool = {

          guard let _ = getUserDefaultData(dec: LoginResponse.self, title: User_Defaults.user)
              else{return false}

          return true
      }()
    
    func getFormatedDate(dateStr:String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"

        let formateDate = dateFormatter.date(from:dateStr)!
        dateFormatter.dateFormat = "dd/MM/yyyy" // Output Formated
    //        let date: Date? = dateFormatter.date(from: dateStr)
        
        return dateFormatter.string(from: formateDate)
        
    }
    
    
    func presentVC(identifier:String, style:UIModalPresentationStyle = .fullScreen) -> UIViewController{
        
//        let vc = AppConstants.mainStoryBoard.instantiateViewController(identifier: identifier)
        let vc = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = style
        
        return vc
    }
    
    func saveUserDefaultData<T:Codable>(data:T, title:String){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
           
            UserDefaults.standard.set(encoded, forKey: title)
            UserDefaults.standard.synchronize()
        }
    }
    
    func deleteUserDefaultData(title:String){
        
        UserDefaults.standard.removeObject(forKey: title)
        UserDefaults.standard.synchronize()
        
    }
    
    func getUserDefaultData<T:Decodable>(dec:T.Type, title:String) -> T?{
        
        guard let data = UserDefaults.standard.object(forKey: title) as? Data
        else{ return nil}
       
        let decoder = JSONDecoder()
       
        guard let val = try? decoder.decode(dec.self, from: data)
        else{ return nil}

        return val
   
    }
//    func saveUserDefaultNormalData<T>(data:T, title:String){
//       
//        UserDefaults.standard.set(data, forKey: title)
//    
//    }
//    func getUserDefaultNormalData(title:String) -> Data?{
//         
//         guard let data = UserDefaults.standard.object(forKey: title) as? Data
//         else{ return nil}
//        
//       
//
//         return data
//    
//     }

    
    func registerTableCell(tableView:UITableView,nibName:String,identifier:String){
        
        tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView()
        
    }
    func registerCollectionCell(collectionView:UICollectionView,nibName:String,identifier:String){
           
        collectionView.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: identifier)
          
    }
    
//    func checkLang(){
//
//        if(AppLanguage.getAppLang() == "ar"){
//            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//        }
//        else{
//            UIView.appearance().semanticContentAttribute = .forceLeftToRight
//        }
//    }
    
    /**
    * @brief this is a generic method use to show toast with generic message
    * @param message: String
    * @param controller: UIViewController
    **/
    public func showToast(message: String, controller: UIViewController) {
       let toastContainer = UIView(frame: CGRect())
       toastContainer.backgroundColor = UIColor.darkGray
       toastContainer.alpha = 1
       toastContainer.layer.cornerRadius = 10;
       toastContainer.clipsToBounds  =  true
       
       let toastLabel = UILabel(frame: CGRect())
       toastLabel.textColor = UIColor.white
       toastLabel.textAlignment = .center;
       toastLabel.font.withSize(12.0)
       toastLabel.text = message
       toastLabel.clipsToBounds  =  true
       toastLabel.numberOfLines = 0
       
       toastContainer.addSubview(toastLabel)
       controller.view.addSubview(toastContainer)
       
       toastLabel.translatesAutoresizingMaskIntoConstraints = false
       toastContainer.translatesAutoresizingMaskIntoConstraints = false
       
       let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
       let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
       let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
       let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
       toastContainer.addConstraints([a1, a2, a3, a4])
       
       let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
       let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
       let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -75)
       controller.view.addConstraints([c1, c2, c3])
       
       UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
           toastContainer.alpha = 1
       }, completion: { _ in
           UIView.animate(withDuration: 0.5, delay: 3.0, options: .curveEaseOut, animations: {
               toastContainer.alpha = 0.0
           }, completion: {_ in
               toastContainer.removeFromSuperview()
           })
       })
    }


    func presentOnMainScreens(controller: UIViewController,index:Int){
       
//       let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "customVC")
//       tab_index = index
//       vc.modalTransitionStyle = .crossDissolve
//       vc.modalPresentationStyle = .fullScreen
//       controller.present(vc, animated: true, completion: nil)
    }


    /*! @discussion this method is use to add spinner

    *  @param view : UIView
    */
    func showSpinner(view : UIView) {
       
       
       iprogress.isShowModal = true
       iprogress.isShowCaption = false
       iprogress.isTouchDismiss = false
       iprogress.indicatorStyle = .circleStrokeSpin
       iprogress.indicatorColor = .white
       iprogress.boxColor = .gray
       iprogress.iprogressStyle = .vertical
       iprogress.indicatorStyle = .ballRotateChase
       iprogress.indicatorSize = 50
       iprogress.boxSize = 20

       iprogress.indicatorView.startAnimating()
       
       iprogress.attachProgress(toView: view)
       view.showProgress()
       
    }
    func hideSpinner(view : UIView) {
       iprogress.indicatorView.stopAnimating()
       view.dismissProgress()
    }
    
    /** @brief this is a generic method use to validate email
    * @param enteredEmail:String
    * @return Bool
    **/
    func validateEmail(enteredEmail:String) -> Bool {
       
       let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
       let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
       return emailPredicate.evaluate(with: enteredEmail)
       
    }
    func popUp(popup : UIViewController,source:UIViewController, popupWidth: CGFloat, popupHeight: CGFloat ,cornerRadius:CGFloat){
       
       
       
       let popupVC = PopupViewController(contentController: popup, popupWidth: popupWidth, popupHeight: popupHeight)
       popupVC.canTapOutsideToDismiss = true
       
       //properties
       //            popupVC.backgroundAlpha = 1
       //            popupVC.backgroundColor = .black
       //            popupVC.canTapOutsideToDismiss = true
                   popupVC.cornerRadius = cornerRadius
       //            popupVC.shadowEnabled = true
       
       // show it by call present(_ , animated:) method from a current UIViewController
       source.present(popupVC, animated: true)
    }
    
    func showAlert(title: String, message: String, controller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
}
