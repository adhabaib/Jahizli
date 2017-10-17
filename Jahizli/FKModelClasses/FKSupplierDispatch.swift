//
//  FKSupplierDispatch.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/17/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import Foundation
import Firebase

//FKSupplierDispatch Class
class FKSupplierDispatch : NSObject {
    
    //MARK:  public variables
    var id : String = ""
    var supplierID: String = ""
    
    var incompletedOrders = [FKOrder]()
    var completedOrders = [FKOrder]()
    
    //MARK:  notification tags
    let NOTIFICATION_UPLOADED = "FKSupplierDispatch_Uploaded"
    let NOTIFICATION_FETCHED = "FKSupplierDispatch_Fetched"
    let NOTIFICATION_OBSERVE_EMPTY = "FKSupplier_Fetch_Empty"
    let NOTIFICATION_UPDATED = "FKSupplierDispatch_Updated"
    let NOTIFICATION_FETCHED_ORDERS = "FKSupplierDispatch_Fetched_In_Progress_Orders"
    let NOTIFICATION_UPDATED_ORDER = "FKSupplierDispatch_Updated_In_Progress_Orders"
    let NOTIFICATION_OBSERVE_ORDERS_EMPTY = "FKSupplier_Fetch_Orders_Empty"
    
    //MARK:  Initializer Method
    func setupSupplierDisptach(supplierID: String){
        self.supplierID = supplierID
    }

    // MARK: Firebase Real-time Functions
    
    // (A) Upload SupplierDispatch To Firebase
    func uploadSupplierDispatchToFireBaseDB(){
        
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let dispatchRef = ref.child("FKSupplierDispatch").childByAutoId()
        self.id = dispatchRef.key
        
        // Setup JSON Object
        let dispatch = [
            "id" : self.id,
            "supplierID" : self.supplierID
        ]
        
        // Save Object to Real-time Database
        
        dispatchRef.setValue(dispatch,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            self.print_action(string: "**** FKSupplierDispatch: Supplier Dispatch uploaded to Firebase Realtime-Database! ****")
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOADED), object: nil)
            }
            
        })
    }
    
    // (B) Fetch Supplier Dispatch From Firebase
    func observeSingleFetchSupplierDispatchFromFireBaseDB(){
        // Call Observe on Reference
        let ref = Database.database().reference().child("FKSupplierDispatch").queryOrdered(byChild:"id").queryEqual(toValue: id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKSupplierDispatch: dispatch was not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let dispatchID = postDict?.allKeys.first as! String
                
                // Get Dispatch Data
                let dispatchData = postDict?[dispatchID] as? NSDictionary // array of dictionaries
                
                self.print_action(string: "**** FKSupplierDispatch: dispatch sucessfully found! ****")
                
                // Init Case Object
                self.id = dispatchID
                self.supplierID = dispatchData!["supplierID"] as! String

                self.print_action(string: "**** FKSupplierDispatch: dispatch Object Initialized****")
                
                // -> Print Dispath Info
                
                // -> Fetch All Pending Orders
                
                
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCHED), object: nil)
                
            }
        })
    }
    
    // (C) Remove Supplier Dispatch From Firebase
    func removeSupplierDispatchFromFireBaseDB(){
         Database.database().reference().child("FKSupplierDispatch").child(self.id).removeValue()
    }
    
    // (D) Update Supplier Dispatch To Firebase
    func updateSupplierDispatchToFireBaseDB(){
        print_action(string: "FKSupplierDispatch: dispatch updating...")
        let ref  = Database.database().reference().child("FKSupplierDispatch").child(self.id)
        
        ref.updateChildValues([
            "id" : self.id,
            "supplierID" : self.supplierID
            ], withCompletionBlock: { (NSError, FIRDatabaseReference) in //update the book in the db
                
                // POST NOTIFICATION FOR COMPLETION
                // -> Print SupplierDispatch
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPDATED), object: nil)
                }
                
        })
        
    }
    
    // (E) Update Supplier Status
    func updateSupplierStatus(status: String){
        print_action(string: "FKSupplierDispatch: SUPPLIER STATUS updating...")
        let ref  = Database.database().reference().child("FKSupplier").child(self.supplierID).child("status")
        
        ref.updateChildValues([
            "status" : status
            ], withCompletionBlock: { (NSError, FIRDatabaseReference) in //update the book in the db
                
                // POST NOTIFICATION FOR COMPLETION
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPDATED), object: nil)
                }
                
        })
    }
    
    // (F) Observe/ Fetch All Pending Orders From Firebase
    func observeFetchAllPendingOrdersFromFireBaseDB(){
        // Call Observe on Reference
        let ref = Database.database().reference().child("FKOrder").queryOrdered(byChild:"supplierID").queryEqual(toValue: self.supplierID)
            ref.observe(DataEventType.value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKSupplierDispatch: Orders were not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_ORDERS_EMPTY), object: nil)
                }
                
            }
            else{
                for child in snapshot.children.allObjects as! [DataSnapshot]  {
                    
                    // Create FKOrder
                    let order = FKOrder()
                    
                    // Parse Data to new Item
                    let orderData = child.value as? NSDictionary
                    let orderID = postDict?.allKeys.first as! String
                    
                    self.print_action(string: "**** FKSupplierDispatch: orders sucessfully found! ****")
                    
                    // Init Case Object
                    order.id = orderID
                    order.orderDateTime = orderData!["orderDateTime"] as! String
                    order.orderStage = orderData!["orderStage"] as! String
                    order.orderPaymentMethod = orderData!["orderPaymentMethod"] as! String
                    order.orderTotalPrice = Double(orderData!["orderTotalPrice"] as! String)!
                    order.customerPhoneNumber = orderData!["customerPhoneNumber"] as! String
                    order.supplierID = orderData!["supplierID"] as! String
                    
                    
                    self.incompletedOrders.append(order)
                    
                    self.print_action(string: "**** FKSupplierDisaptch: Order Object Initialized****")
                    
                }
                
                // -> Print All Orders
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCHED_ORDERS), object: nil)
                
            }
        })
    }
    
    // (G) Observe/ Single Fetch All Pending Orders From Firebase
    
    
    // MARK:  Firebase Messenging Functions
    
    
    

    // MARK: Logical Functions
    // (A) Update Order Status
    
    // (B) Complete Order
    
    // (C) Cancel Order
    
    //MARK: Helper Functions
    func print_action(string: String){
        print("\n************* FKSupplierDispatch Log *************")
        print(string)
        print("******************************************\n")
        
    }
    
    
}
