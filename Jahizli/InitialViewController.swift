//
//  InitialViewController.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 12/5/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageViewCounter = 0
    
    var img0 = UIImage(named: "img0")
    var img1 = UIImage(named: "img1")
    var img2 = UIImage(named: "img2")
    var img3 = UIImage(named: "img3")
    
    @IBOutlet weak var thirdLineLabel: UILabel!
    @IBOutlet weak var secLineLabel: UILabel!
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var endLineLabel: UILabel!
    
    var firstViewAppear = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.firstLineLabel.text = ""
        self.secLineLabel.text = ""
        self.thirdLineLabel.text = ""
        self.endLineLabel.text = ""
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.imageView.image = img0
        
        
        
        
        
       
        if(self.firstViewAppear){
            
            
            
            self.animateImageView()
            self.zoomInOutAnimation()
            
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.firstLineLabel.slideInFromLeft()
                self.firstLineLabel.text = "Local"
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                self.secLineLabel.slideInFromLeft()
                self.secLineLabel.text = "favourites"
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                self.thirdLineLabel.slideInFromLeft()
                self.thirdLineLabel.text = "prepared"
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.endLineLabel.slideInFromLeft()
                self.endLineLabel.text = "faster"
            })
            
            self.firstViewAppear = false
        }
        
   
        
        
    }
    
    func animateImageView(){
        
        var image:UIImage!
        
        if(self.imageView.image == self.img0){
            image = self.img1!
        }
        else if(self.imageView.image == self.img1){
            image = self.img2!
        }
        else if(self.imageView.image == self.img2){
            image = self.img3!
        }
        else if(self.imageView.image == self.img3){
            image = self.img0!
        }
        
        UIView.transition(with: imageView, duration: 2, options: .transitionCrossDissolve, animations: {self.imageView.image = image}) { (done) in
            
         
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.animateImageView()
            })
            
            
        }
        
       
    }
    
    func zoomInOutAnimation(){
        UIView.animate(withDuration: 4.0, animations: {() -> Void in
            self.imageView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 4.0, animations: {() -> Void in
                self.imageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: {(_ finished: Bool) -> Void in
                self.zoomInOutAnimation()
            })
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension UIView {
    // Name this function in a way that makes sense to you...
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideInFromLeft(duration: TimeInterval = 0.75, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    
    func slideInFromRight(duration: TimeInterval = 0.75, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromRightTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromRightTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        // Customize the animation's properties
        slideInFromRightTransition.type = kCATransitionPush
        slideInFromRightTransition.subtype = kCATransitionFromRight
        slideInFromRightTransition.duration = duration
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromRightTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromRightTransition, forKey: "slideInFromRightTransition")
    }
}
