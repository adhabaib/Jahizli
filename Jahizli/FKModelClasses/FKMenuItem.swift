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
    let NOTIFICATION_OBSERVE_EMPTY = "FKMenuItem_Observe_Empty"
    let NOTIFICATION_OBSERVE = "FKMenuItem_Observe_Done"
    let NOTIFICATION_IMG_UPLOAD = "FKMenuItem_Image_Uploaded"
    let NOTIFICATION_IMG_DOWN = "FKMenuItem_Image_Downloaded"
    let NOTIFICATION_ITEM_UPDATED = "FKMenuItem_Updated"
    
    
    // Setup Object Function
    func setupItem(itemName_en: String, itemName_ar: String, itemInfo_en: String, itemInfo_ar: String, itemImage: Data!, itemPrice: Double, itemCategory: String){
        
        self.itemName_en = itemName_en
        self.itemName_ar = itemName_ar
        self.itemInfo_en = itemInfo_en
        self.itemInfo_ar = itemInfo_ar
        self.itemImage = itemImage
        self.itemPrice = itemPrice
        self.itemCategory = itemCategory
        
        self.uploadItemToFirebaseDB()
        
        
        
    }
    
    
    // Firebase Storage Methods
    // (A) Upload Item Image to FireBase Storage
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
                self.print_action(string: "**** FKMenuItem: Failed to upload meta data ****")
                return
            }
        }
        
        // Add a progress observer to an upload task
        _ = uploadTask.observe(.progress) { snapshot in
            // A progress event occured
            self.print_action(string: "**** FKMenuItem: Image upload progress -> \(snapshot.progress!.fractionCompleted) ****")
            if(snapshot.progress!.fractionCompleted == 1.0){
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_IMG_UPLOAD), object: nil)
                    self.print_item()
                }
            }
            
        }
        
    }
    
    //(B) Fetching Item Image from Firebase Storage
    func fetchImageFromFirebaseStorage(id: String){
       
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Create a reference to the file you want to download
        let itemRef = storageRef.child("FKMenuItemimages/\(id).jpeg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        itemRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                self.print_action(string: "**** FKMenuItem: Item Image could not be found/fetched!")
                
            } else {
                // Data for "images/island.jpg" is returned
                self.print_action(string: "**** FKMenuItem: Item Image found/fetched!")
                self.itemImage = data!
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_IMG_DOWN), object: nil)
                    self.print_item()
                }
            }
            
           
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
            
            self.print_action(string: "**** FKMenuItem: item uploaded to Firebase Realtime-Database! ****")
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOAD), object: nil)
                self.uploadImageToFireBaseStorage()
            }

        })
        
        
    }
    
    // (B) Observe/Constant Fetch FKMenuItem Data
    func observeFetchItemFromFirebaseDB(id: String){
        
        // Call Observe on Reference
        _ = Database.database().reference().child("FKMenuItem").queryOrdered(byChild:"id").queryEqual(toValue: id).observe(DataEventType.value, with: { (snapshot) in
          
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKMenuItem: Item was not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let itemId = postDict?.allKeys.first as! String
                
                // Get Item Data
                let itemData = postDict?[itemId] as? NSDictionary // array of dictionaries
                
                self.print_action(string: "**** FKMenuItem: item sucessfully found! ****")
                
                // Init Case Object
                self.id = itemId
                self.itemName_en = itemData!["itemName_en"] as! String
                self.itemName_ar = itemData!["itemName_ar"] as! String
                self.itemInfo_ar  = itemData!["itemInfo_ar"] as! String
                self.itemInfo_en = itemData!["itemInfo_en"] as! String
                self.itemPrice = Double(itemData!["itemPrice"] as! String)!
                self.itemCategory = itemData!["itemCategory"] as! String
               
                self.print_action(string: "**** FKMenuItem: item Object Initialized****")
                
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
    func observeSingleFetchItemFromFirebaseDB(id: String){
        
        // Call Observe on Reference
        let ref = Database.database().reference().child("FKMenuItem").queryOrdered(byChild:"id").queryEqual(toValue: id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKMenuItem: Item was not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let itemId = postDict?.allKeys.first as! String
                
                // Get Item Data
                let itemData = postDict?[itemId] as? NSDictionary // array of dictionaries
                
                self.print_action(string: "**** FKMenuItem: item sucessfully found! ****")
                
                // Init Case Object
                self.id = itemId
                self.itemName_en = itemData!["itemName_en"] as! String
                self.itemName_ar = itemData!["itemName_ar"] as! String
                self.itemInfo_ar  = itemData!["itemInfo_ar"] as! String
                self.itemInfo_en = itemData!["itemInfo_en"] as! String
                self.itemPrice = Double(itemData!["itemPrice"] as! String)!
                self.itemCategory = itemData!["itemCategory"] as! String
                
                self.print_action(string: "**** FKMenuItem: item Object Initialized****")
                
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
    
    // (E) Remove Object From Firebase
    func removeItemFromFirebaseDB(){
          Database.database().reference().child("FKMenuItem").child(self.id)
    }
    
    // (F) Update MenuItem to Firebase
    func updateItemToFirebaseDB(){
        
        print_action(string: "FKMenuItem: Item updating...")
        let ref  = Database.database().reference().child("FKMenuItem").child(self.id)
        
        ref.updateChildValues([
            "id" : self.id,
            "itemName_en" : self.itemName_en,
            "itemName_ar" : self.itemName_ar,
            "itemInfo_en" : self.itemInfo_en,
            "itemInfo_ar" : self.itemInfo_ar,
            "itemPrice" : String(self.itemPrice),
            "itemCategory" : self.itemCategory
            ], withCompletionBlock: { (NSError, FIRDatabaseReference) in //update the book in the db
                
                // POST NOTIFICATION FOR COMPLETION
                self.print_item()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_ITEM_UPDATED), object: nil)
                }
                
        })
        
   
    }

    
    // Helper Methods
    
    func print_item(){
         print("\n************* FKMenuItem Log *************")
        let item = [
            "id" : self.id,
            "itemName_en" : self.itemName_en,
            "itemName_ar" : self.itemName_ar,
            "itemInfo_en" : self.itemInfo_en,
            "itemInfo_ar" : self.itemInfo_ar,
            "itemPrice" : String(self.itemPrice),
            "itemCategory" : self.itemCategory
        ]
        
        print("**** FKMenuItem:*")
        print(item)
        print("****")
        print("*******************************************\n")
        
    }
    
    
    func print_action(string: String){
        print("\n************* FKMenuItem Log *************")
        print(string)
        print("******************************************\n")
        
    }
    
    
    
}
