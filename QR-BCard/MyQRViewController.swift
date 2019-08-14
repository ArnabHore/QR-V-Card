//
//  MyQRViewController.swift
//  QR-BCard
//
//  Created by Arnab Hore on 02/07/17.
//  Copyright © 2017 Arnab Hore. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import Intents

class MyQRViewController: UIViewController, CreatedQRDelegate {
    
    @IBOutlet var imgQRCode: UIImageView!
    @IBOutlet var noQrLabel: UILabel!
    @IBOutlet var createNewView: UIView!
    @IBOutlet var qrSuperView: UIView!
    @IBOutlet var shareButton: UIButton!

    var qrcodeImage: CIImage!
    var dataList: [NSManagedObject]! = []
    var myData: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noQrLabel.isHidden = true
        createNewView.isHidden = true
        
        donateInteraction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.fetch()   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    @IBAction func addNewButtonTapped(_ sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CreateQR") as! CreateQRViewController
        controller.createdQRDelegate = self
        controller.myData = myData != nil ? myData : ""
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func infoButtonTapped(_ sender: AnyObject) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Info") as? InfoViewController {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareTapped(_ sender: AnyObject) {
        if (UserDefaults.standard.value(forKey: "myContact") as? Data) != nil {
            //show options
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Share as contact", style: .default, handler: { (alertAction) in
                self.shareAsContact()
            }))
            actionSheet.addAction(UIAlertAction(title: "Share as QR code", style: .default, handler: { (alertAction) in
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Share") as? ShareViewController {
                    controller.modalPresentationStyle = .custom
                    controller.view.backgroundColor = UIColor.clear
                    controller.qrImage = self.imgQRCode.image
                    self.present(controller, animated: true, completion: nil)
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                actionSheet.popoverPresentationController?.sourceView = self.view
                actionSheet.popoverPresentationController?.sourceRect = shareButton.convert(shareButton.bounds, to: self.view)
            }
            
            self.present(actionSheet, animated: true, completion: nil)
        } else {
            //share as image as contact is not saved in defaults
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Share") as? ShareViewController {
                controller.modalPresentationStyle = .custom
                controller.view.backgroundColor = UIColor.clear
                controller.qrImage = imgQRCode.image
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
        
    // MARK: - Private Method
    func displayQRCodeImage() {
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        let image = UIImage(ciImage: transformedImage)
        imgQRCode.image = image
        let data = image.jpegData(compressionQuality: 1.0)
        let defaults = UserDefaults(suiteName: "Q9QD5LY5L7.group.com.arnab.businesscard.Shared")
        defaults?.set(data, forKey: "QRImageData")
        defaults?.synchronize()
        
//        let qr = QRData()
//        if let image1 = qr.fetchData() {
//            imgQRCode.image = image1
//        } else {
//            imgQRCode.image = nil
//        }
//
//        let isSaved = saveImage(image: image)
//        print(isSaved)
//        let newImg = getSavedImage(named: "qr.png")
//        imgQRCode.image = newImg
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let ciImage = image.ciImage, let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else { return false }

        let image = UIImage(cgImage: cgImage)
        guard let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        let dir = try! NSKeyedArchiver.archivedData(withRootObject: directory, requiringSecureCoding: false)
        let defaults = UserDefaults(suiteName: "group.com.arnab.businesscard.Shared")
        defaults?.set(dir, forKey: "IntentQrImageLocation")
        defaults?.set(directory.absoluteString, forKey: "ImgLocation")
        defaults?.synchronize()
        do {
            try data.write(to: directory.appendingPathComponent("qr.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func fetch () {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CardDetails")
        fetchRequest.predicate = NSPredicate(format: "type == %@", "mine")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "details", ascending: true)]
        
        do {
            dataList = try managedContext.fetch(fetchRequest)
            
            if dataList == nil || dataList.count == 0 {
                imgQRCode.image = nil
                qrcodeImage = nil
                
                noQrLabel.isHidden = false
                createNewView.isHidden = false
                qrSuperView.isHidden = true
                shareButton.isHidden = true
            } else {
                
                let singleData = dataList[dataList.count-1]
                
                let qrDataStr: String! = singleData.value(forKeyPath: "details") as! String?
                
                if qrDataStr == "" {
                    return
                }
                
                myData = qrDataStr
                
                let data = qrDataStr.data(using: String.Encoding(rawValue: String.Encoding.isoLatin1.rawValue), allowLossyConversion: false)

                let filter = CIFilter(name: "CIQRCodeGenerator")!
                
                filter.setValue(data, forKey: "inputMessage")
                filter.setValue("Q", forKey: "inputCorrectionLevel")
                
                qrcodeImage = filter.outputImage
                
                displayQRCodeImage()
                
                noQrLabel.isHidden = true
                createNewView.isHidden = true
                qrSuperView.isHidden = false
                shareButton.isHidden = false
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
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CardDetails")
        fetchRequest.predicate = NSPredicate(format: "type == %@", "mine")  //others

        do {
            let fetchedDataList = try managedContext.fetch(fetchRequest)
            if fetchedDataList.count > 0 {
                //update
                
                fetchedDataList.first?.setValue(detailsStr, forKey: "details")
            } else {
                //save
                
                let entity = NSEntityDescription.entity(forEntityName: "CardDetails", in: managedContext)
                let details =  NSManagedObject(entity: entity!, insertInto: managedContext);
                details.setValue(detailsStr, forKey: "details")
                details.setValue("", forKey: "fullName")
                details.setValue(false, forKey: "isFav")
                details.setValue("mine", forKey: "type")
                details.setValue("", forKey: "contentType")
                details.setValue(Date(), forKey: "createdDate")
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error {
            print("Could not fetch \(error) \(error.localizedDescription)")
        }
    }
    
    func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = qrSuperView.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
    
    
    func shareAsContact() {
        if let myContactData = UserDefaults.standard.value(forKey: "myContact") as? Data,
            let myContact = NSKeyedUnarchiver.unarchiveObject(with: myContactData) as? CNContact {
            
            let contact: CNContact = myContact
            
            let fileManager = FileManager.default
            let cacheDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let fileLocation = cacheDirectory.appendingPathComponent("\(CNContactFormatter().string(from: contact)!).vcf")
            
            let contactData = try! CNContactVCardSerialization.data(with: [contact])
            do {
                try contactData.write(to: fileLocation, options: .atomicWrite)
            } catch {
                print("catch")
            }
            
            let activityVC = UIActivityViewController(activityItems: [fileLocation], applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityVC.popoverPresentationController?.sourceView = self.view
                activityVC.popoverPresentationController?.sourceRect = shareButton.convert(shareButton.bounds, to: self.view)
            }
            present(activityVC, animated: true, completion: nil)
        }
    }
    
    func donateInteraction() {
        let intent = ShowQRIntent()
        
        intent.suggestedInvocationPhrase = "Show QR"
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { (error) in
            if let error = error as NSError? {
                print("Interaction Donation Failed: \(error)")
            } else {
                print("Donation successful")
            }
        }
    }
    
    // MARK: - CreatedQRDelegate
    func didFinishCreatingWithData(_ qrDataStr: String) {
        print(qrDataStr)
        if !qrDataStr.isEmpty {
            qrcodeImage = nil
        }
        
        if qrcodeImage == nil {
            if qrDataStr == "" {
                return
            }
            let defaults = UserDefaults(suiteName: "group.com.arnab.businesscard.Shared")
            defaults?.set(qrDataStr, forKey: "QRData")
            
            let data = qrDataStr.data(using: String.Encoding(rawValue: String.Encoding.isoLatin1.rawValue), allowLossyConversion: false)

            let filter = CIFilter(name: "CIQRCodeGenerator")!
            
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter.outputImage
            
            displayQRCodeImage()
            
            noQrLabel.isHidden = true
            createNewView.isHidden = true
            qrSuperView.isHidden = false
            shareButton.isHidden = false
            
            self.save(detailsStr: qrDataStr)
        }
        else {
            imgQRCode.image = nil
            qrcodeImage = nil
            
            noQrLabel.isHidden = false
            createNewView.isHidden = false
            qrSuperView.isHidden = true
            shareButton.isHidden = true
        }
    }
}
