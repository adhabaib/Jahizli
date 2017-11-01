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
    
    //MARK:  public variables
    var id : String = ""
    var orderDateTime: String = ""
    var orderStage : String = ""
    var orderPaymentMethod: String = ""
    var orderTotalPrice: Double = 0.0
    var customerPhoneNumber: String = ""
    var supplierID: String = ""
    var dispatchID: String = ""
    var customerFCMToken: String = ""
    var country: String = ""
    
    
    var orderItems = [FKOrderItem]()
    
    
    //MARK:  notification tags
    let NOTIFICATION_UPLOAD = "FKOrder_Uploaded"
    let NOTIFICATION_OBSERVE_EMPTY = "FKOrder_Observe_Empty"
    let NOTIFICATION_OBSERVE = "FKOrder_Observe_Found"
    let NOTIFICATION_FETCHED_ITEMS = "FKOrder_Observe_Order_Items"
    let NOTIFICATION_UPDATED = "FKOrder_Updated_Order"
    
    
    //MARK: Initializer Method
    func setupOrder(orderDateTime: Date, orderStage: String, orderPaymentMethod: String, customerPhoneNumber: String, supplierID: String, dispatchID: String, customerFCMToken: String, country: String){
        
        self.orderDateTime = self.dateTimeToString(date: orderDateTime)
        self.orderStage = orderStage
        self.orderPaymentMethod = orderPaymentMethod
        self.customerPhoneNumber = customerPhoneNumber
        self.supplierID = supplierID
        self.dispatchID = dispatchID
        self.customerFCMToken = customerFCMToken
        self.country = country
        
    }
    
    //MARK: Firebase Real-time Database Functions
    //* (A) Upload New Order To Real-time Database
    func uploadNewOrderToFirebaseDB(){
        
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let orderRef = ref.child(self.country).child("FKSupplierDispatches").child(self.dispatchID).child("FKOrdersWaiting").childByAutoId()
        self.id = orderRef.key
    

        // Setup JSON Object
        let order = [
            "id" : self.id,
            "orderDateTime" : self.orderDateTime,
            "orderStage" : self.orderStage,
            "orderPaymentMethod" : self.orderPaymentMethod,
            "orderTotalPrice" : self.getTotalPriceFromOrderItems(),
            "customerPhoneNumber" : self.customerPhoneNumber,
            "supplierID" : self.supplierID,
            "dispatchID" : self.dispatchID,
            "customerFCMToken" : self.customerFCMToken,
            "country" : self.country
        ]
        
        // Save Object to Real-time Database
        
        
        orderRef.setValue(order,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            self.print_action(string: "**** FKOrder: NEW order uploaded to Firebase Realtime-Database!****\n\(order)")
            
            self.uploadAllNewOrderItemsToFireBaseDB()
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOAD), object: nil)
            
            }
            
        })
        
        
    }
    
    //* (B) Upload Completed Order To Real-time Database
    func uploadCompletedOrderToFirebaseDB(){
        
        // Remove Order From Waiting List
        
        // Remove Waiting order From Firebase -> Removes All order items
    Database.database().reference().child(self.country).child("FKSupplierDispatches").child(self.dispatchID).child("FKOrdersWaiting").child(self.id).removeValue()
        

        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let orderRef = ref.child(self.country).child("FKOrdersCompleted").child(self.dispatchID).childByAutoId()
        self.id = orderRef.key
        
        
        // Setup JSON Object
        let order = [
            "id" : self.id,
            "orderDateTime" : self.orderDateTime,
            "orderStage" : "COMPLETE",
            "orderPaymentMethod" : self.orderPaymentMethod,
            "orderTotalPrice" : self.getTotalPriceFromOrderItems(),
            "customerPhoneNumber" : self.customerPhoneNumber,
            "supplierID" : self.supplierID,
            "dispatchID" : self.dispatchID,
            "customerFCMToken" : self.customerFCMToken,
            "country" : self.country
        ]
        
        // Save Object to Real-time Database
        
        
        orderRef.setValue(order,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            self.print_action(string: "**** FKOrder: OLD order uploaded to Firebase Realtime-Database! ****\n\(order)")
            
            self.uploadAllCompletedOrderItemsToFireBaseDB()
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOAD), object: nil)
                
            }
            
        })
        
        
    }
    
    
    //* (C) Upload All Order Items to Firebase Database
    func uploadAllNewOrderItemsToFireBaseDB(){
        for orderItem in self.orderItems {
            orderItem.orderID = self.id
            orderItem.uploadNewOrderItemToFireBaseDB()
        }
    }
    
    //* (D) Upload All Completed Order Items to Firebase Database
    func uploadAllCompletedOrderItemsToFireBaseDB(){
        for orderItem in self.orderItems {
            orderItem.orderID = self.id
            orderItem.uploadCompletedOrderItemToFireBaseDB()
        }
    }
    
    

    //* (E) Update Order To Firebase Real-time Database
    func updateIncompleteOrderToFireBaseDB(){
       
        print_action(string: "FKOrder: Order updating...")
        let ref  = Database.database().reference().child(self.country).child("FKSupplierDispatches").child(self.dispatchID).child("FKOrdersWaiting").child(self.id)
        
        ref.updateChildValues([
            "id" : self.id,
            "orderDateTime" : self.orderDateTime,
            "orderStage" : self.orderStage,
            "orderPaymentMethod" : self.orderPaymentMethod,
            "orderTotalPrice" : String(self.orderTotalPrice),
            "customerPhoneNumber" : self.customerPhoneNumber,
            "supplierID" : self.supplierID,
            "dispatchID" : self.dispatchID,
            "customerFCMToken" : self.customerFCMToken,
            "country" : self.country
            ], withCompletionBlock: { (NSError, FIRDatabaseReference) in //update the book in the db
                
                // POST NOTIFICATION FOR COMPLETION
                self.print_order()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPDATED), object: nil)
                }
                
        })
    }
    
    
    //MARK:  Firebase Helper Methods
    //* (A)Add Order Item to Order
    func addOrderItemToOrder(item: FKMenuItem, quantity: Int, instructions: String){
        let orderItem = FKOrderItem()
        
        orderItem.setupOrderItem(itemName_en: item.itemName_en, itemName_ar: item.itemName_ar, itemPrice: item.itemPrice, quantity: quantity, instructions: instructions, dispatchID:  self.dispatchID, orderID: self.id, country: self.country)
       
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
    
    //MARK: Helper Functions
    func getTotalPriceFromOrderItems() -> String{
        for orderItem in self.orderItems {
            self.orderTotalPrice = self.orderTotalPrice + orderItem.itemPrice
        }
        
        return String(self.orderTotalPrice)
    }
    
    
    
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
    
    // Print Order
    func print_order(){
        print("\n************* FKOrder Log *************")
        
        let order = [
            "id" : self.id,
            "orderDateTime" : self.orderDateTime,
            "orderStage" : self.orderStage,
            "orderPaymentMethod" : self.orderPaymentMethod,
            "orderTotalPrice" : String(self.orderTotalPrice),
            "customerPhoneNumber" : self.customerPhoneNumber,
            "supplierID" : self.supplierID,
            "dispatchID" : self.dispatchID,
            "customerFCMToken" : self.customerFCMToken,
            "country" : self.country
            ]
        
        print(order)
        print("******************************************\n")
    }
    
    // Print Order Items
    func print_order_items(){
        
        print("\n************* FKOrder Log *************")
        
        let order = [
            "id" : self.id,
            "orderDateTime" : self.orderDateTime,
            "orderStage" : self.orderStage,
            "orderPaymentMethod" : self.orderPaymentMethod,
            "orderTotalPrice" : String(self.orderTotalPrice),
            "customerPhoneNumber" : self.customerPhoneNumber,
            "supplierID" : self.supplierID,
            "dispatchID" : self.dispatchID,
            "customerFCMToken" : self.customerFCMToken,
            "country" : self.country
        ]
        print(order)
        
        for orderItem in self.orderItems {
            let item = [
                "id" : orderItem.id,
                "itemName_en" : orderItem.itemName_en,
                "itemName_ar" : orderItem.itemName_ar,
                "itemPrice" : String(orderItem.itemPrice),
                "quantity" : String(orderItem.quantity),
                "instructions" : orderItem.instructions,
                "orderID" : orderItem.orderID,
                "dispatchID": orderItem.dispatchID,
                "country" : orderItem.country
            ]
            print("\n\(item)")
        }
        print("******************************************\n")

    }
    
}



