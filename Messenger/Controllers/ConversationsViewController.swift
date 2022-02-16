//
//  ViewController.swift
//  Messenger
//
//  Created by Perennial Systems on 14/02/22.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
//        DatabaseManager.shared.test()
        
    }
    
    // navigating to login .. from this viewcontroller
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()

    }
    
   private func validateAuth() {
       if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc )
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }


}

