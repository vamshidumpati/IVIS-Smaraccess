/* 
Copyright (c) 2025 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct VaultResponse: Codable {
    let results: VaultResults?
    let errorMessage: String?
    let errorCode: String?
}

struct VaultResults: Codable {
    let userType: String?
    let ivisVault: IvisVault?
    let ivisVaultConfiguration: IvisVaultConfiguration?
    let ivisVaultInfraSop: IvisVaultInfraSop?
    let mobileFrsValidation: String?
    let primaryUserProfiles: [UserProfile]?
    let secondaryUserProfiles: [UserProfile]?
    let overrideUserProfiles: [UserProfile]?
}

struct IvisVault: Codable {
    let pkVaultId: Int?
    let vaultName: String?
    let fkVaultConfigId: Int?
    let fkProjectId: Int?
    let fkSiteId: Int?
    let fkUnitId: Int?
    let active: String?
    let macId: String?
    let vaultCode: String?
    let vaultDescription: String?
    let createdBy: String?
    let updatedBy: String?
    let createdTime: [Int]?
    let updatedTime: [Int]?
    let vaultConfiguration: VaultConfiguration?
    let unit: Unit?
    let vaultPrimaryUsers: [VaultUser]?
    let vaultSecondaryUsers: [VaultUser]?
    let vaultOverrideUsers: [String]?
}

struct VaultConfiguration: Codable {
    let pkVaultConfigId: Int?
    let vaultConfigurationName: String?
    let active: String?
}

struct Unit: Codable {
    let pkUnitId: Int?
    let unitName: String?
    let active: String?
    let ivisunitId: String?
}

struct VaultUser: Codable {
    let pkUserId: Int?
    let username: String?
    let active: String?
}

struct IvisVaultConfiguration: Codable {
    let pkVaultConfigId: Int?
    let vaultConfigurationName: String?
    let authenticationType: String?
    let vaultEmployeeSop: VaultEmployeeSop?
    let ivisVaultInfraSop: IvisVaultInfraSop?
    let isInfraSop: Bool?
    let isEmployeeSop: Bool?
    let authenticationMethod: String?
    let otpType: String?
    let active: String?
    let project: Project?
    let waitingTimeEscalation: Int?
    let ivisVaultNotificationSop: String?
}

struct VaultEmployeeSop: Codable {
    let pkEmployeeSopId: Int?
    let enableFRS: Bool?
    let isDateOfBirth: Bool?
    let isAccessCode: Bool?
    let isDateOfJoin: Bool?
    let active: String?
}

struct IvisVaultInfraSop: Codable {
    let pkInfraSopId: Int?
    let fkVaultConfigId: String?
    let description: String?
    let autoValidation: Bool?
    let manualValidation: Bool?
    let notes: String?
    let active: String?
    let customerCommandCenter: Bool?
    let infraSopRules: String?
    let cloudInfraSopRules: String?
}

struct Project: Codable {
    let pkProjectId: Int?
    let projectName: String?
    let active: String?
    let fkTenantId: Int?
}

struct UserProfile: Codable {
    let pkUserId: Int?
    let username: String?
    let email: String?
    let name: String?
    let firstName: String?
    let middleName: String?
    let lastName: String?
    let mobilePhone: String?
    let employeeId: String?
    let countryObj: Country?
    let pincode: String?
    let dateOfJoin: String?
    let accessCode: String?
    let dateOfBirth: String?
    let userProfileRequest: UserProfileRequest?
    // Add other properties as needed from your JSON
}

struct Country: Codable {
    let pkCountryId: Int?
    let countryCode: String?
    let countryName: String?
}

