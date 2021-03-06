//
//  UserService.swift
//  WhoWorks
//
//  Created by Медведь Святослав on 05.02.17.
//  Copyright © 2017 loogle18. All rights reserved.
//

import Foundation
import Alamofire
import Alamofire_Synchronous

class UserService {
    private class var baseUrl: String {
        return "https://who-works-api.herokuapp.com/api/v1/"
    }
    
    private class var indexUrl: String {
        return "\(baseUrl)users"
    }
    
    private class var authUrl: String {
        return "\(baseUrl)auth"
    }
    
    private class var updateStatusCodeUrl: String {
        return "\(baseUrl)update_status"
    }
    
    private class func createUserFromResponse(_ response: Dictionary<String, Any>) -> User {
        let user = User(
            id: response["id"] as! UInt16, login: response["login"] as! String, email: response["email"] as! String,
            statusCode: response["status_code"] as! UInt8, status: response["status"] as? String, fullName: response["full_name"] as? String, avatarUrl: response["avatar"] as? String
        )
        return user
    }
    
    private class func showUrl(_ id: UInt16) -> String {
        return "\(indexUrl)/\(id)"
    }
    
    class func getUsers() -> [User] {
        let response = Alamofire.request(indexUrl).responseJSON()
        
        var users = [User]()
        if let result = response.result.value {
            let data = result as! Array<Any>
            for item in data {
                let user = createUserFromResponse(item as! Dictionary<String, Any>)
                users.append(user)
            }
        }
        return users
    }
    
    class func createUser(_ parameters: [String : String]) -> Any {
        let params : [String : Any] = ["user" : parameters]
        let response = Alamofire.request(indexUrl, method: .post, parameters: params).responseJSON()
        var result : Any = 400
        
        if response.result.isSuccess {
            if let resp = response.response, resp.statusCode == 200  {
                result = createUserFromResponse(response.result.value as! Dictionary<String, Any>)
            } else if let resp = response.response, resp.statusCode == 406 {
                result = response.result.value as! Array<String>
            }
        }
        return result
    }
    
    class func authUser(_ parameters: [String]) -> Any {
        let params = ["user" : ["email" : parameters[0], "password" : parameters[1]]]
        let response = Alamofire.request(authUrl, method: .get, parameters: params).responseJSON()
        var result : Any = 400
        
        if response.result.isSuccess {
            result = createUserFromResponse(response.result.value as! Dictionary<String, Any>)
            
        } else if let resp = response.response {
            result = resp.statusCode
        }
        return result
    }
    
    class func updateStatusCode(_ parameters: [Any]) {
        let params = ["user" : ["id" : parameters[0], "status_code" : parameters[1]]]
        _ = Alamofire.request(updateStatusCodeUrl, method: .post, parameters: params).responseJSON()
    }
    
    class func destroyUser(_ id: UInt16) -> Bool {
        let response = Alamofire.request(showUrl(id), method: .delete).responseJSON()
        
        if response.result.isSuccess && response.response?.statusCode == 204 {
            return true
        } else {
            return false
        }
    }
}
