//
//  NetworkManager.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 03/04/25.
//

import Foundation
import UIKit

class NetworkManager: NSObject {
    static let grantType = Environment.grantType
    static let apiVersion = Environment.apiVersion
    static let apiAppToken = Environment.apiAppToken
    static let refreshToken = Environment.refreshToken
    
    static func call(payLoadFlag: Bool = false, route: String, requestType: String, requestBody: [String: Any]?,
                    MultipartRequest: Bool? = false, includeAuthHeaders: Bool = true, completionBlock: @escaping (_ error: String?, _ result: Any?) -> Void) -> Void {
        
        let baseUrl = Environment.baseURL.absoluteString
        
        guard let endpointUrl = URL(string: baseUrl + route) else {
            completionBlock("Invalid URL", nil)
            return
        }
        
        var request = URLRequest(url: endpointUrl)
        request.timeoutInterval = 200
        request.httpMethod = requestType
        
        // Set common headers
        let customerID = DataStore.shared.userAuth?.results.mappedCustomers[0].pkCustomerId
        let fkTenantId = DataStore.shared.userAuth?.results.mappedCustomers[0].fkTenantId
        request.setValue(fkTenantId?.description ?? "null", forHTTPHeaderField: "Tenant-Id")
        request.setValue(customerID?.description ?? "null", forHTTPHeaderField: "Customer-Id")
        
        if MultipartRequest == false {
            // Original JSON request handling
            let siteID = DataStore.shared.userAuth?.results.mappedGroups[0].siteId
            let siteGroupID = DataStore.shared.userAuth?.results.mappedGroups[0].siteGroupId
            let loginID = DataStore.shared.userAuth?.results.username
            let accessToken = DataStore.shared.userAuth?.results.accessToken ?? ""
            
            request.setValue(siteGroupID?.description ?? "null", forHTTPHeaderField: "Sitegroup-Id")
            request.setValue(loginID?.description ?? "null", forHTTPHeaderField: "Login-Id")
            request.setValue(siteID?.description ?? "null", forHTTPHeaderField: "Site-Id")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            print("accessToken",accessToken)

            if payLoadFlag {
                if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody as Any, options: .prettyPrinted) {
                    request.httpBody = jsonData
                    let length = "\(jsonData.count)"
                    request.addValue(length, forHTTPHeaderField: "Content-Length")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue(DataStore.shared.accountId ?? "", forHTTPHeaderField: "Customer-Name")
                }
            } else {
                if requestType == "POST" || requestType == "PUT" {
                    let jsonData = try? JSONSerialization.data(withJSONObject: requestBody ?? [:])
                    request.httpBody = jsonData
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue(DataStore.shared.accountId ?? "", forHTTPHeaderField: "Customer-Name")
                }
            }
        } else {
            // Multipart Form Data Handling
            let boundary = "Boundary-\(UUID().uuidString)"
            var body = Data()
            
            // Add authorization headers if needed
            if includeAuthHeaders {
                let accessToken = DataStore.shared.userAuth?.results.accessToken ?? ""
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            // Process each parameter in the request body
            requestBody?.forEach { key, value in
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            // Close the multipart form data
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionBlock(error.localizedDescription, nil)
                    return
                }
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    completionBlock("Invalid response", nil)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    completionBlock(nil, data)
                case 401 where includeAuthHeaders:
                    if let data = data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                            let message = NetworkManager.errorFromResponse(res: res)
                            completionBlock(message, nil)
                        } catch let error {
                            completionBlock(error.localizedDescription, nil)
                        }
                    } else {
                        completionBlock("Unknown Error", nil)
                    }
                    NetworkManager.refreshToken(route: route, requestType: requestType,
                                              requestBody: requestBody, includeAuthHeaders: includeAuthHeaders,
                                              completionBlock: completionBlock)
                default:
                    if let data = data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                            let message = NetworkManager.errorFromResponse(res: res)
                            completionBlock(message, nil)
                        } catch let error {
                            completionBlock(error.localizedDescription, nil)
                        }
                    } else {
                        completionBlock("Unknown Error", nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    static func getMultiPartFormData(params:[String:Any], boundary:String) -> String {
        var body = ""
        for(key, value) in params {
            body += convertFormField(named: key, value: value, using: boundary)
        }
        return body
    }
    
    static func convertFormField(named name: String, value: Any, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\""
        fieldString += "\r\n\r\n\(value)\r\n"
        return fieldString
    }
    
    static func getFormData(params:[String:Any]) -> String
    {
        //        var copyPrarams = params
        //        if params.count > 0 {
        //            let langCode = Utils.getLanguageCode()
        //            copyPrarams["context"] = Utils.jsonString(obj: ["lang": langCode])
        //        }
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    static func errorFromResponse(res:[String:Any]?) -> String {
        var message = "Unknown Error"
        if let messageRes = res?["errorMessage"] as? String {
            message = messageRes
        } else if let errorStr = res?["error"] as? String {
            message = errorStr
        }else if let error = res?["error"] as? [String:Any], let errorMessage = error["message"] as? String {
            message = errorMessage
        }
        if let errorStr = res?["arguments"] as? [Any] {
            message = errorStr.count == 0 ? message:errorStr[0] as? String ?? ""
            print(errorStr)
        }
        return message
    }
    
    
    //MARK: - GET User Token
    static func getUserToken(username: String, password:String,accontId:String ,completionBlock: @escaping (_ result: User?, _ error: String?) -> Void) {
        var params = [String:String]()
        var getTokenRoute = ""
        let requestFlag = false
        getTokenRoute = "/api/clogin"
        params = [
            "loginId": username,
            "password": password,
        ]
        self.call(payLoadFlag: requestFlag,route: getTokenRoute, requestType: "POST", requestBody: params, includeAuthHeaders: false) { (error, data) in
            if error != nil {
                completionBlock(nil, error)
                return
            }
            if let data = data {
                do {
                    let res = try JSONDecoder().decode(User.self, from: data as! Data)
                    DataStore.shared.userAuth = res
                    completionBlock(res, nil)
                } catch let error {
                    completionBlock(nil, error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Refresh Token
    static func refreshToken(route:String, requestType: String, requestBody:[String:Any]?, includeAuthHeaders:Bool, completionBlock: @escaping (_ error: String?, _ result: Any?) -> Void) {
        let refreshToken = DataStore.shared.userAuth?.results.refreshToken ?? ""
        var refreshTokenRoute = ""
        var params:[String : Any] = [:]
        var requestType = ""
        var isIncludeAuthHeaders:Bool!
        
        params = [
            "grant_type": NetworkManager.refreshToken,
            //"client_id": clientId,
            "refresh_token": refreshToken,
        ]
   
        refreshTokenRoute = "/api/authentication/oauth2/token"
        requestType = "POST"
        isIncludeAuthHeaders = true
        
        //   let refreshTokenRoute = "/api/authentication/oauth2/token"
        self.call(route: refreshTokenRoute, requestType: requestType, requestBody: params) { (error, data) in
            if error != nil {
                if error == "invalid_grant" {
                    //Force User to login screen
                    NotificationCenter.default.post(name: Notification.Name("sessionExpired"), object: nil)
                } else {
                    completionBlock(error!, nil)
                }
                return
            }
            if let data = data {
                do {
                    let res = try JSONDecoder().decode(User.self, from: data as! Data)
                    DataStore.shared.userAuth = res
                    NetworkManager.call(route: route, requestType: requestType, requestBody: requestBody, completionBlock: completionBlock)
                } catch let error {
                    completionBlock(error.localizedDescription, nil)
                }
            }
        }
    }
    
    //MARK: - GET User Token for External Service
    static func getUserTokenForExternalClinet(_ clientId:String, token:String, completionBlock: @escaping (_ result: UserAuth?, _ error: String?) -> Void) {
        let params = [
            "client_id": clientId,
            "token" : token,
        ]
        let getTokenRoute = "/api/auth_oauth/get_access_token"
        self.call(route: getTokenRoute, requestType: "POST", requestBody: params, includeAuthHeaders: false) { (error, data) in
            if error != nil {
                completionBlock(nil, error)
                return
            }
            if let data = data {
                do {
                    let res = try JSONDecoder().decode(UserAuth.self, from: data as! Data)
                    completionBlock(res, nil)
                } catch let error {
                    completionBlock(nil, error.localizedDescription)
                }
            }
        }
    }
    
    static func getAcccountDetails(accountNumber:String, completionBlock: @escaping (_ result: Any?, _ error: String?) -> Void) -> Void{
        let escapedString = accountNumber.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        let urlPath = "\(Environment.baseURL.absoluteString)/api/iscutomerexist?customerCode=\(escapedString)"
        guard let endpoint = URL(string: urlPath) else {
            return
        }
        URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionBlock(nil, error.localizedDescription )
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                do {
                    guard let data = data else {
                        completionBlock(nil, "No Data Found" )
                        return
                    }
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let details = (json as? [String:Any])?["results"] as? Int {
                        if(httpResponse.statusCode == 200){
                            //DataStore.shared.accountInfo = details
                            UserDefaults.standard.setValue(details, forKey: "account")
                            completionBlock(details, nil)
                        }else{
                            let message = NetworkManager.errorFromResponse(res: json as? [String:Any] ?? [:])
                            completionBlock(nil, message)
                        }
                    } else {
                        let error = (json as? [String:Any])?["error"] as? String ?? "Oops! We do not have an account associated to this Account ID/Alias."
                        completionBlock(nil, error)
                    }
                } catch let error {
                    completionBlock(nil, error.localizedDescription)
                }
            }
        }.resume()
    }
    
    static func fetchSiteList(
        userName: String,
        token: String,
        customerId: String,
        customerName: String,
        siteGroupId: String? = nil,
        siteId: String? = nil,
        tenantId: String,
        completion: @escaping (Result<SiteResponseModel, Error>) -> Void
    ) {
        let baseURL = "\(Environment.baseURL)" + "/api/client-portal/site-list?user=\(userName)"
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(customerId, forHTTPHeaderField: "Customer-Id")
        request.setValue("IIFL", forHTTPHeaderField: "Customer-Name")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(userName, forHTTPHeaderField: "Login-Id")
        request.setValue(siteGroupId ?? "null", forHTTPHeaderField: "Sitegroup-Id")
        request.setValue(siteId ?? "null", forHTTPHeaderField: "Site-Id")
        request.setValue(tenantId, forHTTPHeaderField: "Tenant-Id")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0)))
                return
            }

            guard httpResponse.statusCode == 200, let data = data else {
                completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(SiteResponseModel.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func getUserProfileImage(completion: @escaping (UIImage?,Error?) -> Void) {
        let route = "/api/userprofile?&action=avatar"
        self.call(route: route, requestType: "GET", requestBody: [:]) { error, result in
            if let error = error {
                print("Error: \(error)")
                completion(nil, error.description as? Error)
                return
            }

            guard let data = result as? Data else {
                print("Failed to cast result to Data")
                completion(nil, error?.description as? Error)
                return
            }

            let image = UIImage(data: data)
            completion(image,nil)
        }
    }
    
    static func getUserProfileInformation(completion: @escaping(_ error:String) -> Void){
        let route = "/api/userprofile"
        self.call(route: route, requestType: "GET", requestBody: [:]) { error, result in
            if let error = error {
                print("Error: \(error)")
                completion(error)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(UserReponse.self, from: result as! Data)
                DataStore.shared.userInfo = decoded.results
                completion("")
            } catch {
                completion(error.localizedDescription)
            }
        }
    }
    
    static func getVaultConfiguration(siteId: Int, unitId: Int, completion: @escaping(_ result: String?, _ error: String?) -> Void) {
        let route = "/api/vaults/vaultaccessflow?siteId=\(siteId)&unitId=\(unitId)"
        self.call(route: route, requestType: "GET", requestBody: [:]) { error, result in
            if let error = error {
                completion(nil, error.description)
                return
            }
            
            guard let data = result as? Data else {
                completion(nil, "Invalid response data")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(VaultResponse.self, from: data)
                DataStore.shared.vaultData = response.results
                completion("Success", "")
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }
    
    static func getDeviceStatus(params:[String:Any],completion:@escaping (_ data:[String:Any], _ error:String) -> Void){
        let route = "/api/smartaccess/frsvalidation/accessflow"
        self.call(payLoadFlag:false,route: route, requestType: "POST",requestBody: params, MultipartRequest:true) { error, result in
            if let error = error{
                completion([:], error)
            }
            // Ensure we have valid Data in result
            guard let data = result as? Data else {
                completion([:], "No valid data received")
                return
            }
            do {
                // Convert the bytes data into a JSON dictionary
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(json,"")
                } else {
                    completion([:], "Unexpected JSON format")
                }
            } catch {
                completion([:], "Failed to parse JSON: \(error.localizedDescription)")
            }
        }
    }
    
    static func getDoorStatus(deviceId: String, completion: @escaping (_ data:[String:Any], _ error: String) -> Void) {
        // Append the deviceId to the route URL
        let route = "/api/smartaccess/frsvalidation/doorstatus?deviceId=\(deviceId)"
        
        self.call(route: route, requestType: "GET", requestBody: [:], includeAuthHeaders: false) { error, result in
            // Return if an error occurs
            if let error = error {
                completion([:], error)
                return
            }
            
            // Ensure we have valid Data in result
            guard let data = result as? Data else {
                completion([:], "No valid data received")
                return
            }
            
            do {
                // Convert the bytes data into a JSON dictionary
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(json, "")
                } else {
                    completion([:], "Unexpected JSON format")
                }
            } catch {
                completion([:], "Failed to parse JSON: \(error.localizedDescription)")
            }
        }
    }
    
    static func validateFace(image: UIImage,completion: @escaping (_ response:[String: Any]?, _ error:String?) -> Void) {
        let tokenId = DataStore.shared.userAuth?.results.accessToken ?? ""
        let empId = DataStore.shared.userInfo?.employeeId ?? ""
        let customerId = DataStore.shared.userAuth?.results.mappedCustomers[0].pkCustomerId.description ?? ""
        let urlString = "\(Environment.baseURL)/api/smartaccess/frsvalidation/validateFace"
        guard let url = URL(string: urlString) else {
            completion(nil,"Invalid URL")
            return
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(tokenId)", forHTTPHeaderField: "Authorization")
        request.setValue(customerId, forHTTPHeaderField: "Customer-Id")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add image part (corrected)
        if let imageData = image.fixOrientation().jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"face_\(Int(Date().timeIntervalSince1970)).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        // Add other fields
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"empId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(empId)\r\n".data(using: .utf8)!)

        // Final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil,error.localizedDescription)
                return
            }

            guard let data = data else {
                completion(nil,"Data is not valid")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(json,nil)
                } else {
                    completion(nil,error.debugDescription)
                }
            } catch {
                completion(nil,"Failed to parse the data")
            }
        }.resume()
    }
    
    static func getChecklistQuestions(completion:@escaping (_ data:[Question]?, _ error:String) -> Void){
        let params:[String:Any] = ["empId":DataStore.shared.userInfo?.employeeId ?? ""]
        let route = "/api/smartaccess/frsvalidation/questionnaire"
        self.call(route: route, requestType: "POST", requestBody: params, MultipartRequest:true) { error, result in
            if let error = error{
                completion(nil, error)
            }
            // Ensure we have valid Data in result
            guard let data = result as? Data else {
                completion(nil, "No valid data received")
                return
            }
            do {
                // Convert the bytes data into a JSON dictionary
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let questions = parseQuestions(from: json)
                    completion(questions,"")
                } else {
                    completion(nil, "Unexpected JSON format")
                }
            } catch {
                completion(nil, "Failed to parse JSON: \(error.localizedDescription)")
            }
        }
    }
    
    static func submitAnswers(params:[String:Any], vaultId:Int ,completion: @escaping( _ response:[String:Any], _ error:String) -> Void){
        let route = "/api/vaults/validateQuestionnaire?vaultId=\(vaultId)"
        self.call(route: route, requestType: "POST", requestBody: params) { error, result in
            if let error = error{
                completion([:], error)
            }
            // Ensure we have valid Data in result
            guard let data = result as? Data else {
                completion([:], "No valid data received")
                return
            }
            do {
                // Convert the bytes data into a JSON dictionary
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(json,"")
                } else {
                    completion([:], "Unexpected JSON format")
                }
            } catch {
                completion([:], "Failed to parse JSON: \(error.localizedDescription)")
            }
        }
    }
    
    static func sendOTP(completion:@escaping (_ data:[String:Any]?, _ error:String) -> Void){
        let params:[String:Any] = ["empId":DataStore.shared.userInfo?.employeeId ?? ""]
        let route = "/api/smartaccess/frsvalidation/getOTP"
        self.call(route: route, requestType: "POST", requestBody: params, MultipartRequest:true) { error, result in
            if let error = error{
                completion(nil, error)
            }
            // Ensure we have valid Data in result
            guard let data = result as? Data else {
                completion(nil, "No valid data received")
                return
            }
            do {
                // Convert the bytes data into a JSON dictionary
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(json,"")
                } else {
                    completion(nil, "Unexpected JSON format")
                }
            } catch {
                completion(nil, "Failed to parse JSON: \(error.localizedDescription)")
            }
        }
    }
}

extension Data {
    static func dataFrom(_ string: String) -> Data{
        if let data = string.data(using: .utf8) {
            return data
        }
        return Data()
    }
    
    static func addHeaders(_ headers: [String: String?], to request: inout URLRequest) {
        for (key, value) in headers {
            if let value = value {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
    }
}
