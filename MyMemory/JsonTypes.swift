//
//  JsonTypes.swift
//  MyMemory
//
//  Created by 최동호 on 2021/04/08.
//

import Foundation

struct JoinReq: Codable {
    var account: String
    var passwd: String
    var name: String
    var profileImage: String
    
    enum CodingKeys: String, CodingKey {
        case account, passwd, name
        case profileImage = "profile_image"
    }
}

struct JoinRes: Codable {
    var resultCode: Int
    var result: String
    var errorMsg: String
    var userInfo: JoinUserInfo?
    var expiresIn: Int?
    var refreshToken: String?
    var accessToken: String?
    
    enum CodingKeys: String, CodingKey {
        case result
        case resultCode = "result_code"
        case errorMsg = "error_msg"
        case userInfo = "user_info"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
    }
}

struct JoinUserInfo: Codable {
    var name: String
    var account: String
    var profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case name, account
        case profilePath = "profile_path"
    }
}

struct UserAccount: Codable {
    var account: String
    var passwd: String
}

struct LoginRes: Codable {
    var userInfo: LoginUserInfo?
    var resultCode: Int
    var result: String
    var tokenType: String?
    var expiresIn: Int?
    var refreshToken: String?
    var accessToken: String?
    var errorMsg: String
    
    enum CodingKeys: String, CodingKey {
        case result
        case tokenType = "token_type"
        case resultCode = "result_code"
        case errorMsg = "error_msg"
        case userInfo = "user_info"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
    }
}

struct LoginUserInfo: Codable {
    var name: String
    var account: String
    var userId: Int
    var profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case name, account
        case userId = "user_id"
        case profilePath = "profile_path"
    }
}

struct ImageRes: Codable {
    var resultCode: Int
    var result: String
    var errorMsg: String
    
    enum CodingKeys: String, CodingKey {
        case result
        case resultCode = "result_code"
        case errorMsg = "error_msg"
    }
}

struct SyncReq: Codable {
    var title: String
    var contents: String
    var createDate: String
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case title, contents, image
        case createDate = "create_date"
    }
}

