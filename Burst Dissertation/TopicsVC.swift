//
//  TopicsVC.swift
//  Burst Dissertation
//
//  Created by Marawan Alwaraki on 25/12/2017.
//  Copyright © 2017 Marawan Alwaraki. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class TopicsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topicsTable: UITableView!
    
    var topics:[topic] = []
    struct topic {
        var question: String
        var yes: Int
        var no: Int
        var required: Bool
        var id: String
    }
    
    var ref: DatabaseReference = DatabaseReference()
    var argument: String = ""
    var alreadyChatting: Bool = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentTopic = topics[indexPath.item]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "")
        cell.textLabel?.text = currentTopic.question
        cell.detailTextLabel?.text = "Yes: " + String(currentTopic.yes) + "/2, No: " + String(currentTopic.no) + "/2"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentTopic = topics[indexPath.item]
        
        let alertView = SCLAlertView()
        var argumentView: UITextView = UITextView()
        var required: Bool = false
        
        self.argument = ""
        
        //if required message
        if(currentTopic.required) {
            required = true
            argumentView = alertView.addTextView()
        }
        
        if(currentTopic.yes < 2) {
            alertView.addButton("Yes") {
                if(required) {
                    if(argumentView.text.isEmpty) {
                        return
                    } else {
                        self.argument = argumentView.text
                    }
                }
                self.increment(topicId: currentTopic.id, vote: true)
            }
        }
        
        if(currentTopic.no < 2) {
            alertView.addButton("No") {
                if(required) {
                    if(argumentView.text.isEmpty) {
                        return
                    } else {
                        self.argument = argumentView.text
                    }
                }
                self.increment(topicId: currentTopic.id, vote: false)
            }
        }
        
        alertView.showTitle(
            "Vote",
            subTitle: currentTopic.question,
            style: .success, closeButtonTitle: "Cancel",
            colorStyle: 0xCF5369,
            colorTextButton: 0xFFFFFF
        )
    }
    
    func increment(topicId: String, vote: Bool) {
        
        let userVote = vote ? "yes" : "no"
        let usersRef = self.ref.child("topics").child(topicId).child(userVote)
        
        usersRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            
            if var users = currentData.value as? Int, let uid = Auth.auth().currentUser?.uid {
                
                if(users>1) {
                    print("chat full")
                } else {
                    self.ref.child("users").child(uid).child("chat").setValue(topicId)
                    
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.vote = vote
                    }
                    
                    self.ref.child("users").child(uid).child("vote").setValue(vote)
                    users = users+1
                    currentData.value = users
                    self.hasChat()
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
    
    func checkUserExists() {
        
        //initialise app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            signUp()
            return
        }
        
        //sign in
        Auth.auth().signInAnonymously() { (user, error) in
            if(error != nil) {
                print(error!)
            } else {
                print(user?.uid ?? "no uid")
                appDelegate.uid = user?.uid ?? ""
                
                Database.database().reference().child("users").child(appDelegate.uid).observe(.value, with: { (snapshot) in
                    appDelegate.name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                    
                    if(appDelegate.name == "") {
                        self.signUp()
                    } else {
                        self.alreadyChatting = true
                        self.hasChat()
                    }
                })
            }
        }
        
    }
    
    func hasChat() {
        ref.child("users").child((Auth.auth().currentUser?.uid)!).child("chat").observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.value as? String != nil) {
                self.performSegue(withIdentifier: "openchat", sender: snapshot.value as! String)
            }
            self.alreadyChatting = false
        })
    }
    
    func signUp() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signup") as? UINavigationController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUserExists()
        
        ref = Database.database().reference()
        
        ref.child("topics").observe(.value, with: { (snapshot) in
            
            self.topics = []
            
            for i in snapshot.children .reversed() {
                let postSnap = i as! DataSnapshot
                
                let question = postSnap.childSnapshot(forPath: "question").value as? String ?? "error_topic"
                let yes = postSnap.childSnapshot(forPath: "yes").value as? Int ?? 0
                let no = postSnap.childSnapshot(forPath: "no").value as? Int ?? 0
                let required = postSnap.childSnapshot(forPath: "require").value as? Bool ?? false
                let id = postSnap.key
                
                self.topics.append(topic(question: question, yes: yes, no: no, required: required, id: id))
            }
            
            self.topicsTable.reloadData()
        })

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(Auth.auth().currentUser?.uid == nil
            || sender == nil || !(sender is String)
            || sender as! String == "") {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let chatVC = (segue.destination).childViewControllers[0] as! ChatVC
        chatVC.userId = (Auth.auth().currentUser?.uid)!
        chatVC.chatID = sender as! String
        
        if(alreadyChatting) {return} //dont send if already in chat
        
        //send initial message
        let combinedKey = String(Int(NSDate().timeIntervalSince1970)) + "-" + (Auth.auth().currentUser?.uid)!
        let messagesRef = self.ref.child("messages").child(sender as! String).child(combinedKey)
        messagesRef.child("sender").setValue("admin")
        let name = appDelegate.name
        var message = "\(name) joined."

        if(!argument.isEmpty) {
             message.append(" Argument: \(argument)")
        }
        
        messagesRef.child("text").setValue(message)
    }
    
}
