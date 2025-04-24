//
//  User.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 03/04/25.
//

import Foundation

struct UserData: Codable {
    let errorMessage: String?
    let errorCode: String?
    let results: User?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "errorMessage"
        case errorCode = "errorCode"
        case results = "results"
    }
}

struct User: Codable {
    let accessToken: String?
    let category: String?
    let departmentName: String?
    let email: String?
    let employeeId: String?
    let firstName: String?
    let fullName: String?
    let lastName: String?
    let listOfTeamNames: [String]?
    let mappedCustomers: [MappedCustomer]?
    let mappedGroups: [MappedGroup]?
    let mappedScopes: [String]?
    let mappedSegments: [String]?
    let mappedTenants: [String]?
    let message: String?
    let mobilePhone: String?
    let refreshToken: String?
    let userId: Int?
    let userPreference: UserPreference?
    let userType: String?
    let username: String?
}

struct MappedCustomer: Codable {
    let customerCode: String?
    let customerName: String?
    let fkTenantId: Int?
    let mappedGroups: String?
    let pkCustomerId: Int?
}

struct MappedGroup: Codable {
    let customerId: Int?
    let customerName: String?
    let firstName: String?
    let lastName: String?
    let siteGroupId: Int?
    let siteGroupName: String?
    let siteId: Int?
    let siteName: String?
    let tenantId: Int?
    let tenantName: String?
    let title: String?
    let userId: Int?
    let userType: String?
}

struct UserPreference: Codable {
    let menuDefaultCollapsed: Bool?
    let pkUserId: Int?
}
