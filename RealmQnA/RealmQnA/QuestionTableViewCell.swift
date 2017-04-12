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
    @IBOutlet weak var questionVoteImageView: UIImageView!
    @IBOutlet weak var questionIsFavoriteImageView: UIImageView!
}

