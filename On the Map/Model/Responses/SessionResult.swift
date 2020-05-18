//
//  SessionResult.swift
//  On the Map
//
//  Created by Krishnil Bhojani on 16/05/20.
//  Copyright © 2020 Krishnil Bhojani. All rights reserved.
//

import Foundation

struct SessionResult: Codable{
    
    let account: Account
    let session: Session
    
}

struct Account: Codable{
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}


