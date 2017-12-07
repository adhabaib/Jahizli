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
    let NOTIFICATION_ORDER_ACCEPTED = "AppDelegate_FKOrder_Accepted"
    let NOTIFICATION_ORDER_READY = "AppDelegate_FKOrder_Ready"
    let NOTIFICATION_ORDER_COMPLETED = "AppDelegate_FKOrder_Completed"
    
    @IBOutlet weak var orderStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Debug: Proceed to testing.")
       
        user = FKCustomer()
        user.getUserCountryLocation()
        //user.isUserSignedIn()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRequestAccepted), name: Notification.Name(self.NOTIFICATION_ORDER_ACCEPTED ), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRequestReady), name: Notification.Name(self.NOTIFICATION_ORDER_READY ), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRequestComplete), name: Notification.Name(self.NOTIFICATION_ORDER_COMPLETED), object: nil)
        
    
        
        
        
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
    @objc func handleRequestAccepted(){
      
        self.orderStatusLabel.text = "Your order has been accepted"

    }
    
    @objc func handleRequestReady(){
        self.orderStatusLabel.text = "Your order is ready for pickup"
        
    }
    
    @objc func handleRequestComplete(){
        self.orderStatusLabel.text = "You picked up the order, Awesome"
        
    }
    @IBAction func triggerEvent(_ sender: Any) {
        
        
        let now = Date()
        let item = FKMenuItem()
        
        item.itemName_en = "Mighty Zinger"
        item.itemInfo_ar = "مايتي زينقر"
        item.itemInfo_en = "Yummy!"
        item.itemInfo_ar = "**"
     
        item.itemPrice = 1.2
        item.itemCategory = "Sandwitches"

        
        order = FKOrder()
        
        
        order.setupOrder(orderDateTime: now, orderStage: "PENDING", orderPaymentMethod: "KNET", customerPhoneNumber: self.user.phoneNumber, supplierID: "-KyHZnXjeBGI11vY2Urv", dispatchID: "-KyHZndMOirc5wySserg", customerFCMToken: self.user.fcmToken, country: "Kuwait")
        
        
        order.addOrderItemToOrder(item: item, quantity: 1, instructions: "No tomatoes please!")
        
        item.itemName_en = "Fries"
        item.itemInfo_ar = "البطاطس"
        item.itemInfo_en = "Classic KFC Fries"
        item.itemInfo_ar = "**"
        item.itemPrice = 0.5
        item.itemCategory = "Sides"
    
        
        order.addOrderItemToOrder(item: item, quantity: 2, instructions: "No instruction given!")
        

        
        
        order.uploadNewOrderToFirebaseDB()
        
    }
    
}




