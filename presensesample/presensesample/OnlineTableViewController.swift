//
//  OnlineTableViewController.swift
//  presensesample
//
//  Created by Ayax Alexis Casarrubias Rodríguez on 26/11/19.
//  Copyright © 2019 Ayax Alexis. All rights reserved.
//

import UIKit
import PusherSwift

struct User {
    let id: String
    var name: String
    var online: Bool = false
    
    init(id: String, name: String, online: Bool? = false) {
        self.id = id
        self.name = name
        self.online = online!
    }
}

class OnlineTableViewController: UITableViewController {
    
    var pusher: Pusher!
    var user: User? = nil
    var users: [User] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "onlineuser", for: indexPath)
        let user = users[indexPath.row]
        
        cell.textLabel?.text = "\(user.name) \(user.online ? "[Online]" : "")"
        
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        
        // Create the Pusher instance...
        pusher = Pusher(
            key: "PUSHER_APP_KEY",
            options: PusherClientOptions(
                authMethod: .endpoint(authEndpoint: "http://127.0.0.1:5000/pusher/auth/presence"),
                host: .cluster("PUSHER_APP_CLUSTER")
            )
        )
        
        // Subscribe to a presence channel...
        let channel = pusher.subscribeToPresenceChannel(
            channelName: "presence-chat",
            onMemberAdded: { member in
                if let info = member.userInfo as? [String: String], let name = info["name"] {
                    if let index = self.users.firstIndex(where: { $0.id == member.userId }) {
                        let userModel = self.users[index]
                        self.users[index] = User(id: userModel.id, name: userModel.name, online: true)
                    } else {
                        self.users.append(User(id: member.userId, name: name, online: true))
                    }
                    
                    self.tableView.reloadData()
                }
        },
            onMemberRemoved: { member in
                if let index = self.users.firstIndex(where: { $0.id == member.userId }) {
                    let userModel = self.users[index]
                    self.users[index] = User(id: userModel.id, name: userModel.name, online: false)
                    self.tableView.reloadData()
                }
        }
        )
        
        // Bind to the subscription succeeded event...
        channel.bind(eventName: "pusher:subscription_succeeded") { data in
            guard let deets = data as? [String: AnyObject],
                let presence = deets["presence"] as? [String: AnyObject],
                let ids = presence["ids"] as? NSArray else { return }
            
            for userid in ids {
                guard let uid = userid as? String else { return }
                
                if let index = self.users.firstIndex(where: { $0.id == uid }) {
                    let userModel = self.users[index]
                    self.users[index] = User(id: uid, name: userModel.name, online: true)
                }
            }
            
            self.tableView.reloadData()
        }
        
        // Connect to Pusher
        pusher.connect()
    }
}

