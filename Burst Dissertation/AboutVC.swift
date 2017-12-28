//
//  AboutVC.swift
//  Burst Dissertation
//
//  Created by Marawan Alwaraki on 28/12/2017.
//  Copyright © 2017 Marawan Alwaraki. All rights reserved.
//

import UIKit
import MessageUI
import SCLAlertView

class AboutVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadBtn.layer.cornerRadius = 5
        contactBtn.layer.cornerRadius = 5
        cancelBtn.layer.cornerRadius = 5
    }
    
    @IBAction func download(_ sender: Any) {
        guard let url = URL(string: "https://burst.carrd.co") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func contact(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["hello.burstapp@gmail.com"])
            mail.setSubject("Burst X")
            present(mail, animated: true)
        } else {
            
            let alertView = SCLAlertView()
            
            alertView.addButton("Sure") {
                UIPasteboard.general.string = "hello.burstapp@gmail.com"
            }
            
            alertView.showTitle(
                "Couldn't Load Mail",
                subTitle: "Looks like you have no accounts in Mail. Our email address has been copied to your clipboard. You can paste this address in your email client.",
                style: .warning, closeButtonTitle: "Don't Copy",
                colorStyle: 0xCF5369,
                colorTextButton: 0xFFFFFF
            )
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    

}
