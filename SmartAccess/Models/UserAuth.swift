//
//  UserAuth.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 03/04/25.
//

import Foundation

struct UserAuth : Codable {
    var accessToken : String?
    var expiresIn: Int?
    var tokenType : String?
    var refreshToken : String?
    var scope: String?
    var isExternalLogin = false
    var clientID = ""

    // keys
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope = "scope"
    }
    
    func saveToUserDefaults() {
        var data:[String : Any] = ["accessToken": self.accessToken as Any, "tokenType": self.tokenType as Any, "refreshToken": self.refreshToken as Any]
        data["scope"] = self.scope
        data["expiresIn"] = self.expiresIn
        data["clientID"] = self.clientID
        UserDefaults.standard.set(data, forKey: "userAuth")
    }
    
    static func loadDataFromDefaults() -> UserAuth?{
        let data = UserDefaults.standard.value(forKey: "userAuth") as? [String:Any]
        if data != nil {
            var objUserAuth = UserAuth()
            objUserAuth.accessToken = data?["accessToken"] as? String
            objUserAuth.expiresIn = data?["expiresIn"] as? Int
            objUserAuth.tokenType = data?["tokenType"] as? String
            objUserAuth.refreshToken = data?["refreshToken"] as? String
            objUserAuth.scope = data?["scope"] as? String
            objUserAuth.isExternalLogin = data?["isExternalLogin"] as? Bool ?? false
            objUserAuth.clientID = data?["clientID"] as? String ?? ""
            return objUserAuth
        }
        return nil
    }
}
