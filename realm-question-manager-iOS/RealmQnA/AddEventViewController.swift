//
//  ViewController.swift
//  RealmQnA
//
//  Created by Eunjoo on 2017. 4. 5..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import UIKit
import RealmSwift

class AddEventViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventPath: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func createNewEvent(_ sender: Any) {
        guard let nameText = eventName.text, !nameText.isEmpty else {
            return
        }
        guard let pathText = eventPath.text, !pathText.isEmpty else {
            return
        }
        
        makeEvent(eid: eventPath.text!, name: eventName.text!)
        
        eventName.text = ""
        eventPath.text = ""
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: realm
    
    func makeEvent(eid: String, name:String) {
        let syncServerURL = Constants.syncEventURL
        var config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: syncServerURL))
        config.objectTypes = [Event.self]
                
        let realm = try! Realm(configuration: config)
        let events = realm.objects(Event.self)
                
        for event in events {
            print(event.name)
                    
            if event.id == eid {
                print("same event \(eid) is already exists")
                let alert = UIAlertController(title: "Try again", message: "same event \(eid) is already exists", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
        }
                
        let newEvent = Event(value: [eid, true, Date(), name])
                
        try! realm.write {
            realm.add(newEvent)
        }
                
        self.useQuestionRealm(eid: eid)
    }
    
    func useQuestionRealm(eid:String) {
        let baseURL = "\(Constants.syncQuestionURL)\(eid)"
                
        let syncServerURL = URL(string: baseURL)!
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: syncServerURL))
                
        let realm = try! Realm(configuration: config)
        let questions = realm.objects(Question.self)
                
        for question in questions {
            print(question.question)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}



