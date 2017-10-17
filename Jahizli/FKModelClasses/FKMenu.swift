//
//  FKMenu.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/11/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import Foundation
import Firebase

// FKMenu Class
class FKMenu: NSObject {
    
    //MARK:  public variables
    
    var id: String = "?"
    var menuCategories_en = [String]()
    var menuCategories_ar = [String]()
    var menuItems = [FKMenuItem]()
    var path = ""
    
    // MARK: public notification tags
    let NOTIFICATION_UPLOAD = "FKMenu_Single_Uploaded"
    let NOTIFICATION_UPDATED = "FKMenu_Updated"
    let NOTIFICATION_OBSERVE_EMPTY = "FKMenu_Observe_Empty"
    let NOTIFICATION_OBSERVE = "FKMenu_Observe_Done"
    let NOTIFICATION_FETCHED_ITEMS = "FKMenu_Fetched_Items"
    
    //MARK:  Setup Object Function
    func setupMenu(categories_en: [String], categories_ar : [String]){

        // Setup categories
        for category in categories_en{
            self.menuCategories_en.append(category)
        }
        
        // Setup categories
        for category in categories_ar{
            self.menuCategories_ar.append(category)
        }
        
        self.uploadMenuToFirebaseDB()
        
    }
    
    
    //MARK:  Firebase Real-time Database Methods
    
