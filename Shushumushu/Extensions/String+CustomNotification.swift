//
//  String+CustomNotification.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 12.02.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import Foundation

// MARK - Custom UTF-8 codes for notifications

extension String {
    
    static var messageDelivered: String {
        
        let codeUnits: [UInt8] = [1, 2, 3]
        let characters = codeUnits.map { $0.character }
        let messageDelivered = String(characters)
        return messageDelivered
    }
    
    static var messageSeen: String {
        
        let codeUnits: [UInt8] = [3, 2, 1]
        let characters = codeUnits.map { $0.character }
        let messageSeen = String(characters)
        return messageSeen
    }
    
    static var messageSent: String {
        
        let codeUnits: [UInt8] = [2, 1, 3]
        let characters = codeUnits.map { $0.character }
        let messageSent = String(characters)
        return messageSent
    }
}

// MARK - Helpers

extension String {
    
    /// Checks wether the String is a UTF-8 code with a custom notification
    var isCustomNotification: Bool {
        
        return self == String.messageDelivered || self == String.messageSeen || self == String.messageSent
    }
}
