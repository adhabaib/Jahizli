//
//  FKOrder.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/16/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import Foundation
import Firebase

// FKOrder Class
class FKOrder : NSObject {
    
    // public variables
    var id : String = ""
    var orderDateTime: String = ""
    var orderStage : String = ""
    var orderPaymentMethod: String = ""
    var orderTotalPrice: Double = 0.0
    var customerPhoneNumber: String = ""
    var supplierID: String = ""
    
    var orderItems = [FKOrderItem]()
    
    
    // notification tags
    let NOTIFICATION_UPLOAD = "FKOrder_Uploaded"
    
    
    //Initializer Method
    func setupOrder(orderDateTime: Date, orderStage: String, orderPaymentMethod: String, orderTotalPrice : Double, customerPhoneNumber: String, supplierID: String){
        
        self.orderDateTime = self.dateTimeToString(date: orderDateTime)
        self.orderStage = orderStage
        self.orderPaymentMethod = orderPaymentMethod
        self.orderTotalPrice = orderTotalPrice
        self.customerPhoneNumber = customerPhoneNumber
        self.supplierID = supplierID
        
    }
    
    //Firebase Real-time Database Functions
    //(A) Upload Order To Real-time Database
    func uploadOrderToFirebaseDB(){
        
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let orderRef = ref.child("FKOrder").childByAutoId()
        self.id = orderRef.key
        
        // Setup JSON Object
        let order = [
            "id" : self.id,
            "orderDateTime" : self.orderDateTime,
            "orderStage" : self.orderStage,
            "orderPaymentMethod" : self.orderPaymentMethod,
            "orderTotalPrice" : String(self.orderTotalPrice),
            "customerPhoneNumber" : self.customerPhoneNumber,
            "supplierID" : self.supplierID
        ]
        
        // Save Object to Real-time Database
        
        orderRef.setValue(order,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            self.print_action(string: "**** FKOrder: order uploaded to Firebase Realtime-Database! ****")
            
            // Upload Order Items
            self.uploadAllOrderItemsToFireBaseDB()
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOAD), object: nil)
            }
            
        })
        
        
    }
    
    
    // (B) Upload All Order Items to Firebase Database
    func uploadAllOrderItemsToFireBaseDB(){
        for orderItem in self.orderItems {
            orderItem.orderID = self.id
            orderItem.uploadOrderItemToFireBaseDB()
        }
    }
    
    
    // Firebase Helper Methods
    //(A) Add Order Item to Order
    func addOrderItemToOrder(item: FKMenuItem, quantity: Int, instructions: String){
        let orderItem = FKOrderItem()
        
        orderItem.setupOrderItem(itemName_en: item.itemName_en, itemName_ar: item.itemName_ar, itemPrice: item.itemPrice, quantity: quantity, instructions: instructions)
       
        self.orderItems.append(orderItem)
    }
    // (B) Delete Order Item From Order
    func removeOrderItemFromOrder(item:FKMenuItem, quantity: Int, instructions: String){
        var index = 0
        for orderItem in self.orderItems{
            if(orderItem.itemName_en == item.itemName_en && orderItem.quantity == quantity && orderItem.instructions == instructions){
                self.orderItems.remove(at: index)
            }
            index = index + 1
        }
        
    }
    // (C) Update Order Item From Order
    func updateOrderItemFromOrder(item: FKMenuItem, quantity : Int, instructions : String, quantity_new: Int, instructions_new : String){
        for orderItem in self.orderItems{
            if(orderItem.itemName_en == item.itemName_en && orderItem.quantity == quantity && orderItem.instructions == instructions){
                orderItem.quantity = quantity_new
                orderItem.instructions = instructions_new
            }
            
        }
    }
    
    //Helper Functions
    func dateTimeToString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from:date)
        print("FKOrder: Date converted to \(dateString)")
        
        return dateString
    }
    


    func print_action(string: String){
        print("\n************* FKOrder Log *************")
        print(string)
        print("******************************************\n")
        
    }
    
}
