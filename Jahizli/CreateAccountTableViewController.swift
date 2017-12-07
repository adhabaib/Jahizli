//
//  CreateAccountTableViewController.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 12/6/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import UIKit
import SwiftHEXColors

class CreateAccountTableViewController: UITableViewController, UITextFieldDelegate{

    var current_country: String = "Kuwait"
    var current_country_code: String = "+965"
    var current_country_phone_number_count = 8
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Create an account"
     
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "DIN", size: 16)!]
       
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        self.actionButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "DIN", size: 12 )!], for: UIControlState.normal)
        
        self.actionButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "DIN", size: 16)!], for: UIControlState.highlighted)
    

        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func sendVerficationCode(){
   
    }
   
    @IBAction func dismissViewController(_ sender: Any) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
            self.view.endEditing(true)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.dismiss(animated: true, completion: nil)
        })
        
       
       
    }
    
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        if(newLength > (self.current_country_phone_number_count - 1 )){
            self.actionButton.tintColor = UIColor.white
            self.actionButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "DIN", size: 18 )!], for: UIControlState.normal)
            
            self.actionButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "DIN", size: 20)!], for: UIControlState.highlighted)
        }
        else{
            self.actionButton.tintColor = UIColor(hexString: "#CCCCCC")
            self.actionButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "DIN", size: 17 )!], for: UIControlState.normal)
            
        }
        
        return newLength <= self.current_country_phone_number_count
    }
    
    // MARK: - Table view data source


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "blank_0", for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "country_cell", for: indexPath) as! FKCountryCell_EN
            
            cell.countryImageView.image = UIImage(named: self.current_country)
            cell.countryImageView.layer.cornerRadius = cell.countryImageView.frame.size.width / 2
            cell.countryImageView.clipsToBounds = true
            cell.countryImageView.layer.borderColor = UIColor.lightGray.cgColor
            cell.countryImageView.layer.borderWidth = 0.5
            cell.countryLabel.text = "\(self.current_country) \(self.current_country_code)"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "phone_cell", for: indexPath) as! FKPhoneNumberCell_EN
            cell.phoneTextField.delegate = self
            cell.phoneTextField.becomeFirstResponder()
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "disclaimer_cell", for: indexPath) as! FKDisclaimerCell_EN
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "blank_0", for: indexPath)
            return cell
        }

    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 10.0
        }
        else{
            return 50.0
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
