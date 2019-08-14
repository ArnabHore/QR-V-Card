//
//  ShowQRIntentHandler.swift
//  QR-BCard
//
//  Created by SlicePay on 19/11/18.
//  Copyright © 2018 Arnab Hore. All rights reserved.
//

import UIKit

class ShowQRIntentHandler: NSObject, ShowQRIntentHandling {
    
    func confirm(intent: ShowQRIntent, completion: @escaping (ShowQRIntentResponse) -> Void) {
        completion(ShowQRIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: ShowQRIntent, completion: @escaping (ShowQRIntentResponse) -> Void) {
        completion(ShowQRIntentResponse.success(title: "Your"))
    }
    

}
