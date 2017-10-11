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
    var menuCategories = [String]()
    var menuItems = [FKMenuItem]()
    
    
    // public notification tags
    
    
    
    // Setup Object Function
    func setupMenu(categories: [String]){

        // Setup categories
        for category in categories{
            self.menuCategories.append(category)
        }
        
    }
    
    
    // Firebase Real-time Database Methods
    
    
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
    
    

    // Helper Methods
    
    
    
}

