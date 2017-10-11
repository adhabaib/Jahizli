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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Second commmit of project!")
        
        
        
        // Debuging Model Classes
        item = FKMenuItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateImageViewFKMenuItem), name: Notification.Name(self.self.item.NOTIFICATION_IMG_DOWN), object: nil)
     
        let img = UIImage(named: "FKMenuItem")
        item.itemImage = img?.jpeg
        item.uploadItemToFirebaseDB()
        item.uploadImageToFireBaseStorage()
        item.observeFetchItem(id: "-Kw1fsHaQmT9njsYlslY")
        item.fetchImageFromFirebaseStorage(id: "-KwBVP2bPtmofRoc1fX8")
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Helper Functions
    @objc func updateImageViewFKMenuItem(){
       self.imageView.image =  self.item.itemImage.uiImage!
    }


}

