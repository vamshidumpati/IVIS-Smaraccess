//
//  DataStore.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 03/04/25.
//

import Foundation

class DataStore {
    var userAuth: User?
    var userInfo:[String: Any]?
    var accountInfo:[String:Any]?
    var configuration:[String: Any]!
    var releaseNotes:[String:Any]?
    var refreshHome = false
    var timeZone = TimeZone.current.identifier
    var accountId:String?

    static let shared = DataStore()
    private init() { } // prevent creating another instances.
    
    func clearData() {
        userAuth = nil
        userInfo = nil
        configuration = [:]
    }
}
