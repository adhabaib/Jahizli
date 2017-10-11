//
//  ViewController.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/1/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Second commmit of project!")
        
        
        // Debuging Model Classes
        let item:FKMenuItem = FKMenuItem()
        let img = UIImage(named: "FKMenuItem")
        item.itemImage = UIImageJPEGRepresentation(img!, 1.0)
        item.uploadItemToFirebaseDB()
        item.uploadImageToFireBaseStorage()
        item.observeFetchItem(id: "-Kw1fsHaQmT9njsYlslY")
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

