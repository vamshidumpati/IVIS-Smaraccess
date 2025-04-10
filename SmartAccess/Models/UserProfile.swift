//
//  UserProfile.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 10/04/25.
//

import Foundation

struct UserProfile : Codable {
    let results : Userinfo?
    let errorMessage : String?
    let errorCode : String?

    enum CodingKeys: String, CodingKey {

        case results = "results"
        case errorMessage = "errorMessage"
        case errorCode = "errorCode"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        results = try values.decodeIfPresent(Userinfo.self, forKey: .results)
        errorMessage = try values.decodeIfPresent(String.self, forKey: .errorMessage)
        errorCode = try values.decodeIfPresent(String.self, forKey: .errorCode)
    }
}

struct Userinfo : Codable {
    let pkUserId : Int?
    let username : String?
    let email : String?
    let name : String?
    let firstName : String?
    let middleName : String?
    let lastName : String?
    let mobilePhone : String?
    let employeeId : String?
    let cityObj : String?
    let stateObj : String?
    let countryObj : CountryObj?
    let pincode : String?
    let aadhaarNo : String?
    let panNo : String?
    let gender : String?
    let dateOfJoin : String?
    let latitude : String?
    let longitude : String?
    let address : String?
    let profileStatus : String?
    let department : String?
    let teams : [String]?
    let accessCode : String?
    let deviceId : String?
    let dateOfBirth : String?
    let userProfileRequest : UserProfileRequest?

    enum CodingKeys: String, CodingKey {

        case pkUserId = "pkUserId"
        case username = "username"
        case email = "email"
        case name = "name"
        case firstName = "firstName"
        case middleName = "middleName"
        case lastName = "lastName"
        case mobilePhone = "mobilePhone"
        case employeeId = "employeeId"
        case cityObj = "cityObj"
        case stateObj = "stateObj"
        case countryObj = "countryObj"
        case pincode = "pincode"
        case aadhaarNo = "aadhaarNo"
        case panNo = "panNo"
        case gender = "gender"
        case dateOfJoin = "dateOfJoin"
        case latitude = "latitude"
        case longitude = "longitude"
        case address = "address"
        case profileStatus = "profileStatus"
        case department = "department"
        case teams = "teams"
        case accessCode = "accessCode"
        case deviceId = "deviceId"
        case dateOfBirth = "dateOfBirth"
        case userProfileRequest = "userProfileRequest"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pkUserId = try values.decodeIfPresent(Int.self, forKey: .pkUserId)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        middleName = try values.decodeIfPresent(String.self, forKey: .middleName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        mobilePhone = try values.decodeIfPresent(String.self, forKey: .mobilePhone)
        employeeId = try values.decodeIfPresent(String.self, forKey: .employeeId)
        cityObj = try values.decodeIfPresent(String.self, forKey: .cityObj)
        stateObj = try values.decodeIfPresent(String.self, forKey: .stateObj)
        countryObj =  try values.decodeIfPresent(CountryObj.self, forKey: .countryObj) 
        pincode = try values.decodeIfPresent(String.self, forKey: .pincode)
        aadhaarNo = try values.decodeIfPresent(String.self, forKey: .aadhaarNo)
        panNo = try values.decodeIfPresent(String.self, forKey: .panNo)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        dateOfJoin = try values.decodeIfPresent(String.self, forKey: .dateOfJoin)
        latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(String.self, forKey: .longitude)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        profileStatus = try values.decodeIfPresent(String.self, forKey: .profileStatus)
        department = try values.decodeIfPresent(String.self, forKey: .department)
        teams = try values.decodeIfPresent([String].self, forKey: .teams)
        accessCode = try values.decodeIfPresent(String.self, forKey: .accessCode)
        deviceId = try values.decodeIfPresent(String.self, forKey: .deviceId)
        dateOfBirth = try values.decodeIfPresent(String.self, forKey: .dateOfBirth)
        userProfileRequest = try values.decodeIfPresent(UserProfileRequest.self, forKey: .userProfileRequest)
    }
}

struct UserProfileRequest : Codable {
    let pkUserProfileRequestId : Int?
    let fkUserId : Int?
    let createdTime : String?
    let actionBy : Int?
    let status : Bool?
    let state : String?
    let imageUrl : String?
    let comments : String?
    let updatedTime : String?

    enum CodingKeys: String, CodingKey {

        case pkUserProfileRequestId = "pkUserProfileRequestId"
        case fkUserId = "fkUserId"
        case createdTime = "createdTime"
        case actionBy = "actionBy"
        case status = "status"
        case state = "state"
        case imageUrl = "imageUrl"
        case comments = "comments"
        case updatedTime = "updatedTime"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pkUserProfileRequestId = try values.decodeIfPresent(Int.self, forKey: .pkUserProfileRequestId)
        fkUserId = try values.decodeIfPresent(Int.self, forKey: .fkUserId)
        createdTime = try values.decodeIfPresent(String.self, forKey: .createdTime)
        actionBy = try values.decodeIfPresent(Int.self, forKey: .actionBy)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl)
        comments = try values.decodeIfPresent(String.self, forKey: .comments)
        updatedTime = try values.decodeIfPresent(String.self, forKey: .updatedTime)
    }

}

struct CountryObj: Codable {
    let id: Int?
    let name: String?
}
