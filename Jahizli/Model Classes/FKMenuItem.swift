//
//  FKMenuItem.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/9/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import Foundation
import Firebase

// FKMenuItem Class
class FKMenuItem: NSObject {
    
    // public variables
    var id = "?"
    var itemName_en = "?"
    var itemName_ar = "?"
    var itemInfo_en = "?"
    var itemInfo_ar = "?"
    var itemImage : Data!
    var itemPrice = 0.0
    var itemCategory = "?"

    
    
    // public notification tags
    let NOTIFICATION_UPLOAD = "FKMenuItem_Single_Uploaded"
    
    
    
    
    // Firebase Methods
    
    // (A) Uploading Single FKMenuItem to Real-time Database
    func uploadItemToFirebase(){
        
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let itemRef = ref.child("FKMenuItem").childByAutoId()
        self.id = itemRef.key
        
        // Setup JSON Object
        let item = [
            "id" : self.id,
            "itemName_en" : self.itemName_en,
            "itemName_ar" : self.itemName_ar,
            "itemInfo_en" : self.itemInfo_en,
            "itemInfo_ar" : self.itemInfo_ar,
            "itemImage" : "IMG" ,
            "itemPrice" : String(self.itemPrice),
            "itemCategory" : self.itemCategory
        ]
        
        
        // Save Object to Real-time Database
        
        itemRef.setValue(item,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            print("\n*** FKMenuItem: item uploaded to Firebase Realtime-Database! ***\n")
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOAD), object: nil)
            }

        })
        
        
    }
    
    
    
    
    
    
    
    
    
    // Helper Methods
    
    
    
    
    
    
}
