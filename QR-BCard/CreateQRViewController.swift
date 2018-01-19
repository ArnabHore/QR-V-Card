//
//  CreateQRViewController.swift
//  QR-BCard
//
//  Created by Arnab Hore on 02/07/17.
//  Copyright © 2017 Arnab Hore. All rights reserved.
//

import UIKit
import Contacts

protocol CreatedQRDelegate {
    func didFinishCreatingWithData(_ qrDataStr: String)
}

class CreateQRViewController: UIViewController, UITextFieldDelegate {
    var createdQRDelegate: CreatedQRDelegate?
    var activeTextField: UITextField!
    
    @IBOutlet var mainScroll: UIScrollView!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var streetTextField: UITextField!
    @IBOutlet var zipTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var countryTextField: UITextField!
    @IBOutlet var companyTextField: UITextField!
    @IBOutlet var emailPersonalTextField: UITextField!
    @IBOutlet var emailBusinessTextField: UITextField!
    @IBOutlet var phonePersonalTextField: UITextField!
    @IBOutlet var phoneMobileTextField: UITextField!
    @IBOutlet var phoneBusinessTextField: UITextField!
    @IBOutlet var websiteTextField: UITextField!
    
    var myData: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        zipTextField.inputAccessoryView = doneToolbar
        phoneMobileTextField.inputAccessoryView = doneToolbar
        phoneBusinessTextField.inputAccessoryView = doneToolbar
        phonePersonalTextField.inputAccessoryView = doneToolbar
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        
        if myData != nil && !myData.isEmpty {
            
            guard let data = myData.data(using: .utf8) else {
                return
            }
            
            let contacts  = try? CNContactVCardSerialization.contacts(with: data)
            let contact: CNContact = (contacts?.first)!
            
            if !contact.givenName.isEmpty {
                firstNameTextField.text = contact.givenName
            }
            
            if !contact.familyName.isEmpty {
                lastNameTextField.text = contact.familyName
            }
            
            if !contact.organizationName.isEmpty {
                companyTextField.text = contact.organizationName
            }
            
            let emails = contact.emailAddresses
            
            if !emails.isEmpty {
                for email in emails {
                    let emailLbl = email.label
                    let emailVal = email.value
                    
                    if emailLbl == CNLabelHome {
                        emailPersonalTextField.text = emailVal as String
                    } else if emailLbl == CNLabelWork {
                        emailBusinessTextField.text = emailVal as String
                    }
                }
            }
            
            let labeledVals = contact.phoneNumbers
            
            if !labeledVals.isEmpty {
                for ph in labeledVals {
                    let homePhlbl = ph.label
                    let homePh = ph.value
                    
                    if homePhlbl == CNLabelHome {
                        phonePersonalTextField.text = (homePh.value(forKeyPath: "digits") as! String)
                    } else if homePhlbl == CNLabelPhoneNumberMobile {
                        phoneMobileTextField.text = (homePh.value(forKeyPath: "digits") as! String)
                    } else if homePhlbl == CNLabelWork {
                        phoneBusinessTextField.text = (homePh.value(forKeyPath: "digits") as! String)
                    }
                }
            }
            
            let addresses = contact.postalAddresses
            if !labeledVals.isEmpty {
                for address in addresses {
                    let addVal = address.value
                    
                    if !addVal.street.isEmpty {
                        streetTextField.text = addVal.street
                    }
                    if !addVal.city.isEmpty {
                        cityTextField.text = addVal.city
                    }
                    if !addVal.state.isEmpty {
                        stateTextField.text = addVal.state
                    }
                    if !addVal.postalCode.isEmpty {
                        zipTextField.text = addVal.postalCode
                    }
                    if !addVal.country.isEmpty {
                        countryTextField.text = addVal.country
                    }
                }
            }
            
            if !contact.urlAddresses.isEmpty {
                let urls = contact.urlAddresses
                let url: String = urls.first?.value as! String
                websiteTextField.text = url
            }
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
    
    @IBAction func createButtonTapped(_ sender: AnyObject) {
        if activeTextField != nil {
            activeTextField.resignFirstResponder()
        }
        
        let contact = createContact()
        
        let data = try? CNContactVCardSerialization.data(with: [contact])
        
        if createdQRDelegate != nil {
            createdQRDelegate?.didFinishCreatingWithData(String(data: data!, encoding: String.Encoding.utf8)!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Method
    func createContact() -> CNContact {
        
        let contact = CNMutableContact()
        
        contact.givenName = firstNameTextField.text!
        contact.familyName = lastNameTextField.text!
        
        let homeEmail = CNLabeledValue(label:CNLabelHome, value:emailPersonalTextField.text! as NSString)
        let workEmail = CNLabeledValue(label:CNLabelWork, value:emailBusinessTextField.text! as NSString)
        contact.emailAddresses = [homeEmail, workEmail]
        
        contact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberMobile,
            value:CNPhoneNumber(stringValue:phoneMobileTextField.text!)),
                                CNLabeledValue(
                                    label:CNLabelPhoneNumberiPhone,
                                    value:CNPhoneNumber(stringValue:phonePersonalTextField.text!)),
                                CNLabeledValue(
                                    label:CNLabelPhoneNumberMain,
                                    value:CNPhoneNumber(stringValue:phoneBusinessTextField.text!))]
        
        let homeAddress = CNMutablePostalAddress()
        homeAddress.street = streetTextField.text!
        homeAddress.city = cityTextField.text!
        homeAddress.state = stateTextField.text!
        homeAddress.postalCode = zipTextField.text!
        homeAddress.country = countryTextField.text!
        contact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
        
        contact.organizationName = companyTextField.text!
        contact.urlAddresses = [CNLabeledValue(label:CNLabelURLAddressHomePage, value:websiteTextField.text! as NSString)]
        return contact
    }
    
    func doneButtonAction() {
        let nextTag: NSInteger = activeTextField.tag + 1
        let nextResponder: UIResponder! = activeTextField.superview!.superview?.viewWithTag(nextTag)
        if nextResponder != nil {
            nextResponder.becomeFirstResponder()
        } else {
            activeTextField.resignFirstResponder()
        }
    }

    // MARK: - Keyboard Notification
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            var contentInset:UIEdgeInsets = mainScroll.contentInset
            contentInset.bottom = keyboardFrame.size.height
            mainScroll.contentInset = contentInset
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        mainScroll.contentInset = contentInset
    }
    
    //MARK: - TextView Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1
        let nextResponder: UIResponder! = textField.superview!.superview?.viewWithTag(nextTag)
        if nextResponder != nil {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }

}
