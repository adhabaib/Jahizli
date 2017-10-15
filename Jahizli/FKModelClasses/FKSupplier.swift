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
    
    // public variables
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
    let NOTIFICATION_IMG_DOWN = "FKSuppler_Image_Downloaded"
    
    // Initiliazer
    func setupSupplier(name_en: String, name_ar: String, status: String, hours: String, info_en : String, info_ar: String, phone_number: String, balance: Double, creditRate: Double, logo: Data!, displayImage: Data!){
        
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
        
        // Setup Menu
        self.menu = FKMenu()
        
        
        // UploadData to Firebase Realtime Database
        self.uploadSupplierToFirebaseDB()
      
        // Setup Images
        self.uploadLogoImageToFirebaseStorage()
        self.uploadDisplayImageToFirebaseStorage()
        
    }
    
    // Firebase Storage Methods
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
            self.print_action(string: "**** FKSupplier: Image upload progress -> \(snapshot.progress!.fractionCompleted) ****")
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
            self.print_action(string: "**** FKSupplier: Image upload progress -> \(snapshot.progress!.fractionCompleted) ****")
            if(snapshot.progress!.fractionCompleted == 1.0){
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_IMG_UPLOAD), object: nil)
                }
            }
            
        }
        
    }
    
    // (C) Delete Remove Logo Image From Firebase Storage
    
    
    // (D) Delete Remove Display Image From Firebase Storage
    
    
    
    // Firebase Real-time Methods
    // (A) Store Basic String Varialbles to FireBase
    func uploadSupplierToFirebaseDB(){
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let supplierRef = ref.child("FKSupplier").childByAutoId()
        self.id = supplierRef.key
        self.path = "FKSuppliers/\(self.id)/"
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
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOAD), object: nil)
            }
            
        })
        
    }
    
    // (B) Observe/ Fetch Supplier Data + Menu Data -> Menu Items
    
    // (C) Single Fetch Supplier Data -> Menu Data -> Menu Items
    
    // (D) Update Basic information of Supplier Data
    
    // (E) Delete Remove Suppler Data -> Menu Data -> Menu Items
    
    
    // Aggregate Logic Methods
    
    // Helper Methods
    
    func print_supplier_data(){
        
    }
    
    func print_action(string: String){
        print("\n**************************************************** FKMSupplier Log ****************************************************")
        print(string)
        print("*************************************************************************************************************************\n")
        
    }
    
   
    
}
