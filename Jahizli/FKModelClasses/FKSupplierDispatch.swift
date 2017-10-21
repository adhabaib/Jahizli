//
//  FKSupplierDispatch.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/17/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import Foundation
import Firebase
import AudioToolbox
import AVFoundation

//FKSupplierDispatch Class
class FKSupplierDispatch : NSObject {
    
    //MARK:  public variables
    var id : String = ""
    var supplierID: String = ""
    
    var incompletedOrders = [FKOrder]()
    var completedOrders = [FKOrder]()
    
    var player: AVAudioPlayer?
    
    //MARK:  notification tags
    let NOTIFICATION_UPLOADED = "FKSupplierDispatch_Uploaded"
    let NOTIFICATION_UPDATED = "FKSupplierDispatch_Updated"
    let NOTIFICATION_UPDATED_SUPPLIER = "FKSupplierDispatch_Updated_FKSupplier_Status"
    let NOTIFICATION_FETCHED_ORDERS = "FKSupplierDispatch_Fetched_In_Progress_Orders"
    let NOTIFICATION_UPDATED_ORDER = "FKSupplierDispatch_Updated_In_Progress_Orders"
    let NOTIFICATION_OBSERVE_ORDERS_EMPTY = "FKSupplier_Fetch_Orders_Empty"
    
    //MARK:  Initializer Method
    func setupSupplierDisptach(supplierID: String){
        self.supplierID = supplierID
        self.uploadSupplierDispatchToFireBaseDB()
    }
    
    // MARK: Firebase Real-time Functions
    
