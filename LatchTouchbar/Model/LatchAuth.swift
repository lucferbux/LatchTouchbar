//
//  LatchAuth.swift
//  LatchTest
//
//  Created by lucas fernández on 20/01/2018.
//  Copyright © 2018 lucas fernández. All rights reserved.
//

import Foundation
import Arcane
import Alamofire

class LatchAuth {
    
    let API_VERSION = "1.0"
    let API_HOST = "latch.elevenpaths.com"
    let API_PORT = 443
    let API_HTTPS = true
    
    let AUTHORIZATION_HEADER_NAME = "Authorization"
    let DATE_HEADER_NAME = "X-11Paths-Date"
    let AUTHORIZATION_METHOD = "11PATHS"
    let AUTHORIZATION_HEADER_FIELD_SEPARATOR = " "
    let UTC_STRING_FORMAT = "Y-MM-DD HH:mm:ss"
    let X_11PATHS_HEADER_PREFIX = "X-11paths-"
    let X_11PATHS_HEADER_SEPARATOR = ":"
    
    var API_CHECK_STATUS_URL: String  { return "/api/" + self.API_VERSION + "/status" }
    var API_PAIR_URL: String { return "/api/" + self.API_VERSION + "/pair" }
    var API_PAIR_WITH_ID_URL: String { return "/api/" + self.API_VERSION + "/pairWithId" }
    var API_UNPAIR_URL: String { return "/api/" + self.API_VERSION + "/unpair" }
    var API_LOCK_URL: String { return "/api/" + self.API_VERSION + "/lock" }
    var API_UNLOCK_URL: String { return "/api/" + self.API_VERSION + "/unlock" }
    var API_HISTORY_URL: String { return "/api/" + self.API_VERSION + "/history" }
    var API_OPERATION_URL: String { return "/api/" + self.API_VERSION + "/operation" }
    var API_SUBSCRIPTION_URL: String { return "/api/" + self.API_VERSION + "/subscription" }
    var API_APPLICATION_URL: String { return "/api/" + self.API_VERSION + "/application" }
    var API_INSTANCE_URL: String { return "/api/" + self.API_VERSION + "/instance" }
    
    private var _appId: String!
    private var _appSecret: String!
    
    var appId: String {
        if _appId == nil {
            _appId = ""
        }
        return _appId
    }
    
    var appSecret: String {
        if _appSecret == nil {
            _appSecret = ""
        }
        return _appSecret
    }
    
    init(appId: String, appSecret: String) {
        self._appId = appId
        self._appSecret = appSecret
        
    }
    
    /// Get the current time in UTC time zone with a given format
    ///
    /// - Returns: String representation of the current time in UTC to be used in a Date HTTP Header
    func getActualDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = UTC_STRING_FORMAT
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateFormatted = formatter.string(from: date)
        return dateFormatted
    }
    
    
    /// Calculate the atuthentication headers to be sent with a request to the API
    ///
    /// - Parameters:
    ///   - httpMethod: The HTTP Method, currently only GET is supported
    ///   - queryString: The urlencoded string including the path (from the first forward slash) and the parameters
    /// - Returns: Dictionary with teh Authorization an Date headers neeede to sign a Latch API request
    func authenticationHeaders(httpMethod: String, queryString: String) -> [String:String] {
        let utc = getActualDate()
        let stringToSign = httpMethod + "\n" + utc + "\n" + "\n" + queryString
        let authorization_header = AUTHORIZATION_METHOD + AUTHORIZATION_HEADER_FIELD_SEPARATOR + appId + AUTHORIZATION_HEADER_FIELD_SEPARATOR + signData(data: stringToSign)
        var headers: [String:String] = [:]
        headers[AUTHORIZATION_HEADER_NAME] = authorization_header
        headers[DATE_HEADER_NAME] = utc
        return headers
    }
    
    
    /// HTTP Request to the specified API endpoint
    ///
    /// - Parameters:
    ///   - method: The HTTP Method
    ///   - url: The urlencode string including the path
    ///   - completion: The completion closure to catch the network response
    func http(method: String, url: String, completion: @escaping ([String: Any]) -> Void) {
        var auth_headers = authenticationHeaders(httpMethod: method, queryString: url)
        if method == "POST" || method == "PUT" {
            auth_headers["Content-type"] = "application/x-www-form-urlencoded"
        }
        let urlLatch = "https://" + API_HOST + ":" + String(API_PORT) + url
        var method_struct: HTTPMethod!
        
        switch method {
            case "GET":
                method_struct = .get
            case "PUT":
                method_struct = .put
            case "POST":
                method_struct = .post
            case "DELETE":
                method_struct = .delete
            default:
                method_struct = .get
        }
        
        // Connect http
        Alamofire.request(URL(string: urlLatch)!,
                          method: method_struct, headers: auth_headers)
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Error while fetching remote rooms:")
                    return
                }
                guard let value = response.result.value as? [String: Any] else {
                    print("Malformed data received from fetchAllRooms service")
                    return
                }
                completion(value)
        }
        
    }
    
    /// Function to hash and encode the request Signature
    ///
    /// - Parameter data: the string to sign
    /// - Returns: string base64 encoding of the HMAC-SHA1 hash of the data parameter using {@code secretKey} as cipher key.
    func signData(data: String) -> String {
        let dataDigest = HMAC.SHA1(data.data(using: .utf8, allowLossyConversion: false)!, key: appSecret.data(using: .utf8, allowLossyConversion: false)!)
        let dataBase64 = dataDigest?.base64String
        return dataBase64!
    }

}
