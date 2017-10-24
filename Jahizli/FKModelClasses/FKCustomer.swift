//
//  FKCustomer.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/22/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import Foundation
import Firebase

// FKCustomer Class
class FKCustomer: NSObject, MessagingDelegate {
    
    //MARK: public variables
    var verificationId: String = ""
    var phoneNumber: String = ""
    var loggedIn: Bool = false
    var fcmToken: String = ""
    var incomplete_orders = [FKOrder]()

    //MARK: Firebase Authentication functions
    
    //(A) Sending Verification Code and Obtain Verification ID
    func sendVerficationCodeForAuth(){
        
        Auth.auth().languageCode = "ar"
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // Sign in using the verificationID and the code sent to the user
            self.verificationId = verificationID!
            UserDefaults.standard.set(self.verificationId, forKey: "authVerificationID")
        }
        
    }
    
    //(B) Sign in With Verification Code and Verification ID
    func signInWithSMSVerificationCode(verificationCode: String){
        
        // Create Credentials
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: self.verificationId,
            verificationCode: verificationCode)
        
        // Sign In Using Auth
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("FKCustomer: Failed to Sign In")
                return
            }
            // User is signed in
            print("FKCustomer: User signed in!")
            self.loggedIn = true
            UserDefaults.standard.set(self.loggedIn, forKey: "FKCustomerLoggedInStatus")
            UserDefaults.standard.set(self.phoneNumber, forKey: "FKCustomerPhoneNumber")
            self.getFCKToken()
        }
    }
    
    //(C) Sign Out
    func signOut(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    //(D) Fetch user froms local storage
    func isUserSignedIn() -> Bool{
        
        loggedIn = UserDefaults.standard.bool(forKey: "FKCustomerLoggedInStatus")
        
        if (self.loggedIn) {
            phoneNumber = UserDefaults.standard.string(forKey: "FKCustomerPhoneNumber")!
            print("FKCustomer: \(phoneNumber) logged in and authenticated")
            self.getFCKToken()
            return true
        }
        else{
            print("FKCustomer: user NOT FOUND")
            return false
        }
        
        
    }
    
    // (E) Get FCM Token
    func getFCKToken(){
        self.fcmToken = Messaging.messaging().fcmToken!
        print("FKCustomer: FCM token: \(self.fcmToken)")
    }
    
    
    //:MARK: Update pending orders with new FCM Token
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("FKCustomer: Firebase registration token: \(fcmToken)")
        self.fcmToken = fcmToken
        
        for order in self.incomplete_orders {
            order.customerFCMToken = self.fcmToken
            order.updateIncompleteOrderToFireBaseDB()
        }
        
    }
        

}
    
    
    
    
    
    

