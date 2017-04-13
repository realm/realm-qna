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
    var notificationToken: NotificationToken? = nil
    var notificationCenter: NotificationCenter? = nil
    var currentUser: User? = nil
    
    @IBOutlet weak var questTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.myEvent.name
        
        prepareRealm()
        upsertUser()
        readQuestions()
    
        self.questTableView.delegate = self
        self.questTableView.dataSource = self
        
        notificationCenter = NotificationCenter.default
        notificationCenter?.addObserver(forName:Notification.Name(rawValue:"questionUpdated"), object:nil, queue:nil) {
            notification in
            self.updateQuest(notification: notification)
        }
    }

    // MARK: - Realm
    
    func prepareRealm() {
        let syncQuestionURL = URL(string: "\(Constants.syncQuestionURL)\(String(myEvent.id))")
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: syncQuestionURL!))
        
        realm = try! Realm(configuration: config)
    }
    
    func readQuestions() {
        questions = realm?.objects(Question.self).filter("status = true")
        
        // Observe Results Notifications
        notificationToken = questions.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let tableView = self?.questTableView else { return }
            
            switch changes {
            case .initial:
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
//                print("notification initial")
                break
                
            case .update(_, let deletions, let insertions, let modifications):
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.endUpdates()
                }
//                print("notification update")
                break
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    func upsertUser() {
        try! realm?.write {
            currentUser = realm?.create(User.self, value: [SyncUser.current!.identity ?? "anomymous"], update: true)
        }
    }
    
    func updateQuest(notification: Notification) {
//        print(notification.userInfo ?? "no userInfo")
        let question = notification.userInfo?["question"] as! Question
        let userInfo = notification.userInfo
        
        if (userInfo?["type"] as! String == "vote") {
            var isVoted = true
            
            try! realm?.write {
                for user in question.votes {
                    if user.id == currentUser?.id {
                        
                        let index = question.votes.index(of: user)
                        question.votes.remove(objectAtIndex: index!)
                        
                        isVoted = false
                    }
                }
                
                if isVoted && (currentUser != nil) {
                    question.votes.append(currentUser!)
                }
            }
        } else if (userInfo?["type"] as! String == "isFavorite") {
            var isFavorite = true
            
            try! realm?.write {
                for user in question.favorites {
                    if user.id == currentUser?.id {
                        
                        let index = question.favorites.index(of: user)
                        question.favorites.remove(objectAtIndex: index!)
                        
                        isFavorite = false
                    }
                }
                
                if isFavorite && (currentUser != nil) {
                    question.favorites.append(currentUser!)
                }
            }
        }
    }
    
    func deleteQuestion(question: Question) {
        try! realm?.write {
            question.status = false
        }
    }
    
    // MARK: - TableView data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(questions.count)
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionsTableCell", for: indexPath) as! QuestionTableViewCell
        let question = questions[indexPath.row]
        
        cell.questionForCell = question
        cell.questionAuthorLabel.text = question.author?.id
        cell.questionDateLabel.text = dateAsString(date: question.date)
        cell.questionTextView.text = question.question
        cell.questionVoteLabel.text = String(question.votes.count)
        cell.questionVoteButton.setBackgroundImage(UIImage(named: "vote-off"), for: .normal)
        cell.questionIsFavoriteButton.setBackgroundImage(UIImage(named: "like-off"), for: .normal)
        
        for vote in question.votes {
            if (vote.id == currentUser?.id) {
                cell.questionVoteButton.setBackgroundImage(UIImage(named: "vote-on"), for: .normal)
                break
            }
            cell.questionVoteButton.setBackgroundImage(UIImage(named: "vote-off"), for: .normal)
        }
        
        for favorite in question.favorites {
            if (favorite.id == currentUser?.id) {
                cell.questionIsFavoriteButton.setBackgroundImage(UIImage(named: "like-on"), for: .normal)
                break
            }
            cell.questionIsFavoriteButton.setBackgroundImage(UIImage(named: "like-off"), for: .normal)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let str = dateFormatter.string(from: date as Date)
        return str
    }
    
    deinit {
        notificationToken?.stop()
    }
}
