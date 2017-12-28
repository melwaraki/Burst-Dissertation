//
//  AddTopicVC.swift
//  Burst Dissertation
//
//  Created by Marawan Alwaraki on 26/12/2017.
//  Copyright © 2017 Marawan Alwaraki. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class AddTopicVC: UIViewController, UITextViewDelegate {

    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var submitText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.submitBtn.isEnabled = false
        self.submitText.becomeFirstResponder()
        self.submitText.inputAccessoryView = toolbar
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        submitText.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitTopics(_ sender: UIButton) {
        
        self.submitText.resignFirstResponder()
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("Yes") {
            self.addTopic(requireArgument: true)
        }
        
        alert.addButton("No") {
            self.addTopic(requireArgument: false)
        }
        
        alert.addButton("Cancel") {
            self.submitText.becomeFirstResponder()
        }
        
        alert.showTitle(
            "Topic added",
            subTitle: "Do you require users to submit an argument before joining the conversation?",
            style: .success,
            colorStyle: 0xCF5369,
            colorTextButton: 0xFFFFFF
        )
    }
    
    func addTopic(requireArgument: Bool) {
        let date:String = String(Int(NSDate().timeIntervalSince1970))
        let combinedKey:String = date + "-" + (Auth.auth().currentUser?.uid)!
        let ref = Database.database().reference().child("topics").child(combinedKey)
        
        ref.child("question").setValue(submitText.text)
        ref.child("yes").setValue(0)
        ref.child("no").setValue(0)
        ref.child("require").setValue(requireArgument)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if(submitText.text != "") {
            placeholder.isHidden = true
            submitBtn.isEnabled = true
        } else {
            placeholder.isHidden = false
            submitBtn.isEnabled = false
        }
    }

}
