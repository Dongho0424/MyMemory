//
//  Token.swift
//  MyMemory
//
//  Created by 최동호 on 2021/04/10.
//

import Alamofire
import Security

struct TokenInfo {
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
    static let serviceId = "kr.co.rubypaper.MyMemory"
}

class Token {
    
    var authorizationHeader: HTTPHeaders? {
        if let accessToken = self.load(TokenInfo.serviceId, account: TokenInfo.accessToken) {
            return ["Authorization" : "Bearer \(accessToken)"] as HTTPHeaders
        } else {
            return nil
        }
    }
    
    func save(_ service: String, account: String, value: String) {
        // 1. keychain query define
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: value.data(using: .utf8, allowLossyConversion: false)!
        ]
        
        // 2. delete current keychain value
        SecItemDelete(keyChainQuery)
        
        // 3. add new key chain item
        let status: OSStatus = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr)
        NSLog("status=\(status)",  "토큰 값 저장에 실패했습니다.")
    }
    
    // 키 체인에 저장된 값을 읽어오는 메소드
    func load(_ service: String, account: String) -> String? {
        // 1. keychain query define
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        // 2. read value stored in key chain
        var data: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keyChainQuery, &data)
        
        // 3.
        if status == errSecSuccess {
            let retrievedData = data as! Data
            let value = String(data: retrievedData, encoding: .utf8)
            return value
        } else {
            NSLog("Nothing was retrieved from the keyChain. Status Code is \(status)")
            return nil
        }
    }
    
    func delete(_ service: String, account: String) {
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service
        ]
        
        let status: OSStatus = SecItemDelete(keyChainQuery)
        assert(status == noErr, "토큰 값 삭제에 실패했습니다.")
    }
}
