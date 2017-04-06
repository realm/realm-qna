//
//  ViewController.swift
//  RealmQnA
//
//  Created by Eunjoo on 2017. 4. 5..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        initializeTextFields()
    }

    @IBAction func createNewEvent(_ sender: Any) {
        guard let nameText = eventName.text, !nameText.isEmpty else {
            return
        }
        guard let numberText = eventNumber.text, !numberText.isEmpty else {
            return
        }
        
        makeEvent(eid: (Int(eventNumber.text!))!, name: eventName.text!)
        
        eventName.text = ""
        eventNumber.text = ""
    }
    
    //MARK: realm
    
    func makeEvent(eid: Int, name:String) {
        let syncServerURL = Constants.syncEventURL
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: syncServerURL))
                
        let realm = try! Realm(configuration: config)
        let events = realm.objects(Event.self)
                
        for event in events {
            print(event.name)
                    
            if event.id == eid {
                print("same event %d is already exists")
                return
            }
        }
                
        let newEvent = Event(value: [eid, true, name])
                
        try! realm.write {
            realm.add(newEvent)
        }
                
        self.useQuestionRealm(eid: eid)
    }
    
    func useQuestionRealm(eid:Int) {        
//        var baseURL = "realm://127.0.0.1:9080/~/question-realm"
//        baseURL += String(eid)
        
        let baseURL = "\(Constants.syncQuestionURL)\(String(eid))"
                
        let syncServerURL = URL(string: baseURL)!
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: syncServerURL))
                
        let realm = try! Realm(configuration: config)
        let questions = realm.objects(Question.self)
                
        for question in questions {
            print(question.question)
        }
                
        print("question count: %f", questions.count)

    }
    
    //MARK: textfields
    
    func initializeTextFields() {
        eventNumber.delegate = self
        eventNumber.keyboardType = UIKeyboardType.decimalPad
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String)
        -> Bool {
            if string.characters.count == 0 {
                return true
            }
            
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            switch textField {
            case eventNumber:
                return isNumeric(string: prospectiveText) &&
                    prospectiveText.characters.count <= 8
                
            default:
                return true
            }
    }
    
    func isNumeric(string: String) -> Bool {
        let scanner = Scanner(string: string)
        scanner.locale = NSLocale.current
        return scanner.scanDecimal(nil) && scanner.isAtEnd
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

