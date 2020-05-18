//
//  StudentLocation.swift
//  On the Map
//
//  Created by Krishnil Bhojani on 16/05/20.
//  Copyright © 2020 Krishnil Bhojani. All rights reserved.
//

import Foundation

struct StudentLocationResponse: Codable {

    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String
    let uniqueKey: String
    let updatedAt: String
    
}
