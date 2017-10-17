//
//  FKSupplier.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/15/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import Foundation
import Firebase

//FKSupplier Class
class FKSupplier: NSData {
    
    //MARK:  public variables
    var id : String = ""
    
    var name_en : String = ""
    var info_en : String = ""
    var name_ar : String = ""
    var info_ar : String = ""
    
    var hours: String = ""
    var status: String = ""
    var phoneNumber: String = ""
    var balance: Double = 0.0
    var creditRate: Double = 0.0
    var menu: FKMenu!
    
    var logo : Data!
    var displayImage : Data!
    
    var path: String = ""
    
    // notification tags
    let NOTIFICATION_UPLOAD = "FKSupplier_Basic_Info_Uploaded"
    let NOTIFICATION_IMG_UPLOAD = "FKSupplier_Image_Uploaded"
    let NOTIFICATION_FETCH = "FKSupplier_Basic_Info_Fetched"
    let NOTIFICATION_FETCH_EMPTY = "FKSupplier_Basic_Info_Fetched_Empty"
    let NOTIFICATION_IMG_DOWN = "FKSuppler_Image_Downloaded"
    let NOTIFICATION_UPDATED = "FKSupplier_Data_Updated"
    
    
    //MARK:  Initiliazer
    func setupSupplier(name_en: String, name_ar: String, status: String, hours: String, info_en : String, info_ar: String, phone_number: String, balance: Double, creditRate: Double, logo: Data!, displayImage: Data!, categories_en : [String], categories_ar: [String]){
        
        // Setup basic variables
        self.name_en = name_en
        self.name_ar = name_ar
        self.info_en = info_en
        self.info_ar = info_ar
        self.status  = status
        self.hours = hours
        self.phoneNumber = phone_number
        self.balance = balance
        self.creditRate = creditRate
        self.logo = logo
        self.displayImage = displayImage
        
        // Setup Menu
        self.menu = FKMenu()
        self.menu.setupMenu(categories_en: categories_en, categories_ar: categories_ar)
        
        // UploadData to Firebase Realtime Database
        self.uploadSupplierToFirebaseDB()
        
        
    }
    
    //MARK:  Firebase Storage Methods
    // (A) Upload Logo to Firebase Storage
    func uploadLogoImageToFirebaseStorage(){
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Child references can also take paths delimited by '/'
        let logoRef = storageRef.child("FKSuppliers/\(self.id)/Logo.jpeg")
        
        // Upload the file to the path
        let uploadTask = logoRef.putData(self.logo, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                self.print_action(string: "**** FKSupplier: Failed to upload meta data ****")
                return
            }
        }
        
