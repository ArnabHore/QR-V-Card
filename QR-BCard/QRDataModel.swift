//
//  QRDataModel.swift
//  QR-BCard
//
//  Created by SlicePay on 21/11/18.
//  Copyright © 2018 Arnab Hore. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class QRData {
    public func fetchData () -> UIImage? {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CardDetails")
        fetchRequest.predicate = NSPredicate(format: "type == %@", "mine")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "details", ascending: true)]
        
        do {
            let dataList = try managedContext.fetch(fetchRequest)
            
            if dataList == nil || dataList.count == 0 {
                return nil
            } else {
                
                let singleData = dataList[dataList.count-1]
                
                let qrDataStr: String! = singleData.value(forKeyPath: "details") as! String?
                
                if qrDataStr == "" {
                    return nil
                }
                
                let myData = qrDataStr
                
                let data = qrDataStr.data(using: String.Encoding(rawValue: String.Encoding.isoLatin1.rawValue), allowLossyConversion: false)
                
                let filter = CIFilter(name: "CIQRCodeGenerator")!
                
                filter.setValue(data, forKey: "inputMessage")
                filter.setValue("Q", forKey: "inputCorrectionLevel")
                
                let qrcodeImage = filter.outputImage
                
//                let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
//                let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
//
//                let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
                
                let image = UIImage(ciImage: qrcodeImage ?? CIImage())
                
                return image
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "QR_BCard")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
