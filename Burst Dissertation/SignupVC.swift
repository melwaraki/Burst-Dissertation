//
//  SignupVC.swift
//  Burst Dissertation
//
//  Created by Marawan Alwaraki on 25/12/2017.
//  Copyright © 2017 Marawan Alwaraki. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SignupVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    
    override func viewDidAppear(_ animated: Bool) {
        nameField.becomeFirstResponder()
        nameField.delegate = self
        doneBtn.isEnabled = false
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        doneBtn.isEnabled = (sender.text != "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finished(doneBtn)
        return true
    }
    
    @IBAction func finished(_ sender: UIBarButtonItem) {
        if(nameField.text == "" || nameField.text == nil) {return} //check again
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        appDelegate.name = nameField.text!
        
        let ref = Database.database().reference().child("users").child(appDelegate.uid)
        ref.child("name").setValue(appDelegate.name)

        self.nameField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
