//
//  QuestionTableViewCell.swift
//  RealmQnA
//
//  Created by Eunjoo on 2017. 4. 12..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionAuthorLabel: UILabel!
    @IBOutlet weak var questionDateLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var questionVoteLabel: UILabel!
    @IBOutlet weak var questionVoteButton: UIButton!
    @IBOutlet weak var questionIsFavoriteButton: UIButton!
    @IBOutlet weak var questionBackgroundView: UIView!
    
    dynamic var questionForCell: Question? = nil

    @IBAction func questionVoteTapped(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"questionUpdated"), object: nil, userInfo: ["question": questionForCell ?? "noQuestion", "type": "vote"])
    }
    
    @IBAction func questionIsFavoriteTapped(_ sender: Any) {
        NotificationCenter.default.post(name:Notification.Name(rawValue:"questionUpdated"), object: nil, userInfo: ["question": questionForCell ?? "noQuestion", "type": "isFavorite"])
    }
    
    
}

