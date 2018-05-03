//
//  ArgumentVC.swift
//  Burst Dissertation
//
//  Created by Marawan Alwaraki on 05/02/2018.
//  Copyright © 2018 Marawan Alwaraki. All rights reserved.
//

import UIKit

class ArgumentVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var argumentText: UITextView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var submitBtn: UIButton!
    
    var topicId: String = ""
    var vote: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        argumentText.becomeFirstResponder()
        argumentText.inputAccessoryView = toolbar
        submitBtn.isEnabled = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        submitBtn.isEnabled = argumentText.text.count > 0
    }
    
    @IBAction func didCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSubmit(_ sender: Any) {
        if let presenter = self.presentingViewController?.childViewControllers[0] as? TopicsVC {
            presenter.argument = argumentText.text
            presenter.increment(topicId: self.topicId, vote: self.vote)
        }
    }
    
}
