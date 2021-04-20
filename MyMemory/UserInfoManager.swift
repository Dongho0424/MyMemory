//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/18.
//

import Alamofire
import UIKit

struct UserInfoKey {
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial  = "TUTORIAL"
}

class UserInfoManager {
    // MARK: - Computable Properties
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
        let tk = Token()
        if self.loginId == 0 || self.account == nil || tk.authorizationHeader == nil {
            return false
        } else {
            return true
        }
    }
    
    // MARK: - Login
    
    func login(account: String, password: String, success: (() -> Void)? = nil, fail: ((String) -> Void)? = nil) {
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        
        // login request
        let userAccount = UserAccount(account: account, passwd: password)
        let call = AF.request(url, method: .post, parameters: userAccount, encoder: JSONParameterEncoder.default)
        
        // login resonse
        call.responseDecodable(of: LoginRes.self){ res in
            switch res.result {
            case .success(let value):
                let resultCode = value.resultCode
                if resultCode == 0 {
                    let user = value.userInfo!
                    self.loginId = user.userId
                    self.account = user.account
                    self.name = user.name
                    if let path = user.profilePath, let imageData = try? Data(contentsOf: URL(string: path)!) {
                        print("profile image available")
                        self.profile = UIImage(data: imageData)
                    }
                    
                    // get Token info
                    let accessToken = value.accessToken!
                    let refreshToken = value.refreshToken!
                    
                    // save Token info to key chain
                    let token = Token()
                    token.save(TokenInfo.serviceId, account: TokenInfo.accessToken, value: accessToken)
                    token.save(TokenInfo.serviceId, account: TokenInfo.refreshToken, value: refreshToken)
                    
                    success?()
                } else {
                    let msg = value.errorMsg
                    fail?(msg)
                }
            case .failure(let err):
                print(err)
                fail?("decode fail")
                return
            }
        }
    }
    
    // MARK: - Logout
    
    func logout(completion: (() -> Void)? = nil) {
        // 1. url
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/logout"
        
        // 2. header
        let token = Token()
        let header = token.authorizationHeader
        
        // 3. API 호출 및 응답 처리
        let call = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON { _ in
            self.deviceLogout()
            completion?()
        }
    }
    
    func deviceLogout() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        
        let token = Token()
        token.delete(TokenInfo.serviceId, account: TokenInfo.accessToken)
        token.delete(TokenInfo.serviceId, account: TokenInfo.refreshToken)
    }
    
    // MARK: - New Profile
    
    func newProfile(_ profile: UIImage, success: (() -> Void)? = nil, fail: ((String) -> Void)? = nil) {
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/profile"
        
        // header
        let token = Token()
        let header = token.authorizationHeader
        
        // profile image to send
        let profileData = profile.pngData()?.base64EncodedString()
        let param: Parameters = ["profile_image" : profileData!]
        
        // request
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        
        // response
        call.responseDecodable(of: ImageRes.self) {
            res in
            switch res.result {
            case .success(let value):
                if value.resultCode == 0 {
                    self.profile = profile
                    success?()
                } else {
                    let msg = value.errorMsg
                    fail?(msg)
                }
            case .failure:
                fail?("new profile image decode fail")
            }
        }
    }
}
