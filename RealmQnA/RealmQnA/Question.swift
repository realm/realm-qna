//
//  Question.swift
//  RealmQnA
//
//  Created by Eunjoo on 2017. 4. 6..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import Foundation
import RealmSwift

class Question: Object {
    dynamic var id = 0
    dynamic var status = true
    dynamic var date = Date()
    dynamic var question = ""
    dynamic var author: User?
    var votes = List<User>()
    var favorites = List<User>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
