////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import UIKit
import RealmSwift

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myEvent: Event!
    var questions: Results<Question>!
    var realm: Realm? = nil
    var notificationToken: NotificationToken? = nil
    var notificationCenter: NotificationCenter? = nil
    var currentUser: User? = nil
    
    @IBOutlet weak var questTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.title = self.myEvent.name
        
        prepareRealm()
        upsertUser()
        readQuestions()
        
        self.questTableView.delegate = self
        self.questTableView.dataSource = self
        
        prepareController()
    }
    
    func prepareController() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit Name", style: .plain, target: self, action: #selector(editTapped))

        notificationCenter = NotificationCenter.default
        notificationCenter?.addObserver(forName:Notification.Name(rawValue:"questionUpdated"), object:nil, queue:nil) {
            notification in
            self.updateQuest(notification: notification)
        }
        
        self.questTableView.rowHeight = UITableViewAutomaticDimension
        self.questTableView.estimatedRowHeight = 120
    }
    
    func editTapped() {
        let alert = UIAlertController(title: "Edit Event name", message: "Enter a new name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = self.navigationItem.title }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            if (textField != nil) && (textField?.text != nil) {
                self.navigationItem.title = textField?.text
                self.updateEvent(name: (textField?.text)!)
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Realm
    
    func prepareRealm() {
        print("event: \(myEvent.id)")
        let syncQuestionURL = URL(string: "\(Constants.syncQuestionURL)\(myEvent.id)")
        var config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: syncQuestionURL!))
        config.objectTypes = [User.self, Question.self]
        
        realm = try! Realm(configuration: config)
    }
    
    func readQuestions() {
        let sortProperties = [SortDescriptor(keyPath: "isAnswered", ascending: true), SortDescriptor(keyPath: "isFavorite", ascending: false),SortDescriptor(keyPath: "voteCount", ascending: false)]
        
        questions = realm?.objects(Question.self).filter("status = true").sorted(by: sortProperties)
        notificationToken = questions.observe { [weak self] (changes: RealmCollectionChange) in
            
            guard let tableView = self?.questTableView else { return }
            
            switch changes {
            case .initial:
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
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
                break
                
            case .error(let error):
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
        let question = notification.userInfo?["question"] as! Question
        let userInfo = notification.userInfo
        
        if (userInfo?["type"] as! String == "vote") {
            var isVoted = true
            
            try! realm?.write {
                for user in question.votes {
                    if user.id == currentUser?.id {
                        let index = question.votes.index(of: user)
                        question.votes.remove(at: index!)
                        question.voteCount = question.voteCount - 1
                        isVoted = false
                    }
                }
                
                if isVoted && (currentUser != nil) {
                    question.votes.append(currentUser!)
                    question.voteCount = question.voteCount + 1
                }
            }
        } else if (userInfo?["type"] as! String == "isFavorite") {
            try! realm?.write {
                question.isFavorite = !question.isFavorite
            }
        } else if (userInfo?["type"] as! String == "isAnswered") {
            try! realm?.write {
                question.isAnswered = !question.isAnswered
            }
        }
    }
    
    func deleteQuestion(question: Question) {
        realm?.beginWrite()
        question.status = false
        try! realm?.commitWrite(withoutNotifying: [notificationToken!])
    }
    
    func updateEvent(name: String) {
        // TODO: add schema somewhere!
        let syncServerURL = Constants.syncEventURL
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: syncServerURL))
        
        let eventRealm = try! Realm(configuration: config)
        
        try! eventRealm.write {
            myEvent.name = name
        }
    }
    
    // MARK: - TableView data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionsTableCell", for: indexPath) as! QuestionTableViewCell
        let question = questions[indexPath.row]
        
        if question.isAnswered {
            cell.questionBackgroundView.backgroundColor = UIColor(displayP3Red: 0.1, green: 0.1, blue: 0.1, alpha: 0.6)
        } else {
            cell.questionBackgroundView.backgroundColor = color(forRow: indexPath.row)
        }
        cell.questionForCell = question
        cell.questionAuthorLabel.text = question.author?.id
        cell.questionDateLabel.text = dateAsString(date: question.date)
        cell.questionTextLabel.text = question.question
        cell.questionVoteLabel.text = String(question.voteCount)
        cell.questionVoteButton.setBackgroundImage(UIImage(named: "vote-off"), for: .normal)
        cell.questionIsFavoriteButton.setBackgroundImage(UIImage(named: "like-off"), for: .normal)
        
        for vote in question.votes {
            if (vote.id == currentUser?.id) {
                cell.questionVoteButton.setBackgroundImage(UIImage(named: "vote-on"), for: .normal)
                break
            }
            cell.questionVoteButton.setBackgroundImage(UIImage(named: "vote-off"), for: .normal)
        }
        
        if question.isFavorite {
            cell.questionIsFavoriteButton.setBackgroundImage(UIImage(named: "like-on"), for: .normal)
        } else {
            cell.questionIsFavoriteButton.setBackgroundImage(UIImage(named: "like-off"), for: .normal)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let answer = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Answer") { (action , indexPath ) -> Void in
            self.isEditing = false
            NotificationCenter.default.post(name:Notification.Name(rawValue:"questionUpdated"), object: nil, userInfo: ["question": self.questions[indexPath.row], "type": "isAnswered"])
        }
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete") { (action , indexPath) -> Void in
            self.isEditing = false
            self.deleteQuestion(question: self.questions[indexPath.row])
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        return [answer, delete]
    }

    func dateAsString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let str = dateFormatter.string(from: date as Date)
        return str
    }
    
    func closeRealm() {
        print("closeRealm")
        realm = nil
        notificationToken?.invalidate()
        notificationCenter?.removeObserver(self, name: Notification.Name(rawValue:"questionUpdated"), object: nil)
    }
    
    func color(forRow row: Int) -> UIColor {
        let fraction = Double(row) / Double(max(13, questions.count))
        return UIColor.taskColors().gradientColor(atFraction: fraction)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeRealm()
    }
    
    deinit {
        closeRealm()
    }
}
