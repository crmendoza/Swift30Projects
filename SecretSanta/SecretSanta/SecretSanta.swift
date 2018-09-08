//
//  SecretSanta.swift
//  SecretSanta
//
//  Created by Mendoza, Christine | Roanne | DCSD on 2017/12/06.
//  Copyright © 2017 Mendoza, Christine | Roanne | DCSD. All rights reserved.
//

import Foundation

struct SecretSanta {
    let name: String
//    let email: String
    var giftee: String?
    
    mutating func assignGiftee(_ newGiftee: String) {
        giftee = newGiftee
    }
}
