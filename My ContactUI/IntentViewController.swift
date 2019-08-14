//
//  IntentViewController.swift
//  My ContactUI
//
//  Created by SlicePay on 19/11/18.
//  Copyright © 2018 Arnab Hore. All rights reserved.
//

import IntentsUI
import CoreData

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    @IBOutlet weak var intentQrImageView: UIImageView!
    @IBOutlet weak var intentQrLabel: UILabel!
    @IBOutlet weak var logoSuperView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        self.showImage()
        
        let desiredSize = CGSize(width: self.desiredSize.width, height: self.desiredSize.width)
        completion(true, parameters, desiredSize)
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
    //MARK: - Methods
    func showImage() {
        DispatchQueue.main.async {
            let defaults = UserDefaults(suiteName: "group.com.arnab.businesscard.Shared")
            if let qrDataStr = defaults?.value(forKey: "QRData") as? String {
                let data = qrDataStr.data(using: String.Encoding(rawValue: String.Encoding.isoLatin1.rawValue), allowLossyConversion: false)

                let filter = CIFilter(name: "CIQRCodeGenerator")!

                filter.setValue(data, forKey: "inputMessage")
                filter.setValue("Q", forKey: "inputCorrectionLevel")

                if let img = filter.outputImage {
                    let scaleX: CGFloat = 3.98//self.desiredSize.width / img.extent.size.width
                    let scaleY: CGFloat = 3.98//self.desiredSize.height / img.extent.size.height

                    let transformedImage = img.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

                    let image = UIImage(ciImage: transformedImage)
                    self.intentQrImageView.image = image
                }
            }
            
//            if let loc = defaults?.value(forKey: "ImgLocation") as? String {
//                self.intentQrImageView.image = UIImage(contentsOfFile: loc)
//            }

//            let image = self.getSavedImage(named: "qr.png")
//            self.intentQrImageView.image = image
//            self.logoSuperView.isHidden = false
//            self.intentQrLabel.isHidden = true

//            let qr = QRData()
//            if let image = qr.fetchData() {
//                self.intentQrImageView.image = image
//                self.logoSuperView.isHidden = false
//                self.intentQrLabel.isHidden = true
//            } else {
//                self.intentQrLabel.text = "No QR code found"
//                self.logoSuperView.isHidden = true
//                self.intentQrLabel.isHidden = false
//            }
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            print(dir)
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
//    func getSavedImage(named: String) -> UIImage? {
//        let qrVc = MyQRViewController()
        
//        if let directory = UserDefaults.standard.value(forKey: "IntentQrImageLocation") as? Data,
//            let dir = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(directory) as? URL {
//            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
//        }
//        return nil
//    }

    
}
