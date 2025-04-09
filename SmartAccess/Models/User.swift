//
//  User.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 03/04/25.
//

import Foundation

struct User: Codable {
    let errorMessage: String
    let errorCode: String
    var results: Results

    enum CodingKeys: String, CodingKey {
        case errorMessage
        case errorCode
        case results
    }
}

struct Results: Codable {
    let accessToken: String
    let category: String
    let departmentName: String
    let email: String
    let employeeId: String
    let firstName: String
    let fullName: String
    let lastName: String
    let listOfTeamNames: [String]
    let mappedCustomers: [MappedCustomer]
    let mappedGroups: [MappedGroup]
    let mappedScopes: [String]
    let mappedSegments: [String]
    let mappedTenants: [String]
    let message: String
    let mobilePhone: String
    let refreshToken: String
    let userId: Int
    let userPreference: UserPreference
    let userType: String
    let username: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken) ?? ""
        self.category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        self.departmentName = try container.decodeIfPresent(String.self, forKey: .departmentName) ?? ""
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.employeeId = try container.decodeIfPresent(String.self, forKey: .employeeId) ?? ""
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        self.listOfTeamNames = try container.decodeIfPresent([String].self, forKey: .listOfTeamNames) ?? []
        self.mappedCustomers = try container.decodeIfPresent([MappedCustomer].self, forKey: .mappedCustomers) ?? []
        self.mappedGroups = try container.decodeIfPresent([MappedGroup].self, forKey: .mappedGroups) ?? []
        self.mappedScopes = try container.decodeIfPresent([String].self, forKey: .mappedScopes) ?? []
        self.mappedSegments = try container.decodeIfPresent([String].self, forKey: .mappedSegments) ?? []
        self.mappedTenants = try container.decodeIfPresent([String].self, forKey: .mappedTenants) ?? []
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        self.mobilePhone = try container.decodeIfPresent(String.self, forKey: .mobilePhone) ?? ""
        self.refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken) ?? ""
        self.userId = try container.decodeIfPresent(Int.self, forKey: .userId) ?? 0
        self.userPreference = try container.decode(UserPreference.self, forKey: .userPreference)
        self.userType = try container.decodeIfPresent(String.self, forKey: .userType) ?? ""
        self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
    }
}

struct MappedCustomer: Codable {
    let customerCode: String
    let customerName: String
    let fkTenantId: Int
    let mappedGroups: String?
    let pkCustomerId: Int
}

struct MappedGroup: Codable {
    let customerId: Int
    let customerName: String
    let firstName: String?
    let lastName: String?
    let siteGroupId: Int?
    let siteGroupName: String?
    let siteId: Int?
    let siteName: String?
    let tenantId: Int
    let tenantName: String
    let title: String
    let userId: Int
    let userType: String
}

struct UserPreference: Codable {
    let menuDefaultCollapsed: Bool
    let pkUserId: Int
}