        // Add a progress observer to an upload task
        _ = uploadTask.observe(.progress) { snapshot in
            // A progress event occured
            //self.print_action(string: "**** FKSupplier: Image upload progress -> \(snapshot.progress!.fractionCompleted) ****")
            if(snapshot.progress!.fractionCompleted == 1.0){
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_IMG_UPLOAD), object: nil)
                }
            }
            
        }
        
    }
    
    // (B) Upload Display Image to Firebase Storage
    func uploadDisplayImageToFirebaseStorage(){
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Child references can also take paths delimited by '/'
        let displayRef = storageRef.child("FKSuppliers/\(self.id)/Display.jpeg")
        
        // Upload the file to the path
        let uploadTask = displayRef.putData(self.displayImage, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                self.print_action(string: "**** FKSupplier: Failed to upload meta data ****")
                return
            }
        }
        
        // Add a progress observer to an upload task
        _ = uploadTask.observe(.progress) { snapshot in
            // A progress event occured
            //self.print_action(string: "**** FKSupplier: Image upload progress -> \(snapshot.progress!.fractionCompleted) ****")
            if(snapshot.progress!.fractionCompleted == 1.0){
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_IMG_UPLOAD), object: nil)
                }
            }
            
        }
        
    }
    
    // (C) Fetch Logo Image From Firebase Storage
    func fetchLogoImageFromFirebaseStorage(){
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Child references can also take paths delimited by '/'
        let logoRef = storageRef.child("FKSuppliers/\(self.id)/Logo.jpeg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        logoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                self.print_action(string: "**** FKSupplier: logo Image could not be found/fetched!")
                
            } else {
                // Data for "images/island.jpg" is returned
                self.print_action(string: "**** FKSuppler: logo Image found/fetched!")
                self.logo = data!
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_IMG_DOWN), object: nil)
                }
            }
            
        }
    }
    
    
    // (D) Fetch Display Image From Firebase Storeage
    func fetchDisplayImageFromFirebaseStorage(){
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Child references can also take paths delimited by '/'
        let displayRef = storageRef.child("FKSuppliers/\(self.id)/Display.jpeg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        displayRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                self.print_action(string: "**** FKSupplier: display Image could not be found/fetched!")
                
            } else {
                // Data for "images/island.jpg" is returned
                self.print_action(string: "**** FKSuppler: display Image found/fetched!")
                self.displayImage = data!
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_IMG_DOWN), object: nil)
                }
            }
            
        }
    }
    
    
    // (E) Delete Remove Logo Image From Firebase Storage
    func removeLogoImageFromFirebaseStorage(){
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Child references can also take paths delimited by '/'
        let logoRef = storageRef.child("FKSuppliers/\(self.id)/Logo.jpeg")
        
        // Delete the file
        logoRef.delete { error in
            if let error = error {
                self.print_action(string: "**** FKSupplier: Logo Image could not be found/fetched!")
            } else {
                self.print_action(string: "**** FKSupplier: Logo Image found/fetched and DELETED!")
            }
        }
    }
    
    // (F) Delete Remove Display Image From Firebase Storage
    func removeDisplayImageFromFirebaseStorage(){
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Child references can also take paths delimited by '/'
        let displayRef = storageRef.child("FKSuppliers/\(self.id)/Display.jpeg")
        
        // Delete the file
        displayRef.delete { error in
            if let error = error {
                self.print_action(string: "**** FKSupplier: Display Image could not be found/fetched!")
            } else {
                self.print_action(string: "**** FKSupplier: Display Image found/fetched and DELETED!")
            }
        }
    }
    
    
    //MARK:  Firebase Real-time Methods
    // (A) Store Basic String Varialbles to FireBase
    func uploadSupplierToFirebaseDB(){
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let supplierRef = ref.child("FKSupplier").childByAutoId()
        self.id = supplierRef.key
        self.path = "FKSuppliers/\(self.id)/"
        
        // Setup Menu
        self.menu.path = self.path
        
        // Setup JSON Object
        let supplier = [
            "id" : self.id,
            "name_en" : self.name_en,
            "name_ar" : self.name_ar,
            "status" : self.status,
            "hours" : self.hours,
            "info_en" : self.info_en,
            "info_ar" : self.info_ar,
            "phoneNumber" : self.phoneNumber ,
            "balance" : String(self.balance) ,
            "creditRate" : String(self.creditRate),
            "menu" : self.menu.id
        ]
        
        // Save Object to Real-time Database
        
        supplierRef.setValue(supplier,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            self.print_action(string: "**** FKSupplier: Supplier uploaded to Firebase Realtime-Database! ****")
            
            self.uploadLogoImageToFirebaseStorage()
            self.uploadDisplayImageToFirebaseStorage()
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOAD), object: nil)
            }
            
        })
        
    }
    
    // (B) Observe/ Fetch Supplier Data + Menu Data -> Menu Items
    func observeFetchSupplierFromFirebaseDB(){
        
        // Call Observe on Reference
        _ = Database.database().reference().child("FKSupplier").queryOrdered(byChild:"id").queryEqual(toValue: id).observe(DataEventType.value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKSupplier: Supplier Data was not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCH_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let supplierID = postDict?.allKeys.first as! String
                
                // Get Item Data
                let supplierData = postDict?[supplierID] as? NSDictionary // array of dictionaries
                
                self.print_action(string: "**** FKSupplier: Supplier Data sucessfully found! ****")
                
                // Init Case Object
                self.id = supplierID
                self.name_en =  supplierData!["name_en"] as! String
                self.name_ar =  supplierData!["name_ar"] as! String
                self.info_en =  supplierData!["info_en"] as! String
                self.info_ar =  supplierData!["info_ar"] as! String
                self.status  =  supplierData!["status"] as! String
                self.hours =  supplierData!["hours"] as! String
                self.phoneNumber =  supplierData!["phoneNumber"] as! String
                self.balance = Double(supplierData!["balance"] as! String)!
                self.creditRate =  Double(supplierData!["creditRate"] as! String)!
                self.path =  "FKSuppliers/\(self.id)/"
                self.menu = FKMenu()
                self.menu.path = self.path
                self.menu.id = supplierData!["menu"] as! String
                self.menu.observeFetchMenuFromFirebaseDB()
                
                self.print_action(string: "**** FKSupplier: Supplier Object Initialized****")
                self.print_supplier_data()
                
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCH), object: nil)
                
            }
            
            
            
        })
    }
    
    
    // (C) Single Fetch Supplier Data -> Menu Data -> Menu Items
    func observeSingleFetchSupplierFromFirebaseDB(){
        
        // Call Observe on Reference
        let ref = Database.database().reference().child("FKSupplier").queryOrdered(byChild:"id").queryEqual(toValue: id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKSupplier: Supplier Data was not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCH_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let supplierID = postDict?.allKeys.first as! String
                
                // Get Item Data
                let supplierData = postDict?[supplierID] as? NSDictionary // array of dictionaries
                
                self.print_action(string: "**** FKSupplier: Supplier Data sucessfully found! ****")
                
                // Init Case Object
                self.id = supplierID
                self.name_en =  supplierData!["name_en"] as! String
                self.name_ar =  supplierData!["name_ar"] as! String
                self.info_en =  supplierData!["info_en"] as! String
                self.info_ar =  supplierData!["info_ar"] as! String
                self.status  =  supplierData!["status"] as! String
                self.hours =  supplierData!["hours"] as! String
                self.phoneNumber =  supplierData!["phoneNumber"] as! String
                self.balance = Double(supplierData!["balance"] as! String)!
                self.creditRate =  Double(supplierData!["creditRate"] as! String)!
                self.path =  "FKSuppliers/\(self.id)/"
                self.menu = FKMenu()
                self.menu.path = self.path
                self.menu.id = supplierData!["menu"] as! String
                self.menu.observeFetchMenuFromFirebaseDB()
                
                self.print_action(string: "**** FKSupplier: Supplier Object Initialized****")
                self.print_supplier_data()
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCH), object: nil)
                
            }
            
        })
        
    }
    
    
    // (D) Update Basic information of Supplier Data
    func updateSupplierToFirebaseDB(){
        
        print_action(string: "FKSupplier: Supplier updating...")
        let ref  = Database.database().reference().child("FKSupplier").child(self.id)
        
        ref.updateChildValues([
            "id" : self.id,
            "name_en" : self.name_en,
            "name_ar" : self.name_ar,
            "status" : self.status,
            "hours" : self.hours,
            "info_en" : self.info_en,
            "info_ar" : self.info_ar,
            "phoneNumber" : self.phoneNumber ,
            "balance" : String(self.balance) ,
            "creditRate" : String(self.creditRate),
            "menu" : self.menu.id
            ], withCompletionBlock: { (NSError, FIRDatabaseReference) in //update the book in the db
                
                // POST NOTIFICATION FOR COMPLETION
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPDATED), object: nil)
                }
                
        })
        
        
    }

    
    // (E) Delete Remove Suppler Data -> Menu Data -> Menu Items
    func removeSupplierFromFireBaseDB(){
        
        // Remove Children objects related
        self.menu.removeMenuFromFirebaseDB()
        
        // Remove Supplier Logo, Display Images from Storage
        self.removeLogoImageFromFirebaseStorage()
        self.removeDisplayImageFromFirebaseStorage()
        
        // Remove Supplier Data from Firebase Real-time Storage
        Database.database().reference().child("FKSupplier").child(self.id).removeValue()

    }
    
    
    
    //MARK:  Helper Methods
    
    func print_supplier_data(){
          print("\n**************************************************** FKMSupplier Log ****************************************************")
        
        let supplier = [
            "id" : self.id,
            "name_en" : self.name_en,
            "name_ar" : self.name_ar,
            "status" : self.status,
            "hours" : self.hours,
            "info_en" : self.info_en,
            "info_ar" : self.info_ar,
            "phoneNumber" : self.phoneNumber ,
            "balance" : String(self.balance) ,
            "creditRate" : String(self.creditRate),
            "menu" : self.menu.id
        ]
        
        print(supplier)
        
        print("*************************************************************************************************************************\n")
        
    }
    
    func print_action(string: String){
        print("\n**************************************************** FKMSupplier Log ****************************************************")
        print(string)
        print("*************************************************************************************************************************\n")
        
    }
    
    
    
}
