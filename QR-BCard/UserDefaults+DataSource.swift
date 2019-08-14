//
//  UserDefaults+DataSource.swift
//  QR-BCard
//
//  Created by SlicePay on 21/11/18.
//  Copyright © 2018 Arnab Hore. All rights reserved.
//

import Foundation
extension UserDefaults {
    
    private static let AppGroup = "group.com.arnab.businesscard.Shared"
    
    enum StorageKeys: String {
        case soupMenu
        case orderHistory
        case voiceShortcutHistory
    }
    
    static let dataSuite = { () -> UserDefaults in
        guard let dataSuite = UserDefaults(suiteName: AppGroup) else {
            fatalError("Could not load UserDefaults for app group \(AppGroup)")
        }
        
        return dataSuite
    }()
}
