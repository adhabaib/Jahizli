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
    var country: String = ""
    
    var incompletedOrders = [FKOrder]()
    var completedOrders = [FKOrder]()
    
    var unprocessedOrders = [[FKOrder]]()
    var unprocessedDates = [String]()
    
    
    var player: AVAudioPlayer?
    
    //MARK:  notification tags
    let NOTIFICATION_UPLOADED = "FKSupplierDispatch_Uploaded"
    let NOTIFICATION_UPDATED = "FKSupplierDispatch_Updated"
    let NOTIFICATION_UPDATED_SUPPLIER = "FKSupplierDispatch_Updated_FKSupplier_Status"
    let NOTIFICATION_FETCHED_ORDERS = "FKSupplierDispatch_Fetched_In_Progress_Orders"
    let NOTIFICATION_FETCHED_ORDERS_UNPROCESSED = "FKSupplierDispatch_Fetched_In_Progress_Orders_UNPROCESSED"
    let NOTIFICATION_UPDATED_ORDER = "FKSupplierDispatch_Updated_In_Progress_Orders"
    let NOTIFICATION_OBSERVE_ORDERS_EMPTY = "FKSupplier_Fetch_Orders_Empty"
    
    //MARK:  Initializer Method
    func setupSupplierDisptach(supplierID: String, country: String){
        self.supplierID = supplierID
        self.country = country
        self.uploadSupplierDispatchToFireBaseDB()
    }
    
    // MARK: Firebase Real-time Functions
    
    // (A) Upload SupplierDispatch To Firebase
    func uploadSupplierDispatchToFireBaseDB(){
        
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let dispatchRef = ref.child(self.country).child("FKSupplierDispatches").childByAutoId()
        self.id = dispatchRef.key
        
        // Setup JSON Object
        let dispatch = [
            "id" : self.id,
            "supplierID" : self.supplierID,
            "country" : self.country
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
        Database.database().reference().child(self.country).child("FKSupplierDispatches").child(self.id).removeValue()
    }
    
    // (C) Update Supplier Dispatch To Firebase
    func updateSupplierDispatchToFireBaseDB(){
        print_action(string: "FKSupplierDispatch: dispatch updating...")
        let ref  = Database.database().reference().child(self.country).child("FKSupplierDispatches").child(self.id)
        
        ref.updateChildValues([
            "id" : self.id,
            "supplierID" : self.supplierID,
            "country" : self.country
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
        let ref  = Database.database().reference().child(self.country).child("FKSuppliers").child(self.supplierID).child("status")
        
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
        let ref = Database.database().reference().child(self.country).child("FKSupplierDispatches").child(self.id).child("FKOrdersWaiting")
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
                        else if(grandchild.key == "customerFCMToken"){
                            order.customerFCMToken = grandchild.value as! String
                        }
                        else if(grandchild.key == "country"){
                            order.country = grandchild.value as! String
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
                                orderItem.country = orderItemData!["country"] as! String
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
    
    
    
    //(E) Observe/ Fetch All Pending Orders From Firebase
    func observeFetchAllUnProcessedOrdersFromFireBaseDB(){
        
        // Call Observe on Reference
        let ref = Database.database().reference().child(self.country).child("FKSupplierDispatches").child(self.id).child("FKOrdersUnProcessed")
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
                
                // Refresh Unprocessed Arrays
                self.unprocessedDates.removeAll()
                self.unprocessedOrders.removeAll()
                
                for child in snapshot.children.allObjects as! [DataSnapshot]  {
                    
                    // Get Date
                    let current_date = child.key
                    self.unprocessedDates.append(current_date)
                    
                    self.print_action(string: "Unprocessed Orders for date: \(current_date)")
                    
                    var current_orders = [FKOrder]()
                    
                    for grand in child.children.allObjects as! [DataSnapshot] {
                        
                        let order = FKOrder()
                        
                        for grandchild in grand.children.allObjects as! [DataSnapshot] {
                            
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
                            else if(grandchild.key == "customerFCMToken"){
                                order.customerFCMToken = grandchild.value as! String
                            }
                            else if(grandchild.key == "country"){
                                order.country = grandchild.value as! String
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
                                    orderItem.country = orderItemData!["country"] as! String
                                    orderItem.dispatchID = self.id
                                    orderItem.orderID = order.id
                                    
                                    order.orderItems.append(orderItem)
                                    
                                    self.print_action(string: "**** FKSupplierDispatch: Order Item Object Initialized****")
                                    
                                    
                                }
                            }
                            
                        }
                        
                        
                        current_orders.append(order)
                        
                    }
                    
                    self.unprocessedOrders.append(current_orders)
                    current_orders.removeAll()
                    
                }
                
            }
            
            
            self.print_unprocessed_orders()
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCHED_ORDERS_UNPROCESSED), object: nil)
                
            }
        })
    }
    
    
    // (F) Observe Fetch All Processed Orders From Firebase Database by Date
    
    func observeFetchProcessedOrdersFor(date: String){
        
        // Call Observe on Reference
        let ref = Database.database().reference().child(self.country).child("FKSupplierDispatches").child(self.id).child("FKOrdersProcessed").child(date)
        
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
                self.completedOrders.removeAll()
                
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
                        else if(grandchild.key == "customerFCMToken"){
                            order.customerFCMToken = grandchild.value as! String
                        }
                        else if(grandchild.key == "country"){
                            order.country = grandchild.value as! String
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
                                orderItem.country = orderItemData!["country"] as! String
                                orderItem.dispatchID = self.id
                                orderItem.orderID = order.id
                                
                                order.orderItems.append(orderItem)
                                
                                self.print_action(string: "**** FKSupplierDispatch: Order Item Object Initialized****")
                                
                                
                            }
                            
                            
                            
                        }
                        
                        
                    }
                    
                    
                    self.completedOrders.append(order)
                    
                    
                }
                
            }
            
       
            self.print_complete_orders()
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCHED_ORDERS), object: nil)
                
            }
        })
        
        
        
        
    }
    
    
    // MARK:  Firebase Messenging Functions
    
    //(A) HTTP POST TO FIREBASE SERVER
    func sendFireBaseNotification(deviceToken: String, message: String){
        
        print("FKSupplierDispatch: Token recieved \(deviceToken)")
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAADuRmp-o:APA91bE-LOJp8XDHG1CdSHdqQDbim4jrPkUUnq3Y6nJsSoAVqJNirdnqkSgZiB7msA19moI0_MT2UhVuYErg4bOjn5N-rA5CL9Apygg7gZt2ddj_4fR6ywnEljo60ZIuCFwHEvNzkxbr", forHTTPHeaderField:"Authorization")
        request.httpMethod = "POST"
        
        // prepare json data
        let json: [String: Any] = [
            
            "to" : deviceToken,
            "priority": "high",
            "notification" :
                [ "title": "Jahezli",
                  "body": message,
                  "sound": "default"]
            
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        
        
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                //Retry Sending...
                self.sendFireBaseNotification(deviceToken: deviceToken, message: message)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                //Retry Sending...
                self.sendFireBaseNotification(deviceToken: deviceToken, message: message)
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    
    //(B) Send Notification To Specific Order Holder
    func notifyCustomerForOrder(order: FKOrder, msg: String){
        self.sendFireBaseNotification(deviceToken: order.customerFCMToken, message: msg)
    }
    
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
    
    
    
    // (E) Process All Unprocessed order
    func processAllOrdersToFireBaseDB(){
        
        self.unprocessedDates.removeAll()
        for order_tray in self.unprocessedOrders{
            for order in order_tray{
                order.uploadProcessedOrderToFirebaseDB()
            }
        }
        self.unprocessedOrders.removeAll()
        
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
    
    func print_complete_orders(){
        print("\n\n****************************************** FKSupplierDispatch Completed Orders ****************************************** ")
        print("PENDING ORDER COUNT COUNT: \(self.completedOrders.count)\n")
        for order in self.completedOrders {
            order.print_order_items()
        }
        print("*************************************************************************************************************************\n\n")
    }
    
    func print_unprocessed_orders(){
        print("\n\n****************************************** FKSupplierDispatch Completed Orders ****************************************** ")
        
        var count = 0
        for order_tray in self.unprocessedOrders{
            count = count + order_tray.count
        }
        
        print("UNPROCESSED ORDER COUNT: \(count)\n")
        
        
        var day_index = 0
        
        for day in self.unprocessedDates {
            
            print("DAY : \(day)")
            
            for order in self.unprocessedOrders[day_index] {
                
                order.print_order_items()
                
            }
            
            day_index = day_index + 1
        }
        print("*************************************************************************************************************************\n\n")
    }
    
    
    func getCashBalance() -> Double{
        
        var cashBalance = 0.0
        var date_index = 0
        
        for _ in self.unprocessedDates {
            for order in self.unprocessedOrders[date_index]{
                if(order.orderPaymentMethod == "CASH"){
                    cashBalance = cashBalance + order.orderTotalPrice
                }
            }
            date_index = date_index + 1
        }
        
        return cashBalance
    }
    
    func getKNETBalance() -> Double{
        
        var knetBalance = 0.0
        var date_index = 0
        
        for _ in self.unprocessedDates {
            for order in self.unprocessedOrders[date_index]{
                if(order.orderPaymentMethod == "KNET"){
                    knetBalance = knetBalance + order.orderTotalPrice
                }
            }
            date_index = date_index + 1
        }
        
        return knetBalance
    }
    
    func getTotalBalance() -> Double {
        return self.getCashBalance() + self.getKNETBalance()
    }
    
    func getTotalNet(creditRate: Double, fixedRate: Double) -> Double {
        
        if(fixedRate == 0.0){
            let rev = self.getTotalBalance() * creditRate
            let net = self.getKNETBalance() - rev
            return net
        }
        else{
            var count = 0
            for order_tray in self.unprocessedOrders{
                count = count + order_tray.count
            }
            let rev = fixedRate * Double(count)
            let net = self.getKNETBalance() - rev
            return net
        }
    }
    
    
    
    func getCashBalanceForDay(date: String) -> Double{
        
        var cashBalance = 0.0
        var date_index = 0
        
        for day in self.unprocessedDates {
            if(day == date){
                for order in self.unprocessedOrders[date_index]{
                    if(order.orderPaymentMethod == "CASH"){
                        cashBalance = cashBalance + order.orderTotalPrice
                    }
                }
            }
            date_index = date_index + 1
        }
        
        return cashBalance
    }
    
    func getKNETBalanceForDay(date: String) -> Double{
        
        var knetBalance = 0.0
        var date_index = 0
        
        for day in self.unprocessedDates {
            if(day == date){
            for order in self.unprocessedOrders[date_index]{
                if(order.orderPaymentMethod == "KNET"){
                    knetBalance = knetBalance + order.orderTotalPrice
                }
            }
            }
            date_index = date_index + 1
        }
        
        return knetBalance
    }
    
    func getTotalBalanceForDay(date: String) -> Double {
        return self.getCashBalanceForDay(date: date) + self.getKNETBalanceForDay(date: date)
    }
    
    func getTotalNetForDay(creditRate: Double, fixedRate: Double, date: String) -> Double {
        
        if(fixedRate == 0.0){
            let rev = self.getTotalBalanceForDay(date:date) * creditRate
            let net = self.getKNETBalanceForDay(date:date) - rev
            return net
        }
        else{
            var count = 0
            var index = 0
            for day in self.unprocessedDates{
                if day == date {
                    count = self.unprocessedOrders[index].count
                }
                index = index + 1
            }
            let rev = fixedRate * Double(count)
            let net = self.getKNETBalanceForDay(date:date) - rev
            return net
        }
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
