//
//  ChatVC.swift
//  Burst Dissertation
//
//  Created by Marawan Alwaraki on 27/12/2017.
//  Copyright © 2017 Marawan Alwaraki. All rights reserved.
//

import UIKit
import Firebase
import NMessenger
import AsyncDisplayKit
import SCLAlertView

class ChatVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var messages:[message] = []
    struct message {
        var text: String
        var sender: String
    }
    
    var chatID: String = ""
    var userId: String = ""
    var vote: Bool = false
    var lastMessage: String? = nil
    
    var ref: DatabaseReference = DatabaseReference()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        loadMessages()
        
        messageTextView.layer.cornerRadius = 5
        messageTextView.layer.borderColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0).cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.delegate = self
        sendButton.isEnabled = false
        
        messagesTable.rowHeight = UITableViewAutomaticDimension
        messagesTable.estimatedRowHeight = 60
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            toggleKeyboard(notification: notification, changeInHeight: -keyboardSize.height)
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            toggleKeyboard(notification: notification, changeInHeight: keyboardSize.height)
        }
    }
    
    func toggleKeyboard(notification: NSNotification, changeInHeight: CGFloat) {
        var userInfo = notification.userInfo!
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
            self.view.layoutSubviews()
            self.scrollToBottom()
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        messageTextView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = !textView.text.isEmpty
    }
    
    @IBAction func pressSend(_ sender: Any) {
        
        if(messageTextView.text.isEmpty) {
            return
        }
        
        sendMessage(message: messageTextView.text)
        
        messageTextView.text = ""
    }
    
    func sendMessage(message: String) {
        
        print("sending message")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        print("coming through")
        
        if(message.isEmpty) {
            return
        }
        
        print("here")
        
        //add message to db
        let combinedKey = String(Int(NSDate().timeIntervalSince1970)) + "-" + userId
        let messagesRef = self.ref.child("messages").child(chatID).child(combinedKey)
        messagesRef.child("text").setValue(message)
        messagesRef.child("sender").setValue(appDelegate.name)
    }
    
    func loadMessages() {
        
        _ = self.ref.child("messages").child(chatID).observe(DataEventType.childAdded, with: { (snapshot) in
            var found = false
//            for i in snapshot.children {
            
                let currentMessage = snapshot //i as! DataSnapshot
//
//                //if previously found or found now or first message
//                found = found || self.lastMessage == currentMessage.key || self.messages.count == 0
//
//                if(!found || self.lastMessage == currentMessage.key) {
//                    continue
//                }
                
                let text = currentMessage.childSnapshot(forPath: "text").value as? String ?? "error_message"
                let sender = currentMessage.childSnapshot(forPath: "sender").value as? String ?? "error_sender"
                self.messages.append(message(text: text, sender: sender))
                
//                self.lastMessage = currentMessage.key
//            }
            self.messagesTable.reloadData()
            self.scrollToBottom()
            
        })
    }
    
    func scrollToBottom() {
        if(self.messagesTable.numberOfRows(inSection: 0) > 0) {
            self.messagesTable.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentMessage = messages[indexPath.item]
        let cell = Bundle.main.loadNibNamed("LeftChatCell", owner: self, options: nil)?.first as! LeftChatCell
        
        //link xib to swift
        cell.sender.text = currentMessage.sender
        cell.message.text = currentMessage.text
        
        cell.message.numberOfLines = 0
        cell.message.lineBreakMode = .byWordWrapping
        
        return cell
    }
    
    @IBAction func leaveChat(_ sender: Any) {
        
        self.messageTextView.resignFirstResponder()
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Leave") {
            self.decrement(topicId: self.chatID)
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                self.vote = appDelegate.vote
                appDelegate.vote = false
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        alertView.addButton("Stay") {
            alertView.dismiss(animated: true, completion: nil)
        }
        
        alertView.showTitle(
            "Leave Chat",
            subTitle: "Are you sure you want to leave this chat?",
            style: .warning, closeButtonTitle: "Cancel",
            colorStyle: 0xCF5369,
            colorTextButton: 0xFFFFFF
        )
    }
    
    func decrement(topicId: String) {
        
        let userVote = vote ? "yes" : "no"
        let usersRef = self.ref.child("topics").child(topicId).child(userVote)
        
        usersRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            
            if var users = currentData.value as? Int, let uid = Auth.auth().currentUser?.uid {
                
                self.ref.child("users").child(uid).child("chat").removeValue()
                users = users-1
                currentData.value = users
                
                if(users<0) {
                    currentData.value = 0
                }
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
