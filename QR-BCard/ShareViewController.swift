//
//  ShareViewController.swift
//  QR-BCard
//
//  Created by SlicePay on 19/08/18.
//  Copyright © 2018 Arnab Hore. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {
    @IBOutlet weak var mainSuperView: UIView!
    @IBOutlet weak var qrImageView: UIImageView!
    var qrImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        qrImageView.image = qrImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func shareTapped(_ sender: UIButton) {
        if let img = takeScreenshot(false) {
//            let text = """
//        Hey, please scan this QR with your iOS device camera and save my contact details on your iOS device.
//        
//        Download the app: https://itunes.apple.com/us/app/get-my-contact/id1420548798
//        """
            let activityItems = [img] as [Any]
            let shareViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            shareViewController.popoverPresentationController?.sourceView = self.view
            self.present(shareViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = mainSuperView.layer
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


}