    // (A) Uploading FKMenu to Real-time Database
    func uploadMenuToFirebaseDB(){
        
        // Create/Retrieve Reference
        let ref =  Database.database().reference()
        let menuRef = ref.child("FKMenus").childByAutoId()
        self.id = menuRef.key
        
        // Setup JSON Object
        let menu = [
            "id" : self.id,
            "menuCategories_en" : self.arrayToString(array: menuCategories_en),
            "menuCategories_ar" : self.arrayToString(array: menuCategories_ar)
            ]
        
        // Save Object to Real-time Database
        
        menuRef.setValue(menu,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            self.print_action(string: "**** FKMenu: menu uploaded to Firebase Realtime-Database! ****")
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPLOAD), object: nil)
            }
            
        })
    }
    
    // (B) Observe/Fetching FKMenu From Real-time Database
    func observeFetchMenuFromFirebaseDB(){
        
        
        // Call Observe on Reference
        _ = Database.database().reference().child("FKMenus").queryOrdered(byChild:"id").queryEqual(toValue: id).observe(DataEventType.value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKMenu: Menu was not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let menuId = postDict?.allKeys.first as! String
                
                // Get Item Data
                let menuData = postDict?[menuId] as? NSDictionary // array of dictionaries
                
                self.print_action(string: "**** FKMenu: menu sucessfully found! ****")
                
                // Init Case Object
                self.id = menuId
                self.menuCategories_en = self.stringToArray(string: menuData!["menuCategories_en"] as! String)
                self.menuCategories_ar = self.stringToArray(string: menuData!["menuCategories_ar"] as! String)
                self.fetchMenuItemsWithIDSFromFirebaseDB()
                
                // NOTE: Removed, added new method to fetch all items in one call
                //self.menuItems = self.decodeMenuItemIDs(ids: menuData!["menuItems"] as! String )
               
                self.print_action(string: "**** FKMenu: Menu Object Initialized****")
                
                // Print Out Item
                self.print_menu()
                
                
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE), object: nil)
                
            }
            
            
            
        })
    }
    
    // (C) Single Fetch FKMenu From Real-time Database
    func observeSingleFetchMenuFromFirebaseDB(){
        // Call Observe on Reference
        let ref = Database.database().reference().child("FKMenus").queryOrdered(byChild:"id").queryEqual(toValue: id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKMenu: menu was not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                // Get ID
                let menuId = postDict?.allKeys.first as! String
                
                // Get Item Data
                let menuData = postDict?[menuId] as? NSDictionary // array of dictionaries
                
                self.print_action(string: "**** FKMenu: menu sucessfully found! ****")
                
                // Init Case Object
                self.id = menuId
                self.menuCategories_en = self.stringToArray(string: menuData!["menuCategories_en"] as! String)
                self.menuCategories_ar = self.stringToArray(string: menuData!["menuCategories_ar"] as! String)
                self.fetchMenuItemsWithIDSFromFirebaseDB()
                
                // NOTE: Removed, added new method to fetch all items in one call
                //self.menuItems = self.decodeMenuItemIDs(ids: menuData!["menuItems"] as! String )
                
                self.print_action(string: "**** FKMenu: Menu Object Initialized****")
                
                // Print Out Item
                self.print_menu()
                
                
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE), object: nil)
                
            }
            
            
            
        })
    }
    
    // (D) Update FKMenu To Real-time Database
    func updateMenuToFirebaseDB(){
        
        print_action(string: "FKMenu: Item updating...")
        let ref  = Database.database().reference().child("FKMenus").child(self.id)
        
        ref.updateChildValues([
            "id" : self.id,
            "menuCategories_en" : self.arrayToString(array: menuCategories_en),
            "menuCategories_ar" : self.arrayToString(array: menuCategories_ar),
            "menuItems" : self.fetchMenuItemsID()
            ], withCompletionBlock: { (NSError, FIRDatabaseReference) in //update the book in the db
                
                // POST NOTIFICATION FOR COMPLETION
                self.print_menu()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_UPDATED), object: nil)
                }
                
        })
        
        
    }
    
    // (E) Update Categories to Menu
    func updateMenuCategory(old_category_en: String ,old_category_ar: String, new_category_en: String, new_category_ar: String){
        
        // Update Menu Categories in both English and Arabic
        
        var en_i = 0
        
        for c in self.menuCategories_en{
            if(c == old_category_en){
               self.menuCategories_en.remove(at: en_i)
               self.menuCategories_en.insert(new_category_en, at: en_i)
            }
            en_i = en_i + 1
        }
        
        var ar_i = 0
        
        for c in self.menuCategories_ar{
            if(c == old_category_ar){
                self.menuCategories_ar.remove(at: ar_i)
                self.menuCategories_ar.insert(new_category_ar, at: ar_i)
            }
            ar_i = ar_i + 1
        }
        
        // Update Menu
        self.updateMenuToFirebaseDB()
        
        // Update Menu Items in old category
        
        for item in self.menuItems {
            if(item.itemCategory == old_category_en){
                item.itemCategory = new_category_en
                item.updateItemToFirebaseDB()
            }
        }
        
        
        
        
    }
    
    // (F) Remove Category and Items associated with it
    func removeMenuCategory(old_category_en: String, old_category_ar: String){
        
        
        // Remove Menu Categories in both English and Arabic
        
        var en_i = 0
        
        for c in self.menuCategories_en{
            if(c == old_category_en){
                self.menuCategories_en.remove(at: en_i)
                
            }
            en_i = en_i + 1
        }
        
        var ar_i = 0
        
        for c in self.menuCategories_ar{
            if(c == old_category_ar){
                self.menuCategories_ar.remove(at: ar_i)
            }
            ar_i = ar_i + 1
        }
        
        
        // Remove all Unassigned MenuItems
        
        for item in self.menuItems {
            if(item.itemCategory == old_category_en){
               self.removeMenuItem(item: item)
            }
        }
        
        
    }
    
    // (G) Add new Menu Category
    func addNewMenuCategory(category_en: String, category_ar: String){
        self.menuCategories_en.append(category_en)
        self.menuCategories_ar.append(category_ar)
        self.updateMenuToFirebaseDB()
        
    }
    
    // (H) Remove Menu From Firebase Realtime Database
    func removeMenuFromFirebaseDB(){
        // Clear MenuItems From Array
        self.menuItems.removeAll()
        
        // Remove Menu Data From Firebase -> Removes All FKMenuItems
        Database.database().reference().child("FKMenus").child(self.id).removeValue()
        
    }
    

    //MARK:  Logic Methods
    
    // (A) Add MenuItem to Menu
    func addMenuItem(itemName_en: String, itemName_ar: String, itemInfo_en: String, itemInfo_ar: String, itemImage: Data!, itemPrice: Double, itemCategory: String){
        
        let item = FKMenuItem()
        
        item.setupItem(itemName_en: itemName_en, itemName_ar: itemName_ar, itemInfo_en: itemInfo_en, itemInfo_ar: itemInfo_ar, itemImage: itemImage, itemPrice: itemPrice, itemCategory: itemCategory, path: path, menuID: self.id)
        
        self.menuItems.append(item)
        
    }
    
    // (B) Remove MenuItem From Menu
    func removeMenuItem(item: FKMenuItem){
        
        // Remove Item from menu and from FirebaseDB
        var counter = 0
        for i in self.menuItems {
            if(item.id == i.id){
                item.removeItemFromFirebaseDB()
                self.menuItems.remove(at: counter)
            }
            counter = counter + 1
        }
        
        self.updateMenuToFirebaseDB()
        
    }
    
    
    // (C) Update Menu Item From Menu
    func updateMenuItem(item: FKMenuItem){
        item.updateItemToFirebaseDB()
    }
    
    // (D) Get All MenuItems For Menu
    func fetchMenuItemsWithIDSFromFirebaseDB(){
        // Call Observe on Reference
        _ = Database.database().reference().child("FKMenuItem").queryOrdered(byChild:"menuID").queryEqual(toValue: self.id).observe(DataEventType.value, with: { (snapshot) in
            
            // Get Data From Real-time Database
            let postDict = snapshot.value as? NSDictionary
            
            // No Item Found Return Failed to Find
            if(postDict == nil){
                self.print_action(string: "**** FKMenu: Items were not found/empty. ****")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_OBSERVE_EMPTY), object: nil)
                }
                
            }
            else{
                for child in snapshot.children.allObjects as! [DataSnapshot]  {
                    
                    // Create FKMenuItem
                    let item = FKMenuItem()
                    
                    // Parse Data to new Item
                    let itemData = child.value as? NSDictionary
                    let itemID = postDict?.allKeys.first as! String
                    
                    self.print_action(string: "**** FKMenu: items sucessfully found! ****")
                    
                    // Init Case Object
                    item.id = itemID
                    item.itemName_en = itemData!["itemName_en"] as! String
                    item.itemName_ar = itemData!["itemName_ar"] as! String
                    item.itemInfo_ar  = itemData!["itemInfo_ar"] as! String
                    item.itemInfo_en = itemData!["itemInfo_en"] as! String
                    item.itemPrice = Double(itemData!["itemPrice"] as! String)!
                    item.itemCategory = itemData!["itemCategory"] as! String
                    item.menuID = itemData!["menuID"] as! String
                    item.path = self.path
                    item.fetchImageFromFirebaseStorage()
                    
                    self.menuItems.append(item)
                    
                    self.print_action(string: "**** FKMenu: item Object Initialized****")
 
                }
              
                self.print_menu()
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.NOTIFICATION_FETCHED_ITEMS), object: nil)
                
            }
            
            
            
        })
    }
    
    
    

    //MARK:  Helper Methods
    
    func print_menu(){
        
        print("\n************************** FKMenu Log **************************")
        
        for item in self.menuItems {
            
            item.print_item()
            
        }
        
        
        print("*******************************************************************\n")
    
    }
    
    func print_action(string: String){
        print("\n************************** FKMenu Log **************************")
        print(string)
        print("*******************************************************************\n")
        
    }
    
    
    func arrayToString(array: [String]) -> String{
        return array.joined(separator:",")
    }
    
    func stringToArray(string: String) -> [String]{
        return string.characters.split{$0 == ","}.map(String.init)
    }
    
    func fetchMenuItemsID() -> String{
        
        var ids = [String]()
        
        for item in self.menuItems{
            ids.append(item.id)
        }
        
        return arrayToString(array: ids)
        
    }
    
    func decodeMenuItemIDs(ids: String) -> [FKMenuItem]{
        
        var items = [FKMenuItem]()
        
        let ids_array = self.stringToArray(string: ids)
        
        for e in ids_array{
            let item = FKMenuItem()
            item.id = e
            item.path = self.path
            item.observeSingleFetchItemFromFirebaseDB()
            item.fetchImageFromFirebaseStorage()
            items.append(item)
        }
        
        return items
        
    }
    
    
}

