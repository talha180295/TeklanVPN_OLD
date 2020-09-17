//
//  TopBarView.swift
//  Bidkum
//
//  Created by dev on 22/02/2020.
//  Copyright © 2020 bidkum. All rights reserved.
//

import UIKit
import Foundation

protocol TopBarViewDelegate {
    
    func rightBtnClick()
    func leftBtnClick()
    func serach(searchText:String)
//    func setupTopBar();
}

extension TopBarViewDelegate{
    
    func serach(searchText:String){
        print("search")
    }
    
}

@IBDesignable class TopBarView: UIView, UISearchBarDelegate {

    
    var delegate:TopBarViewDelegate?
    
    //IBOutlets
    @IBOutlet weak var titleStr:UILabel!
    @IBOutlet weak var leftBtn:UIButton!
    @IBOutlet weak var rightBtn:UIButtonBadge!
    @IBOutlet weak var searchBar: UISearchBar!
    
       
    // Our custom view from the XIB file
    var view: UIView!

    
    override init(frame: CGRect) {
        // 1. setup any properties here

        // 2. call super.init(frame:)
        super.init(frame: frame)

        // 3. Setup view from .xib file
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here

        // 2. call super.init(coder:)
        super.init(coder: aDecoder)

        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        
        view = loadViewFromNib()

        // use bounds not frame or it'll be offset
        view.frame = bounds
        searchBar.delegate = self
        // Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {

        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TopBarView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

        return view
    }
    
    @IBAction func leftBtn(sender:UIButton){
        delegate?.leftBtnClick()
    }
    
    @IBAction func rightBtn(sender:UIButton){
        delegate?.rightBtnClick()
    }

    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        
        delegate?.serach(searchText: searchText)
      
    }
}

