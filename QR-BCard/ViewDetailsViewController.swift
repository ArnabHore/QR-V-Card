//
//  ViewDetailsViewController.swift
//  QR-BCard
//
//  Created by Arnab Hore on 07/07/17.
//  Copyright © 2017 Arnab Hore. All rights reserved.
//

import UIKit
import Contacts

protocol AddToContactDelegate {
    func addToContact(shouldAdd: Bool, WithData dataStr: String);
}

class ViewDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var addToContactDelegate: AddToContactDelegate!
    
    @IBOutlet var table: UITableView!  
    @IBOutlet var bgView: UIView!
    
    var scannedData: String!
    var detailsArray: NSMutableArray = NSMutableArray()
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.bgView.layer.cornerRadius = 10
        self.bgView.clipsToBounds = true
        self.bgView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if scannedData != nil {
            
            guard let data = scannedData.data(using: .utf8) else {
                return
            }
            
            let contacts  = try? CNContactVCardSerialization.contacts(with: data)
            let contact: CNContact = (contacts?.first)!
            
            if !contact.givenName.isEmpty {
                detailsArray.add("First Name: \(contact.givenName)")
            }
            
            if !contact.familyName.isEmpty {
                detailsArray.add("Last Name: \(contact.familyName)")
            }
            
            if !contact.jobTitle.isEmpty {
                detailsArray.add("Designation: \(contact.jobTitle)")
            }
            
            if !contact.organizationName.isEmpty {
                detailsArray.add(contact.organizationName)
            }
            
            let emails = contact.emailAddresses
            
            if !emails.isEmpty {
                for email in emails {
                    let emailLbl = email.label
                    let emailVal = email.value
                    
                    if emailLbl == CNLabelHome {
                        detailsArray.add("Email (Personal): \(emailVal)")
                    } else if emailLbl == CNLabelWork {
                        detailsArray.add("Email (Work): \(emailVal)")
                    }
                }
            }
            
            let labeledVals = contact.phoneNumbers
            
            if !labeledVals.isEmpty {
                for ph in labeledVals {
                    let homePhlbl = ph.label
                    let homePh = ph.value
                    
                    if homePhlbl == CNLabelPhoneNumberiPhone {
                        detailsArray.add("Phone (Home): \(homePh.value(forKeyPath: "digits") as! String)")
                    } else if homePhlbl == CNLabelPhoneNumberMobile {
                        detailsArray.add("Phone (Mobile): \(homePh.value(forKeyPath: "digits") as! String)")
                    } else if homePhlbl == CNLabelPhoneNumberMain {
                        detailsArray.add("Phone (Work): \(homePh.value(forKeyPath: "digits") as! String)")
                    }
                }
            }
            
            let addresses = contact.postalAddresses
            if !labeledVals.isEmpty {
                for address in addresses {
                    let addVal = address.value
                    
                    if !addVal.street.isEmpty {
                        detailsArray.add("Street: \(addVal.street)")
                    }
                    if !addVal.city.isEmpty {
                        detailsArray.add("City: \(addVal.city)")
                    }
                    if !addVal.state.isEmpty {
                        detailsArray.add("State: \(addVal.state)")
                    }
                    if !addVal.postalCode.isEmpty {
                        detailsArray.add("Zip: \(addVal.postalCode)")
                    }
                    if !addVal.country.isEmpty {
                        detailsArray.add("Country: \(addVal.country)")
                    }
                }
            }
            
            if !contact.urlAddresses.isEmpty {
                let urls = contact.urlAddresses
                let url: String = urls.first?.value as! String
                detailsArray.add("Website: \(url)")
            }
            
            table.reloadData()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBAction
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToContactButtonTapped(_ sender: AnyObject) {
        if scannedData != nil {
            CNContactStore().requestAccess(for: .contacts, completionHandler: { granted, error in
                if (granted) {
                    
                    if self.addToContactDelegate != nil {
                        self.addToContactDelegate.addToContact(shouldAdd: true, WithData: self.scannedData)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            })
        } else {
            print("No data")
        }
    }
        
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = detailsArray.object(at: indexPath.row) as? String
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
}
