//  Environment.swift

import Foundation

public enum Environment {
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let baseURL = "API_BASE_URL"
            static let apiVersion = "API_VERSION"
            static let grantType = "API_GRANT_TYPE"
            static let refreshToken = "API_REFRESH_TOKRN"
            static let apiAppToken = "API_APP_TOKEN"
            static let appName = "APP_NAME"
            static let appVersion = "APP_MARKETING_VERSION"
            static let isProduction = "IS_PRODUCTION"
        }
    }
    
    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    // MARK: - Plist values
    static let baseURL: URL = {
        guard let rootURLstring = Environment.infoDictionary[Keys.Plist.baseURL] as? String else {
            fatalError("Base URL not set in plist for this environment")
        }
        guard let url = URL(string: rootURLstring) else {
            fatalError("Base URL is invalid")
        }
        return url
    }()
        
    static let appName: String = {
        guard let value = Environment.infoDictionary[Keys.Plist.appName] as? String else {
            return "HSense"
        }
        return value
    }()
    
    static let apiVersion: String = {
        guard let value = Environment.infoDictionary[Keys.Plist.apiVersion] as? String else {
            fatalError("Api Version not set in plist for this environment")
        }
        return value
    }()
    
    static let refreshToken: String = {
        guard let value = Environment.infoDictionary[Keys.Plist.refreshToken] as? String else {
            fatalError("API Refresh Token not set in plist for this environment")
        }
        return value
    }()
    
    static let grantType: String = {
        guard let value = Environment.infoDictionary[Keys.Plist.grantType] as? String else {
            fatalError("Api grantType not set in plist for this environment")
        }
        return value
    }()
    
    static let apiAppToken: String = {
        guard let value = Environment.infoDictionary[Keys.Plist.apiAppToken] as? String else {
            fatalError("Api App Token not set in plist for this environment")
        }
        return value
    }()

    static let isProduction: String = {
        guard let value = Environment.infoDictionary[Keys.Plist.isProduction] as? String else {
            fatalError("isProduction not set in plist for this environment")
        }
        return value
    }()
    
    static let appVersion: String = {
        guard let value = Environment.infoDictionary[Keys.Plist.appVersion] as? String else {
            fatalError("app version not set in plist for this environment")
        }
        return value
    }()
}
