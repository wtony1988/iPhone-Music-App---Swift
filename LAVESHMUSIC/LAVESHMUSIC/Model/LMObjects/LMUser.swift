//
//  LMUser.swift
//  LAVESHMUSIC
//
//  Created by Admin on 1/25/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import Firebase

class LMUser: NSObject {
    
    var uid: String?
    var username: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    var company: String?
    var userAvatarURL: URL?
    
    required override init() {
    }
    
    func setUser(withDataSnapshot: DataSnapshot) {
        let value = withDataSnapshot.value as? NSDictionary
        
        uid = value?["uid"] as? String
        username = value?["username"] as? String
        firstName = value?["first_name"] as? String
        lastName = value?["last_name"] as? String
        email = value?["email"] as? String
        phone = value?["phone"] as? String
        company = value?["company_name"] as? String
        
        if ((value?["user_photo"]) != nil) {
            userAvatarURL = URL(string: value?["user_photo"] as! String)
        }
        else {
            userAvatarURL = URL(string: "")

        }
    }
    
    func setUser(withUserDataDic: [String : Any]) {
        uid = withUserDataDic["uid"] as? String
        username = withUserDataDic["username"] as? String
        firstName = withUserDataDic["first_name"] as? String
        lastName = withUserDataDic["last_name"] as? String
        email = withUserDataDic["email"] as? String
        phone = withUserDataDic["phone"] as? String
        company = withUserDataDic["company_name"] as? String
        userAvatarURL = URL(string: withUserDataDic["user_photo"] as! String)

    }

}
