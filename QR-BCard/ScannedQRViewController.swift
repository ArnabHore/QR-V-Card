//
//  ScannedQRViewController.swift
//  QR-BCard
//
//  Created by Arnab Hore on 02/07/17.
//  Copyright © 2017 Arnab Hore. All rights reserved.
//

import UIKit
import Contacts
import CoreData
import ContactsUI

class ScannedQRViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CNContactViewControllerDelegate, AddToContactDelegate {
    @IBOutlet var table: UITableView!
    @IBOutlet var noQrLabel: UILabel!
    @IBOutlet var createNewView: UIView!

    var dataList: [NSManagedObject]! = []
    var scannedData: String!
    var contentType: String! = "text"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if scannedData != nil {
            let types :NSTextCheckingResult.CheckingType = [.link , .phoneNumber]
            
            
            let checkTextType =  try? NSDataDetector(types: types.rawValue )
            
            let matchs = checkTextType?.matches(in: scannedData as String, options: .reportCompletion, range: NSMakeRange(0, (scannedData as String).count))
            
            for match in matchs! {
                print(match.resultType)
                if match.resultType == NSTextCheckingResult.CheckingType.link {
//                    UIApplication.shared.open((NSURL(string: scannedData as String)! as URL), options: [:], completionHandler: nil)
                    contentType = "link"
                    break
                } else if match.resultType == NSTextCheckingResult.CheckingType.phoneNumber {
                    contentType = "phone"
                    break
                }
            }
            print(contentType)
            let contentArray = scannedData.components(separatedBy: ":")
            if contentType == "link" {
                if contentArray.count == 1 || contentArray[0].contains("http") {
                    contentType = "link"
                } else if contentArray[0] == "tel" {
                    contentType = "tel"
                    scannedData = contentArray[1]
                }
            } else if contentType == "text" {
                if contentArray.count == 1 {
                    contentType = "text"
                } else if contentArray[0] == "geo" {
                    contentType = "geo"
                    let newArray = contentArray[1].components(separatedBy: ",")
                    scannedData = "Latitude: \(newArray[0]), Longitude: \(newArray[1])"
                } else if contentArray[0] == "SMSTO" {
                    contentType = "sms"
                    scannedData = "SMS to: \(contentArray[1]), Content: \(contentArray[2])"
                }
            }
            
//            if contentType == "text" {
                let newContentArray = scannedData.components(separatedBy: ":")
                if newContentArray.count > 1 {
                    if newContentArray[0].caseInsensitiveCompare("BEGIN") == ComparisonResult.orderedSame && newContentArray[1].contains("VCARD") {
                        contentType = "phone"
                    }
                }
//            }
            
            self.save(detailsStr: scannedData)
            
            if contentType != nil && contentType == "phone" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "ViewDetails") as! ViewDetailsViewController
                controller.scannedData = scannedData
                controller.addToContactDelegate = self
                controller.modalPresentationStyle = UIModalPresentationStyle.custom
                present(controller, animated:true, completion: nil)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        scannedData = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    @IBAction func createNewTapped(_ sender: AnyObject) {
        tabBarController?.selectedIndex = 1
    }
    
    @IBAction func infoButtonTapped(_ sender: AnyObject) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Info") as? InfoViewController {
            self.present(controller, animated: true, completion: nil)
        }
    }

    // MARK: - AddToContactDelegate
    func addToContact(shouldAdd: Bool, WithData dataStr: String) {
        guard let data = dataStr.data(using: .utf8) else {
            return
        }
        
        let contacts  = try? CNContactVCardSerialization.contacts(with: data)
        
        let contactStore = CNContactStore()
        
        let contactsViewController = CNContactViewController(forNewContact: contacts?[0])
        contactsViewController.contactStore = contactStore
        contactsViewController.delegate = self
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.pushViewController(contactsViewController, animated: true)
    }
    
    // MARK: - CNContactViewControllerDelegate
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        _ = viewController.navigationController?.popViewController(animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Private Methods
    func fetch () {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CardDetails")
        fetchRequest.predicate = NSPredicate(format: "type == %@", "others")    //mine
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullName", ascending: true)]
        
        do {
            dataList = try managedContext.fetch(fetchRequest)
            
            if dataList == nil || dataList.count == 0 {
                table.isHidden = true
                noQrLabel.isHidden = false
                createNewView.isHidden = false
            } else {
                table.isHidden = false
                noQrLabel.isHidden = true
                createNewView.isHidden = true
                self.table.reloadData()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func save(detailsStr: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "CardDetails", in: managedContext)
        let details =  NSManagedObject(entity: entity!, insertInto: managedContext);
        details.setValue(detailsStr, forKey: "details")
        details.setValue(self.getFullName(details: detailsStr), forKey: "fullName")
        details.setValue(false, forKey: "isFav")
        details.setValue("others", forKey: "type")
        details.setValue(contentType, forKey: "contentType")
        details.setValue(Date(), forKey: "createdDate")
        
        do {
            try managedContext.save()
            self.fetch()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getFullName(details: String) -> String {
        if contentType == "phone" {
            guard let data = details.data(using: .utf8) else {
                return ""
            }
            
            let contacts  = try? CNContactVCardSerialization.contacts(with: data)
            let contact: CNContact = (contacts?.first)!
            
            let fullName: String = "\(contact.givenName) \(contact.familyName)"
            
            return fullName
        }
        return "zzzzzDefaultName"
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataList != nil {
            return dataList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let singleData = dataList[indexPath.row]
        
        var fullName: String! = singleData.value(forKey: "fullName") as! String?
        
        let type: String! = singleData.value(forKey: "contentType") as! String?
        if type != "phone" {
            fullName = singleData.value(forKey: "details") as! String?
        }
        
        cell.textLabel?.text = fullName!
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let singleData = dataList[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ViewDetails") as! ViewDetailsViewController
        controller.scannedData = singleData.value(forKeyPath: "details") as! String
        controller.addToContactDelegate = self
        controller.modalPresentationStyle = UIModalPresentationStyle.custom
        present(controller, animated:true, completion: nil)
    }
}
