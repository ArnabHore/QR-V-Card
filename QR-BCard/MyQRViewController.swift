//
//  MyQRViewController.swift
//  QR-BCard
//
//  Created by Arnab Hore on 02/07/17.
//  Copyright © 2017 Arnab Hore. All rights reserved.
//

import UIKit
import CoreData

class MyQRViewController: UIViewController, CreatedQRDelegate {
    
    @IBOutlet var imgQRCode: UIImageView!
    @IBOutlet var noQrLabel: UILabel!
    @IBOutlet var createNewView: UIView!
    
    var qrcodeImage: CIImage!
    var dataList: [NSManagedObject]! = []
    var myData: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noQrLabel.isHidden = true
        createNewView.isHidden = true
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
        
    // MARK: - Private Method
    func displayQRCodeImage() {
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        imgQRCode.image = UIImage(ciImage: transformedImage)
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
                imgQRCode.isHidden = true
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
                imgQRCode.isHidden = false
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
        details.setValue("", forKey: "fullName")
        details.setValue(false, forKey: "isFav")
        details.setValue("mine", forKey: "type")
        details.setValue("", forKey: "contentType")
        details.setValue(Date(), forKey: "createdDate")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: - CreatedQRDelegate
    func didFinishCreatingWithData(_ qrDataStr: String) {
        if !qrDataStr.isEmpty {
            qrcodeImage = nil
        }
        
        if qrcodeImage == nil {
            if qrDataStr == "" {
                return
            }
            
            let data = qrDataStr.data(using: String.Encoding(rawValue: String.Encoding.isoLatin1.rawValue), allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")!
            
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter.outputImage
            
            displayQRCodeImage()
            
            noQrLabel.isHidden = true
            createNewView.isHidden = true
            imgQRCode.isHidden = false
            
            self.save(detailsStr: qrDataStr)
        }
        else {
            imgQRCode.image = nil
            qrcodeImage = nil
            
            noQrLabel.isHidden = false
            createNewView.isHidden = false
            imgQRCode.isHidden = true
        }
    }
}
