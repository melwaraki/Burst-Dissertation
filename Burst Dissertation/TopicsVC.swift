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
        var id: String
    }
    
    var ref: DatabaseReference = DatabaseReference()
    
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
        
        if(currentTopic.yes < 2) {
            alertView.addButton("Yes") {
                self.increment(topicId: currentTopic.id, vote: true)
            }
        }
        
        if(currentTopic.no < 2) {
            alertView.addButton("No") {
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
                    print("we here again")
                    self.ref.child("users").child(uid).child("chat").setValue(topicId)
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
                        self.hasChat()
                    }
                })
            }
        }
        
    }
    
    func hasChat() {
        ref.child("users").child((Auth.auth().currentUser?.uid)!).child("chat").observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.value as? String == nil) {
                print("no chat")
            } else {
                print("you have a chat") //this keeps adding a chat for me whenever i leave
                self.performSegue(withIdentifier: "openchat", sender: snapshot.value as! String)
            }
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
                let id = postSnap.key
                
                self.topics.append(topic(question: question, yes: yes, no: no, id: id))
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
        
        let chatVC = (segue.destination).childViewControllers[0] as! ChatVC
        chatVC.userId = (Auth.auth().currentUser?.uid)!
        chatVC.chatID = sender as! String
    }
    
}
