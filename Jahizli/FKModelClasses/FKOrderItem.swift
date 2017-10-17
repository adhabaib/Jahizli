//
//  FKOrderItem.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/16/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import Foundation
import Firebase

// FKOrderItem Class
class FKOrderItem : NSObject {
    
    //MARK:  public variables
    var id: String = ""
    var itemName_en: String = ""
    var itemName_ar: String = ""
    var itemPrice: Double = 0.0
    var quantity : Int = 0
    var orderID: String = ""
    var dispatchID: String = ""
    var instructions: String = ""

    
    
    
    //MARK:  notification tag
    let NOTIFICATION_UPLOAD = "FKOrderItem_Uploaded"
    
    //MARK:  Initializer Method
    func setupOrderItem(itemName_en: String, itemName_ar: String, itemPrice: Double,quantity: Int, instructions: String, dispatchID: String, orderID: String){
        self.itemName_en = itemName_en
        self.itemName_ar = itemName_ar
        self.itemPrice = itemPrice
        self.quantity = quantity
        self.instructions = instructions
        self.orderID = orderID
        self.dispatchID = dispatchID
      
        
    }

    //MARK:  Firebase Realtime-Database function
    //(A) Upload Order Item To Firebase Realtime-Storage
    func uploadOrderItemToFireBaseDB(){
        
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let orderItemRef = ref.child("FKSupplierDispatches").child(self.dispatchID).child("FKOrdersWaiting").child(self.orderID).child("FKOrderItems").childByAutoId()
        self.id = orderItemRef.key
        
        // Setup JSON Object
        let item = [
            "id" : self.id,
            "itemName_en" : self.itemName_en,
            "itemName_ar" : self.itemName_ar,
            "itemPrice" : String(self.itemPrice),
            "quantity" : String(self.quantity),
            "instructions" : self.instructions,
            "orderID" : self.orderID,
            "dispatchID" : self.dispatchID
        ]
        
        // Save Object to Real-time Database
        
        orderItemRef.setValue(item,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            self.print_action(string: "**** FKOrderITem: item uploaded to Firebase Realtime-Database! ****")
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOAD), object: nil)
            }
            
        })
        
    }
    
    
    //MARK:  Helper Methods
    
    func print_action(string: String){
        print("\n************* FKOrderItem Log *************")
        print(string)
        print("******************************************\n")
        
    }
    
    
}
