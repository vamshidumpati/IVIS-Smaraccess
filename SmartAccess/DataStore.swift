//
//  DataStore.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 03/04/25.
//

import Foundation

class DataStore {
    var userAuth: User?
    var userInfo:Userinfo?
    var vaultData:VaultResults?
    var accountId:String?
    var siteData:SiteResults?

    static let shared = DataStore()
    private init() { } // prevent creating another instances.
    
    func clearData() {
        userAuth = nil
        userInfo = nil
        accountId = nil
        //vaultData = nil
        siteData = nil
    }
}
