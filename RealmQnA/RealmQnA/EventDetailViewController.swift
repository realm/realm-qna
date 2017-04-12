//
//  File.swift
//  RealmQnA
//
//  Created by Eunjoo on 2017. 4. 12..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import UIKit
import RealmSwift

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myEvent: Event!
    var questions: Results<Question>!
    var realm: Realm?
    
    @IBOutlet weak var questTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.eventDateLabel.text = dateAsString(date: self.myEvent.date)
        readQuestions()
    
        self.questTableView.delegate = self
        self.questTableView.dataSource = self
    }

    // MARK: - Realm
    
    func readQuestions() {
        let syncQuestionURL = URL(string: "\(Constants.syncQuestionURL)\(String(myEvent.id))")
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: syncQuestionURL!))
        
        realm = try! Realm(configuration: config)
        questions = realm?.objects(Question.self).filter("status = true")
    }
    
    func deleteQuestion(question: Question) {
        try! realm?.write {
            question.status = false
        }
    }
    
    // MARK: - TableView data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(questions.count)
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionsTableCell", for: indexPath) as! QuestionTableViewCell
        let question = questions[indexPath.row]
        
        cell.questionAuthorLabel.text = question.author?.id
        cell.questionDateLabel.text = dateAsString(date: question.date)
        cell.questionTextView.text = question.question
        cell.questionVoteLabel.text = String(question.votes.count)

        if (question.isFavorite) {
            cell.questionIsFavoriteImageView.image = UIImage(named: "like-on")
        } else {
            cell.questionIsFavoriteImageView.image = UIImage(named: "like-off")
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteQuestion(question: questions[indexPath.row])
            tableView.reloadData()
        }
    }
    

    
    func dateAsString(date: Date) -> String {
        
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y.M.d HH:mm"
        let str = dateFormatter.string(from: date as Date)
        return str
    }
    
}
