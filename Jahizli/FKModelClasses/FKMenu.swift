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
    
    // public variables
    
    var id: String = "?"
    var menuCategories_en = [String]()
    var menuCategories_ar = [String]()
    var menuItems = [FKMenuItem]()
    
    
    // public notification tags
    
    
    
    // Setup Object Function
    func setupMenu(categories_en: [String], categories_ar : [String]){

        // Setup categories
        for category in categories_en{
            self.menuCategories_en.append(category)
        }
        
        // Setup categories
        for category in categories_ar{
            self.menuCategories_ar.append(category)
        }
        
    }
    
    
    // Firebase Real-time Database Methods
    
    // (A) Uploading FKMenu to Real-time Database
    func uploadMenuToFirebaseDB(){
     
    }
    
    // (B) Observe/Fetching FKMenu From Real-time Database
    func observeFetchMenuFromFirebaseDB(){
        
    }
    
    // (C) Single Fetch FKMenu From Real-time Database
    func observeSingleFetchMenuFromFirebaseDB(){
        
    }
    
    

    // Logic Methods
    
    // (A) Add MenuItem to Menu
    func addMenuItem(itemName_en: String, itemName_ar: String, itemInfo_en: String, itemInfo_ar: String, itemImage: Data!, itemPrice: Double, itemCategory: String){
        
        let item = FKMenuItem()
        
        item.setupItem(itemName_en: itemName_en, itemName_ar: itemName_ar, itemInfo_en: itemInfo_en, itemInfo_ar: itemInfo_ar, itemImage: itemImage, itemPrice: itemPrice, itemCategory: itemCategory)
        
        self.menuItems.append(item)
   
    }
    
    // (B) Remove MenuItem From Menu
    func removeMenuItem(item: FKMenuItem){
        
        // Remove Item from menu and from FirebaseDB
        var counter = 0
        for i in self.menuItems {
            if(item.id == i.id){
                self.menuItems.remove(at: counter)
                i.removeItemFromFirebaseDB()
            }
            counter = counter + 1
        }
        
        
    }
    
    
    // (C) Update Menu Item From Menu
    func updateMenuItem(item: FKMenuItem){
        item.updateItemToFirebaseDB()
    }
    
    

    // Helper Methods
    
    func print_menu(){
        
        print("\n************* FKMenu Log *************")
        
        for item in self.menuItems {
            
            item.print_item()
            
        }
        
        
        print("******************************************\n")
    
    }
    
    
    func arrayToString(array: [String]) -> String{
        return array.joined(separator:",")
    }
    
    func stringToArray(string: String) -> [String]{
        return string.characters.split{$0 == ","}.map(String.init)
    }
    
    
}

