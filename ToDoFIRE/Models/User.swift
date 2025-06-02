//
//  User.swift
//  ToDoFIRE
//
//  Created by Zhanibek Bakyt on 05.02.2025.
//

import Foundation
import FirebaseAuth

struct User {
    let uid: String
    let email: String
    
    init(user: FirebaseAuth.User) {
        self.uid = user.uid
        self.email = user.email ?? ""
    }
}
