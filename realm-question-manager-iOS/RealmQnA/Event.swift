//
//  Event.swift
//  RealmQnA
//
//  Created by Eunjoo on 2017. 4. 6..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import Foundation
import RealmSwift

class Event: Object {
    dynamic var id = ""
    dynamic var status = true
    dynamic var date = Date()
    dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