    // (A) Upload SupplierDispatch To Firebase
    func uploadSupplierDispatchToFireBaseDB(){
        
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let dispatchRef = ref.child("FKSupplierDispatches").childByAutoId()
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
    
    // (B) Remove Supplier Dispatch From Firebase
    func removeSupplierDispatchFromFireBaseDB(){
        Database.database().reference().child("FKSupplierDispatches").child(self.id).removeValue()
    }
    
    // (C) Update Supplier Dispatch To Firebase
    func updateSupplierDispatchToFireBaseDB(){
        print_action(string: "FKSupplierDispatch: dispatch updating...")
        let ref  = Database.database().reference().child("FKSupplierDispatches").child(self.id)
        
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
    
    // (D) Update Supplier Status
    func updateSupplierStatus(status: String){
        print_action(string: "FKSupplierDispatch: SUPPLIER STATUS updating...")
        let ref  = Database.database().reference().child("FKSupplier").child(self.supplierID).child("status")
        
        ref.updateChildValues([
            "status" : status
            ], withCompletionBlock: { (NSError, FIRDatabaseReference) in //update the book in the db
                
                // POST NOTIFICATION FOR COMPLETION
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPDATED_SUPPLIER), object: nil)
                }
                
        })
    }
    
    //(E) Observe/ Fetch All Pending Orders From Firebase
    func observeFetchAllPendingOrdersFromFireBaseDB(){
        
        var old_count = 0
        
        // Call Observe on Reference
        let ref = Database.database().reference().child("FKSupplierDispatches").child(self.id).child("FKOrdersWaiting")
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
                
                old_count = self.incompletedOrders.count
                self.incompletedOrders.removeAll()
                
                for child in snapshot.children.allObjects as! [DataSnapshot]  {
                    
                    // Create Order
                    self.print_action(string: "**** FKSupplierDispatch: order sucessfully found! ****")
                    let order = FKOrder()
                    
                    for grandchild in child.children.allObjects as! [DataSnapshot] {
                        
                        // Setup Order Object Fields
                        if(grandchild.key == "id"){
                            order.id = grandchild.value as! String
                            order.dispatchID = self.id
                        }
                        else if(grandchild.key == "orderDateTime"){
                            order.orderDateTime = grandchild.value as! String
                        }
                        else if(grandchild.key == "orderStage"){
                            order.orderStage = grandchild.value as! String
                        }
                        else if(grandchild.key == "orderPaymentMethod"){
                            order.orderPaymentMethod = grandchild.value as! String
                        }
                        else if(grandchild.key == "orderTotalPrice"){
                            order.orderTotalPrice = Double(grandchild.value as! String)!
                        }
                        else if(grandchild.key == "customerPhoneNumber"){
                            order.customerPhoneNumber = grandchild.value as! String
                        }
                        else if(grandchild.key == "supplierID"){
                            order.supplierID = grandchild.value as! String
                        }
                        else if(grandchild.key == "FKOrderItems"){
                            
                            for data in grandchild.children.allObjects as! [DataSnapshot] {
                                
                                self.print_action(string: "**** FKSupplierDispatch: items sucessfully found! ****")
                                
                                // Create FKMenuItem
                                let orderItem = FKOrderItem()
                                
                                // Parse Data to new Item
                                let orderItemData = data.value as? NSDictionary
                                
                                // Init Order Item Object
                                
                                orderItem.id =  orderItemData!["id"] as! String
                                orderItem.itemName_en = orderItemData!["itemName_en"] as! String
                                orderItem.itemName_ar = orderItemData!["itemName_ar"] as! String
                                orderItem.itemPrice = Double(orderItemData!["itemPrice"] as! String)!
                                orderItem.instructions = orderItemData!["instructions"] as! String
                                orderItem.quantity = Int(orderItemData!["quantity"] as! String)!
                                orderItem.dispatchID = self.id
                                orderItem.orderID = order.id
                                
                                order.orderItems.append(orderItem)
                                
                                self.print_action(string: "**** FKSupplierDispatch: Order Item Object Initialized****")
                                
                                
                            }
                            
                            
                            
                        }
                        
                        
                    }
                    
                    
                    self.incompletedOrders.append(order)
                    
                    
                }
                
            }
            
            self.normalizeOrderItems()
            self.play_alert(old_count: old_count, new_count: self.incompletedOrders.count)
            self.print_incomplete_orders()
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCHED_ORDERS), object: nil)
                
            }
        })
    }
    
    
    // MARK:  Firebase Messenging Functions
    
    
    
    // MARK: Logical Functions
    // (A) Update Order Status
    func updateOrderStatus(order: FKOrder, status: String){
        
        // Find order in incomplete list
        for e in self.incompletedOrders{
            if (e.id == order.id){
                e.orderStage = status
                e.updateIncompleteOrderToFireBaseDB()
            }
        }
        
        
    }
    
    // (B) Complete Order
    func completeOrder(order: FKOrder){
        
        // Find order in incomplete list
        var i = 0
        for e in self.incompletedOrders{
            if (e.id == order.id){
                e.orderStage = "COMPLETED"
                e.uploadCompletedOrderToFirebaseDB()
                self.completedOrders.append(e)
                self.incompletedOrders.remove(at: i)
                
            }
            i = i + 1
        }
        
    }
    
    // (C) Cancel Order
    func cancelOrder(order: FKOrder){
        // Find order in incomplete list
        var i = 0
        for e in self.incompletedOrders{
            if (e.id == order.id){
                e.orderStage = "CANCELLED"
                e.uploadAllCompletedOrderItemsToFireBaseDB()
                self.completedOrders.append(e)
                self.incompletedOrders.remove(at: i)
                
            }
            i = i + 1
        }
    }
    
    //MARK: Helper Functions
    
    func normalizeOrderItems(){
        for order in self.incompletedOrders{
            for item in order.orderItems{
                item.orderID = order.id
            }
            
        }
        
        self.incompletedOrders.reverse()
    }
    
    func play_alert(old_count: Int, new_count: Int){
        if(old_count < new_count){
            self.playSound()
        }
    }
    
    func print_action(string: String){
        print("\n************* FKSupplierDispatch Log *************")
        print(string)
        print("******************************************\n")
        
    }
    
    func print_incomplete_orders(){
        print("\n\n****************************************** FKSupplierDispatch Pending Orders ****************************************** ")
        print("PENDING ORDER COUNT COUNT: \(self.incompletedOrders.count)\n")
        for order in self.incompletedOrders {
            order.print_order_items()
        }
        print("*************************************************************************************************************************\n\n")
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "alert", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
}
