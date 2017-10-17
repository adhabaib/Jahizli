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
    let NOTIFICATION_FETCHED = "FKSupplierDispatch_Fetched_In_Progress_Orders"
    
    
    //MARK:  Initializer Method
    func setupSupplierDisptach(supplierID: String){
        self.supplierID = supplierID
    }

    // MARK: Firebase Real-time Functions
    
    // (A) Fetch Supplier Dispatch From Firebase
    
    // (B) Remove Supplier Dispatch From Firebase
    
    // (C) Update Supplier Dispatch To Firebase
    
    // (D) Update Supplier Status
    
    // (E) Observe/ Fetch All Pending Orders From Firebase
    
    // (F) Observe/ Single Fetch All Pending Orders From Firebase
    
    
    // MARK:  Firebase Messenging Functions
    
    
    

    // MARK: Logical Functions
    // (A) Update Order Status
    
    // (B) Complete Order
    
    // (C) Cancel Order
    
    //MARK: Helper Functions
    
    
}
