//
//  ViewController.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/1/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var supplier: FKSupplier!
    let NOTIFICATION_FETCHED_ITEMS = "FKMenu_Fetched_Items"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Second commmit of project!")
        
        
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.handleRequest), name: Notification.Name(self.NOTIFICATION_FETCHED_ITEMS), object: nil)
        
          supplier = FKSupplier()
          supplier.id = "-Kw_kKtke0eZJ0_AaME-"
          supplier.observeFetchSupplierFromFirebaseDB()
        
        // Debuging Model Classes
        
        /*
        let supplier = FKSupplier()
        let logo = UIImage(named: "logo")
        let display = UIImage(named: "displayImage")
       
        let club = UIImage(named: "club")
        let cake = UIImage(named: "cake")
        let drink = UIImage(named: "water")
        
        supplier.setupSupplier(name_en: "Grill Town", name_ar: "***", status: "Available", hours: "8am-12pm", info_en: "We have everything your heart desires!", info_ar: "***", phone_number: "99166300", balance: 0.0, creditRate: 10.0, logo: logo?.jpeg, displayImage: display?.jpeg, categories_en: ["Main","Drinks","Desert"], categories_ar: ["Main","Drinks","Desert"])

        supplier.menu.addMenuItem(itemName_en: "Club Sandwitch", itemName_ar: "***", itemInfo_en: "Tasty!", itemInfo_ar: "***", itemImage: club?.jpeg, itemPrice: 2.00, itemCategory: "Main")
        supplier.menu.addMenuItem(itemName_en: "Water", itemName_ar: "***", itemInfo_en: "Refreshing!", itemInfo_ar: "***", itemImage: drink?.jpeg, itemPrice: 0.50, itemCategory: "Drinks")
        supplier.menu.addMenuItem(itemName_en: "Cake", itemName_ar: "***", itemInfo_en: "Yummy!", itemInfo_ar: "***", itemImage: cake?.jpeg, itemPrice: 3.50, itemCategory: "Desert")
       */

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Helper Functions
    @objc func handleRequest(){
        
        supplier.removeSupplierFromFireBaseDB()
        
        
    }

}

