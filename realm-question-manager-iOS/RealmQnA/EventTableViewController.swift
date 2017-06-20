//
//  EventTableViewController.swift
//  RealmQnA
//
//  Created by Eunjoo Im on 2017. 4. 11..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import UIKit
import RealmSwift

class EventTableViewController: UITableViewController {
    
    var events: Results<Event>!
    var notificationToken: NotificationToken? = nil
    var notificationCenter: NotificationCenter? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareController()
        readEvents()
    }
    
    func prepareController() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Event", style: .plain, target: self, action: #selector(addTapped))
    }
    
    func addTapped() {
        let addViewController = self.storyboard!.instantiateViewController(withIdentifier: "addEventViewController") as! AddEventViewController
        self.navigationController!.pushViewController(addViewController, animated: true)
    }
    
    func readEvents() {
        let syncServerURL = Constants.syncEventURL
        var config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: syncServerURL))
        config.objectTypes = [Event.self]
        
        let realm = try! Realm(configuration: config)
        events = realm.objects(Event.self).filter("status = true")
        
        // Observe Results Notifications
        notificationToken = events.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            print("Realm Notification")
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
                print("notification initial")
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
                
                print("notification update")
                break
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    // MARK: - TableView data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventTableViewCell", for: indexPath) as! EventTableViewCell
        
        cell.backgroundColor = color(forRow: indexPath.row)
        cell.eventNameLable.text = events[indexPath.row].name
        cell.eventDateLable.text = String(events[indexPath.row].id)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        detailViewController.myEvent = events[indexPath.row]
        self.navigationController!.pushViewController(detailViewController, animated: true)
    }
    
    func color(forRow row: Int) -> UIColor {
        let fraction = Double(row) / Double(max(13, events.count))
        return UIColor.listColors().gradientColor(atFraction: fraction)
    }
    
    deinit {
        notificationToken?.stop()
        notificationCenter?.removeObserver(self, name: Notification.Name(rawValue:"eventAdded"), object: nil)
    }
}
