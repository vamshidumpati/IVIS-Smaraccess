//
//  SiteResponseModel.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 07/04/25.
//

struct SiteResponseModel: Codable {
    let results: SiteResults
    let errorMessage: String?
    let errorCode: String
    
    init() {
        results = SiteResults()
        errorMessage = ""
        errorCode = ""
    }
}

struct SiteResults: Codable {
    let active: Bool
    let activeSites: Int
    let authenticationToken: String
    let company: String
    let firstName: String?
    let id: Int
    let inActiveSites: Int
    let lastName: String?
    let logo: String
    let role: Int
    let roles: String?
    let sitesList: [Site]
    let userId: String
    let userType: String
    
    init() {
        self.active = false
        self.activeSites = 0
        self.authenticationToken = ""
        self.company = ""
        self.firstName = nil
        self.id = 0
        self.inActiveSites = 0
        self.lastName = nil
        self.logo = ""
        self.role = 0
        self.roles = nil
        self.sitesList = []
        self.userId = ""
        self.userType = ""
    }
}

struct Site: Codable {
    let atmIds: String
    let contactNum: String
    let latitude: String
    let longitude: String
    let numberOfCameras: String
    let project: String
    let siteAccountId: Int
    let siteId: Int
    let siteName: String
    let smAccountId: Int
    let smPotentialId: Int
    let solId: String
    let state: String
    let status: String
    let unitId: Int
    let zone: String
}
