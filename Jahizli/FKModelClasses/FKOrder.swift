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
    
    
    var orderItems = [FKOrderItem]()
    
    
    //MARK:  notification tags
    let NOTIFICATION_UPLOAD = "FKOrder_Uploaded"
    let NOTIFICATION_OBSERVE_EMPTY = "FKOrder_Observe_Empty"
    let NOTIFICATION_OBSERVE = "FKOrder_Observe_Found"
    let NOTIFICATION_FETCHED_ITEMS = "FKOrder_Observe_Order_Items"
    let NOTIFICATION_UPDATED = "FKOrder_Updated_Order"
    
    
    //MARK: *Initializer Method
    func setupOrder(orderDateTime: Date, orderStage: String, orderPaymentMethod: String, customerPhoneNumber: String, supplierID: String, dispatchID: String){
        
        self.orderDateTime = self.dateTimeToString(date: orderDateTime)
        self.orderStage = orderStage
        self.orderPaymentMethod = orderPaymentMethod
        self.customerPhoneNumber = customerPhoneNumber
        self.supplierID = supplierID
        self.dispatchID = dispatchID
        
    }
    
    //MARK: Firebase Real-time Database Functions
    //* (A) Upload Order To Real-time Database
    func uploadNewOrderToFirebaseDB(){
        
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let orderRef = ref.child("FKSupplierDispatches").child(self.dispatchID).child("FKOrdersWaiting").childByAutoId()
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
            "dispatchID" : self.dispatchID
        ]
        
        // Save Object to Real-time Database
        
        
        orderRef.setValue(order,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            self.print_action(string: "**** FKOrder: order uploaded to Firebase Realtime-Database! ****")
            
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
    
    // (C) Observe/Fetch Order From FireBase Realtime-Database
    func observeFetchOrderFromFirebaseDB(){
        
        // Call Observe on Reference
        _ = Database.database().reference().child("FKOrder").queryOrdered(byChild:"id").queryEqual(toValue: id).observe(DataEventType.value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKOrder: Order was not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let orderID = postDict?.allKeys.first as! String
                
                // Get Item Data
                let orderData = postDict?[orderID] as? NSDictionary // array of dictionaries
                
                self.print_action(string: "**** FKOrder: Order was sucessfully found! ****")
                
                // Init Case Object
                
                self.id = orderID
                self.orderDateTime = orderData!["orderDateTime"] as! String
                self.orderStage = orderData!["orderStage"] as! String
                self.orderPaymentMethod = orderData!["orderPaymentMethod"] as! String
                self.orderTotalPrice = Double(orderData!["orderTotalPrice"] as! String)!
                self.customerPhoneNumber = orderData!["customerPhoneNumber"] as! String
                self.supplierID = orderData!["supplierID"] as! String
                
                self.print_action(string: "**** FKOrder: Order Object Initialized****")
                
                // Fetch Order Items for Orders
               self.observeSingleFetchAllOrderItemsForOrderFromFirebaseDB()
                
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE), object: nil)
                
            }
 
        })
        
    }
    
    // (D) Observe/Single Fetch Order From Firebase Real-time Database
    func observeSingleFetchOrderFromFirebaseDB(){
        
        // Call Observe on Reference
        let ref = Database.database().reference().child("FKOrder").queryOrdered(byChild:"id").queryEqual(toValue: id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKOrder: Order was not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let orderID = postDict?.allKeys.first as! String
                
                // Get Item Data
                let orderData = postDict?[orderID] as? NSDictionary // array of dictionaries
                
                self.print_action(string: "**** FKOrder: Order was sucessfully found! ****")
                
                // Init Case Object
                
                self.id = orderID
                self.orderDateTime = orderData!["orderDateTime"] as! String
                self.orderStage = orderData!["orderStage"] as! String
                self.orderPaymentMethod = orderData!["orderPaymentMethod"] as! String
                self.orderTotalPrice = Double(orderData!["orderTotalPrice"] as! String)!
                self.customerPhoneNumber = orderData!["customerPhoneNumber"] as! String
                self.supplierID = orderData!["supplierID"] as! String
                
                self.print_action(string: "**** FKOrder: Order Object Initialized****")
                
                // Fetch Order Items for Orders
                self.observeSingleFetchAllOrderItemsForOrderFromFirebaseDB()
                
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE), object: nil)
                
            }
            
        })
    }
    
    // (E) Observe/Fetch All Order Items for Order From Real-time Database
    func observeFetchAllOrderItemsForOrderFromFireBaseDB(){
        _ = Database.database().reference().child("FKOrderItem").queryOrdered(byChild:"orderID").queryEqual(toValue: self.id).observe(DataEventType.value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKOrder: Order Items were not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                for child in snapshot.children.allObjects as! [DataSnapshot]  {
                    
                    // Create FKMenuItem
                    let orderItem = FKOrderItem()
                    
                    // Parse Data to new Item
                    let orderItemData = child.value as? NSDictionary
                    let orderID = postDict?.allKeys.first as! String
                    
                    self.print_action(string: "**** FKOrderItem: items sucessfully found! ****")
                    
                    // Init Order Item Object
                    
                    orderItem.id = orderID
                    orderItem.itemName_en = orderItemData!["itemName_en"] as! String
                    orderItem.itemName_ar = orderItemData!["itemName_ar"] as! String
                    orderItem.itemPrice = Double(orderItemData!["itemPrice"] as! String)!
                    orderItem.instructions = orderItemData!["instructions"] as! String
                    orderItem.quantity = Int(orderItemData!["quantity"] as! String)!
                   
                    
                    self.orderItems.append(orderItem)
                    
                    self.print_action(string: "**** FKOrder: Order Item Object Initialized****")
                    
                }
                
                // Print Order Items
                self.print_order_items()
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCHED_ITEMS), object: nil)
                
            }
            
            
            
        })
    }
    
    // (F) Observe/Single Fetch All Order Items for Order From Real-time Database
    func observeSingleFetchAllOrderItemsForOrderFromFirebaseDB(){
        let ref = Database.database().reference().child("FKOrderItem").queryOrdered(byChild:"orderID").queryEqual(toValue: self.id)
            
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKOrder: Order Items were not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                for child in snapshot.children.allObjects as! [DataSnapshot]  {
                    
                    // Create FKMenuItem
                    let orderItem = FKOrderItem()
                    
                    // Parse Data to new Item
                    let orderItemData = child.value as? NSDictionary
                    let orderID = postDict?.allKeys.first as! String
                    
                    self.print_action(string: "**** FKOrderItem: items sucessfully found! ****")
                    
                    // Init Order Item Object
                    
                    orderItem.id = orderID
                    orderItem.itemName_en = orderItemData!["itemName_en"] as! String
                    orderItem.itemName_ar = orderItemData!["itemName_ar"] as! String
                    orderItem.itemPrice = Double(orderItemData!["itemPrice"] as! String)!
                    orderItem.instructions = orderItemData!["instructions"] as! String
                    orderItem.quantity = Int(orderItemData!["quantity"] as! String)!
                    
                    
                    self.orderItems.append(orderItem)
                    
                    self.print_action(string: "**** FKOrder: Order Item Object Initialized****")
                    
                }
                
                // Print Order Items
                self.print_order_items()
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCHED_ITEMS), object: nil)
                
            }
            
            
            
        })
    }
    
    // (G) Update Order To Firebase Real-time Database
    func updateOrderToFireBaseDB(){
       
        print_action(string: "FKOrder: Order updating...")
        let ref  = Database.database().reference().child("FKOrder").child(self.id)
        
        ref.updateChildValues([
            "id" : self.id,
            "orderDateTime" : self.orderDateTime,
            "orderStage" : self.orderStage,
            "orderPaymentMethod" : self.orderPaymentMethod,
            "orderTotalPrice" : String(self.orderTotalPrice),
            "customerPhoneNumber" : self.customerPhoneNumber,
            "supplierID" : self.supplierID
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
        
        orderItem.setupOrderItem(itemName_en: item.itemName_en, itemName_ar: item.itemName_ar, itemPrice: item.itemPrice, quantity: quantity, instructions: instructions, dispatchID:  self.dispatchID, orderID: self.id)
       
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
            "supplierID" : self.supplierID
            ]
        
        print(order)
        print("******************************************\n")
    }
    
    // Print Order Items
    func print_order_items(){
        print_order()
        print("\n************* FKOrderItems Log *************")
        for orderItem in self.orderItems {
            let item = [
                "id" : orderItem.id,
                "itemName_en" : orderItem.itemName_en,
                "itemName_ar" : orderItem.itemName_ar,
                "itemPrice" : String(orderItem.itemPrice),
                "quantity" : String(orderItem.quantity),
                "instructions" : orderItem.instructions,
                "orderID" : orderItem.orderID
            ]
            print(item)
        }
        print("******************************************\n")

    }
    
}
