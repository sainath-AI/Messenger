//
//  ViewController.swift
//  Messenger
//
//  Created by Perennial Systems on 14/02/22.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        
    }
    
    // navigating to login .. from this viewcontroller
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn =  UserDefaults.standard.bool(forKey: "logged_in")
        if !isLoggedIn{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc )
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        

    }


}

