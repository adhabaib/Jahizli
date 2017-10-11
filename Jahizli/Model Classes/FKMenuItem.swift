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
    var itemPrice: Double = 0.0
    var itemCategory = "?"

    
    
    // public notification tags
    let NOTIFICATION_UPLOAD = "FKMenuItem_Single_Uploaded"
    let NOTIFICATION_OBSERVE_EMPTY = "FkMenuItem_Observe_Empty"
    let NOTIFICATION_OBSERVE = "FkMenuItem_Observe_Done"
    
    // Firebase Storage Methods
    func uploadImageToFireBaseStorage(){
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
       
        // Child references can also take paths delimited by '/'
        let itemImageRef = storageRef.child("FKMenuItemimages/\(self.id).jpeg")
  
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
            print("\n*** FKMenuItem: Image upload progress -> \(snapshot.progress!.fractionCompleted) ***\n")
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
    
    // (B) Observe/Constant Fetch FKMenuItem Data
    func observeFetchItem(id: String){
        
        // Call Observe on Reference
        _ = Database.database().reference().child("FKMenuItem").queryOrdered(byChild:"id").queryEqual(toValue: id).observe(DataEventType.value, with: { (snapshot) in
          
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Case Found Return Failed to Find
            if(postDict == nil){
                print("\n*** FKMenuItem: Item was not found/empty. ***\n")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let itemId = postDict?.allKeys.first as! String
                
                // Get Item Data
                let itemData = postDict?[itemId] as? NSDictionary // array of dictionaries
                
                print("\n*** FKMenuItem: item sucessfully found! ***\n")
                
                // Init Case Object
                self.id = itemId
                self.itemName_en = itemData!["itemName_en"] as! String
                self.itemName_ar = itemData!["itemName_ar"] as! String
                self.itemInfo_ar  = itemData!["itemInfo_ar"] as! String
                self.itemInfo_en = itemData!["itemInfo_en"] as! String
                self.itemPrice = Double(itemData!["itemPrice"] as! String)!
                self.itemCategory = itemData!["itemCategory"] as! String
               
                print("\t*** FKMenuItem: item Object Initialized***\n")
                
                // Print Out Item
                self.print_item()
                
              
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE), object: nil)
                
            }
            
            
            
        })
        
        
        
        
    }
    
    
    // (C) Single Observe fetch of item data
    func observeSingleFetchItem(id: String){
        
        // Call Observe on Reference
        let ref = Database.database().reference().child("FKMenuItem").queryOrdered(byChild:"id").queryEqual(toValue: id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Case Found Return Failed to Find
            if(postDict == nil){
                print("\n*** FKMenuItem: Item was not found/empty. ***\n")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let itemId = postDict?.allKeys.first as! String
                
                // Get Item Data
                let itemData = postDict?[itemId] as? NSDictionary // array of dictionaries
                
                print("\n*** FKMenuItem: item sucessfully found! ***\n")
                
                // Init Case Object
                self.id = itemId
                self.itemName_en = itemData!["itemName_en"] as! String
                self.itemName_ar = itemData!["itemName_ar"] as! String
                self.itemInfo_ar  = itemData!["itemInfo_ar"] as! String
                self.itemInfo_en = itemData!["itemInfo_en"] as! String
                self.itemPrice = Double(itemData!["itemPrice"] as! String)!
                self.itemCategory = itemData!["itemCategory"] as! String
                
                print("\t*** FKMenuItem: item Object Initialized***\n")
                
                // Print Out Item
                self.print_item()
                
                
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE), object: nil)
                
            }
            
            
            
        })
        
        
        
        
        
    }
    
    
    // (D) Remove All Attached Observers to Item
    func removeItemObserver(){
        
        Database.database().reference().child("FKMenuItem").removeAllObservers()
        
    }
    
    
    
    // Helper Methods
    
    func print_item(){
        
        print("/n*** FKMenuItem: itemCategory:\(self.itemCategory)")
        
    }
    
    
    
    
}
