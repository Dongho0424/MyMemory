//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/18.
//

import Foundation
import UIKit

struct UserInfoKey {
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
}

class UserInfoManager {
    var loginId: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        set {
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    
    var account: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set {
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    
    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set {
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    
    var profile: UIImage? {
        get {
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: UserInfoKey.profile) {
                return UIImage(data: _profile)
            } else {
                return UIImage(named: "account@2x.jpg")
            }
        }
        set {
            if newValue != nil {
                let ud = UserDefaults.standard
                ud.setValue(newValue?.pngData(), forKey: UserInfoKey.profile)
                ud.synchronize()
            }
        }
    }
    
    var isLogin: Bool {
        if self.loginId == 0 || self.account == nil {
            return false
        } else {
            return true
        }
    }
    
    func login(account: String, password: String) -> Bool {
        if account == "pridesam@snu.ac.kr" && password == "1234" {
            let ud = UserDefaults.standard
            ud.setValue(100, forKey: UserInfoKey.loginId)
            ud.setValue(account, forKey: UserInfoKey.account)
            ud.setValue("dongho", forKey: UserInfoKey.name)
            ud.synchronize()
            
            return true
        } else {
            return false
        }
    }
    
    func logout() -> Bool {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        return true
    }
}
