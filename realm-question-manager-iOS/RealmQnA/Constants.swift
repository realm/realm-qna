//
//  Constants.swift
//  RealmQnA
//
//  Created by Eunjoo on 2017. 4. 6..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import Foundation

struct Constants {
    // add host here
    static let syncHost = ""

    static let syncAuthURL = URL(string: "http://\(syncHost):9080")!
    static let syncEventURL = URL(string: "realm://\(syncHost):9080/qna/event-realm")!
    static let syncQuestionURL = "realm://\(syncHost):9080/qna/question-realm"
    
    static let appID = Bundle.main.bundleIdentifier!
}
