//
//  ViewController.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/1/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
   
    var item:FKMenuItem!
    var menu: FKMenu!
    var item_count = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Second commmit of project!")
        
        // Debuging Model Classes
        
        
        /*
        item = FKMenuItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateImageViewFKMenuItem), name: Notification.Name(self.self.item.NOTIFICATION_IMG_UPLOAD), object: nil)
     
        let img = UIImage(named: "FKMenuItem")
        
        self.item.setupItem(itemName_en: "Chicken Shwarma", itemName_ar: "???????", itemInfo_en: "BEST shwarma in town.", itemInfo_ar: "????????", itemImage: img?.jpeg, itemPrice: 1.5, itemCategory: "Main")
          */
        
        menu = FKMenu()
        menu.id = "-KwW0Blkmw8DSfBqZdim"
        menu.observeFetchMenuFromFirebaseDB()
    
        item = FKMenuItem()

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.print_out_menu), name: Notification.Name(self.self.item.NOTIFICATION_OBSERVE), object: nil)
        
        
        /*
        let club = UIImage(named: "club")
        let cake = UIImage(named: "cake")
        let drink = UIImage(named: "water")
        
        
        menu.setupMenu(categories_en: ["Sandwitches","Drinks","Desert"], categories_ar: ["Sandwitches","Drinks","Desert"] )
        
        menu.addMenuItem(itemName_en: "Club Sandwitch", itemName_ar: "***", itemInfo_en: "Tasty!", itemInfo_ar: "***", itemImage: club?.jpeg, itemPrice: 2.00, itemCategory: "Sandwitches")
        menu.addMenuItem(itemName_en: "Water", itemName_ar: "***", itemInfo_en: "Refreshing!", itemInfo_ar: "***", itemImage: drink?.jpeg, itemPrice: 0.50, itemCategory: "Drinks")
        menu.addMenuItem(itemName_en: "Cake", itemName_ar: "***", itemInfo_en: "Yummy!", itemInfo_ar: "***", itemImage: cake?.jpeg, itemPrice: 3.50, itemCategory: "Desert")
        
        */
    
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Helper Functions
    @objc func updateImageViewFKMenuItem(){
      item.observeFetchItemFromFirebaseDB()
      item.fetchImageFromFirebaseStorage()
      self.imageView.image =  self.item.itemImage.uiImage!
    }
    
    

    
    @objc func print_out_menu(){
        
        self.item_count = self.item_count + 1
        if(self.item_count == self.menu.menuItems.count){
            print("PRINTING OUT MENU FROM VIEW_CONTROLLER: \n")
            self.menu.print_menu()
           // self.menu.updateMenuCategory(old_category_en: "Drinks", old_category_ar: "Drinks", new_category_en: "Beverages", new_category_ar: "Beverages")
         //   self.menu.removeMenuCategory(old_category_en: "Desert", old_category_ar: "Desert")
        }
        
        
    }


}

