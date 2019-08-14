//
//  InfoViewController.swift
//  QR-BCard
//
//  Created by SlicePay on 16/08/18.
//  Copyright © 2018 Arnab Hore. All rights reserved.
//

import UIKit
import MessageUI
import IntentsUI
import os.log

class InfoViewController: UIViewController {
    @IBOutlet var infoTable: UITableView!
    @IBOutlet var tableFooterView: UIView!
    
    var infoArray = ["Share", "Credits", "Feedback", "Review"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        infoTable.tableFooterView = UIView()
        configureFooter()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureFooter() {
        if #available(iOS 12.0, *) {
            let addShortcutButton = INUIAddVoiceShortcutButton(style: .whiteOutline)
            addShortcutButton.shortcut = INShortcut(intent: ShowQRIntent())
            addShortcutButton.delegate = self
            
            addShortcutButton.translatesAutoresizingMaskIntoConstraints = false
            tableFooterView.addSubview(addShortcutButton)
            tableFooterView.centerXAnchor.constraint(equalTo: addShortcutButton.centerXAnchor).isActive = true
            tableFooterView.centerYAnchor.constraint(equalTo: addShortcutButton.centerYAnchor).isActive = true
            
            infoTable.tableFooterView = tableFooterView
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func share() {
        let textToShare = """
Hey, I've found this awesome app to share your contact with anyone through iOS camera.

Generate your QR code just by filling out your contact information. Tell others to scan that QR code with iPhone/iPad camera and they will get your contact details on their iPhone/iPad contact.

https://itunes.apple.com/us/app/get-my-contact/id1420548798
"""
        let activityItems = [textToShare] as [Any]
        let shareViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            shareViewController.popoverPresentationController?.sourceView = self.view
            let ip = IndexPath(row: 0, section: 0)
            if let cell = infoTable.cellForRow(at: ip) {
                shareViewController.popoverPresentationController?.sourceRect = cell.convert(cell.bounds, to: self.view)
            }
        }
        self.present(shareViewController, animated: true, completion: nil)
    }
    
    func openWebview() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Web") {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func sendMail() {
        let composer = MFMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            composer.mailComposeDelegate = self
            composer.setToRecipients(["info@popcornarena.com"])
            composer.setSubject("Feedback of Get My Contact")
            present(composer, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension InfoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        
        cell.textLabel?.text = infoArray[indexPath.row]
        cell.textLabel?.font = UIFont.init(name: "BrandonGrotesque-Medium", size: 19.0)
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if infoArray[indexPath.row] == "Share" {
            share()
        } else if infoArray[indexPath.row] == "Credits" {
            openWebview()
        } else if infoArray[indexPath.row] == "Feedback" {
            sendMail()
        } else if infoArray[indexPath.row] == "Review" {
            if let url = URL(string: "https://itunes.apple.com/us/app/get-my-contact/id1420548798?action=write-review"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

extension InfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

extension InfoViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)

    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

extension InfoViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController,
                                        didFinishWith voiceShortcut: INVoiceShortcut?,
                                        error: Error?) {
        if let error = error as NSError? {
            os_log("Error adding voice shortcut: %@", log: OSLog.default, type: .error, error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension InfoViewController: INUIEditVoiceShortcutViewControllerDelegate {
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didUpdate voiceShortcut: INVoiceShortcut?,
                                         error: Error?) {
        if let error = error as NSError? {
            os_log("Error adding voice shortcut: %@", log: OSLog.default, type: .error, error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
