//
//  MainViewController.swift
//  presensesample
//
//  Created by Ayax Alexis Casarrubias Rodríguez on 26/11/19.
//  Copyright © 2019 Ayax Alexis. All rights reserved.
//
import UIKit

class MainViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Who's Online"
        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = false
        
        // Logout button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutButtonPressed)
        )
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationItem.title = item.title
    }
    
    @objc fileprivate func logoutButtonPressed() {
        viewControllers?.forEach {
            if let vc = $0 as? OnlineTableViewController {
                vc.users = []
                vc.pusher.disconnect()
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
}
