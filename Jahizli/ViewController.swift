//
//  ViewController.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/1/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController {
   
    @IBOutlet weak var textfield: UITextField!
    
    var supplier: FKSupplier!
    var order: FKOrder!
    var user: FKCustomer!
    let NOTIFICATION_FETCHED_ITEMS = "FKMenu_Fetched_Items"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Debug: Proceed to testing... now!")
       
        user = FKCustomer()
        user.isUserSignedIn()
        
     
        
        /*
         //
        let dispatch = FKSupplierDispatch()
        dispatch.setupSupplierDisptach(supplierID:"-KwfHDulDICJPIFpfypA")
    
       
        let now = Date()
        let club = UIImage(named: "club")
        let item = FKMenuItem()
        item.itemName_en = "Kabab"
        item.itemInfo_ar = "**"
        item.itemInfo_en = "Yummy!"
        item.itemInfo_ar = "**"
        item.itemImage = club?.jpeg
        item.itemPrice = 2.00
        item.itemCategory = "Sandwitches"
        item.path = ""
        item.menuID = ""
    
        order = FKOrder()
        order.setupOrder(orderDateTime: now, orderStage: "Pending", orderPaymentMethod: "KNET", customerPhoneNumber: "99166300", supplierID: "-KwfHDulDICJPIFpfypA", dispatchID: "-KwfnNinXARGkU2sewDy")
        order.addOrderItemToOrder(item: item, quantity: 2, instructions: "Pleae make sure its hot and spicey!")
        order.uploadNewOrderToFirebaseDB()
 
 

        
        let dispatch = FKSupplierDispatch()
        dispatch.id = "-KwfnNinXARGkU2sewDy"
        dispatch.supplierID = "-KwfHDulDICJPIFpfypA"
        
        dispatch.observeFetchAllPendingOrdersFromFireBaseDB()
        
        
        
        self.order = FKOrder()
        self.order.id = "-KwanPBEqoRm3nTR4yiM"
        order.observeFetchOrderFromFirebaseDB()
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.handleRequest), name: Notification.Name(self.order.NOTIFICATION_FETCHED_ITEMS), object: nil)
 
         */
        
        
        
     // supplier = FKSupplier()
     // supplier.id = "-KwfHDulDICJPIFpfypA"
     // supplier.observeFetchSupplierFromFirebaseDB()
        
        
        
      //supplier.fetchLogoImageFromFirebaseStorage()
      //supplier.fetchDisplayImageFromFirebaseStorage()
         
        
 
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
    
    @IBAction func triggerAuthCode(_ sender: Any) {
        user.phoneNumber = "+96599166300"
        user.sendVerficationCodeForAuth()
    }
    
    @IBAction func triggerAuthEvent(_ sender: Any) {
        user.signInWithSMSVerificationCode(verificationCode: self.textfield.text!)
    }
    
    // Helper Functions
    @objc func handleRequest(){
      

    }
    @IBAction func triggerEvent(_ sender: Any) {
        
        
        let now = Date()
        let club = UIImage(named: "club")
        let item = FKMenuItem()
        
        item.itemName_en = "Kabab"
        item.itemInfo_ar = "**"
        item.itemInfo_en = "Yummy!"
        item.itemInfo_ar = "**"
        item.itemImage = club?.jpeg
        item.itemPrice = 2.00
        item.itemCategory = "Sandwitches"
        item.path = ""
        item.menuID = ""
        
        order = FKOrder()
        
        
        order.setupOrder(orderDateTime: now, orderStage: "PENDING", orderPaymentMethod: "KNET", customerPhoneNumber: "99166300", supplierID: "-KwfHDulDICJPIFpfypA", dispatchID: "-KwfnNinXARGkU2sewDy", customerFCMToken: self.user.fcmToken)
        order.addOrderItemToOrder(item: item, quantity: 1, instructions: "No tomatoes please!")
        
        item.itemName_en = "Shwarma"
        item.itemInfo_ar = "**"
        item.itemInfo_en = "With tomatoes, taheena and the best sauce in town!"
        item.itemInfo_ar = "**"
        item.itemImage = club?.jpeg
        item.itemPrice = 2.00
        item.itemCategory = "Sandwitches"
        item.path = ""
        item.menuID = ""
        
        order.addOrderItemToOrder(item: item, quantity: 2, instructions: "Extra taheena sauce.")
        
        item.itemName_en = "Fatoosh"
        item.itemInfo_ar = "**"
        item.itemInfo_en = "All fresh and green, as healthy as it gets!"
        item.itemInfo_ar = "**"
        item.itemImage = club?.jpeg
        item.itemPrice = 1.00
        item.itemCategory = "Sandwitches"
        item.path = ""
        item.menuID = ""
        
        order.addOrderItemToOrder(item: item, quantity: 3, instructions: "No instructions provided.")
        
        item.itemName_en = "Pepsi"
        item.itemInfo_ar = "**"
        item.itemInfo_en = "Yummy!"
        item.itemInfo_ar = "**"
        item.itemImage = club?.jpeg
        item.itemPrice = 0.500
        item.itemCategory = "Sandwitches"
        item.path = ""
        item.menuID = ""
        
        order.addOrderItemToOrder(item: item, quantity: 2, instructions: "Room temprature.")
        
        
        order.uploadNewOrderToFirebaseDB()
        
    }
    
}




