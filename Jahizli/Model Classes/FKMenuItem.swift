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
    
    // Firebase Storage Methods
    func uploadImageToFireBaseStorage(){
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
       
        // Child references can also take paths delimited by '/'
        let itemImageRef = storageRef.child("FKMenuItemimages/\(self.id).png")
  
        // Upload the file to the path
        let uploadTask = itemImageRef.putData(self.itemImage, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("\n*** FKMenuItem: Failed to upload meta data ***\n")
                return
            }
        }
        
        // Add a progress observer to an upload task
        _ = uploadTask.observe(.progress) { snapshot in
            // A progress event occured
            print("PROGRESS")
           // print("\n*** FKMenuitem: Uploading ItemImage (\(progress_string)) ***\n")
            
        }
        
    }
  
    
    // Firebase Realtime-Database Methods
    // (A) Uploading Single FKMenuItem to Real-time Database
    func uploadItemToFirebaseDB(){
        
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
