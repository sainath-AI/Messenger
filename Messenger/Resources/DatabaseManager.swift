//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Perennial Systems on 16/02/22.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    
    // MARK: - Account Management
    
}
    extension DatabaseManager {
        
    public func userExists(with email: String , completion : @escaping ((Bool) -> Void))
    {
        
        var safeEmails = email.replacingOccurrences(of: ".", with: "-")
        safeEmails = safeEmails.replacingOccurrences(of: "@", with: "-")

        database.child(safeEmails).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
              completion(false)
                return
            }
            completion(true)
        })
    }
    
    // insert new User to database
    public func insertUser(with user: ChatAppUser){
        
        database.child(user.safeEmails).setValue(["first_name": user.firstName,
                                                    "last_name": user.lastName])
    }
  
}
struct  ChatAppUser {
    
    let firstName: String
    let lastName: String
    let emailAddress : String
    
    var safeEmails: String{
        
     var safeEmails = emailAddress.replacingOccurrences(of: ".", with: "-")
    safeEmails = safeEmails.replacingOccurrences(of: "@", with: "-")
    return safeEmails
    }
 //   let profilePictureUrl: String
}
