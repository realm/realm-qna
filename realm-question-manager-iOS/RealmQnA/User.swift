//
//  User.swift
//  RealmQnA
//
//  Created by Eunjoo on 2017. 4. 6..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    dynamic var id = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
