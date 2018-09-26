//
//  Communicator.swift
//  ACSCommunicator
//
//  Created by Leandro Bartetzko Fernandes on 21.09.18.
//  Copyright © 2018 Leandro Bartetzko Fernandes. All rights reserved.
//

import Foundation
import SwiftyJSON
//**************************************************************************
//Get a valid Token from ACS ***********************************************
//**************************************************************************
public func getToken(username: String, password: String, callback:@escaping (_ token: String?, _ error: Error?)->()) {
    let bodyData: String = "scope=acs_webservice&client_id=10TVL0SAM30000004901DSLHILFEAPP000000000&grant_type=password&username=\(username)&password=\(password)"
    var req = URLRequest(url: URL(string: "https://accounts.login00.idm.ver.sul.t-online.de/oauth2/tokens")!)
    req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    req.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
    req.httpMethod = "POST"
    req.httpBody = bodyData.data(using: .utf8)
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: req) { (data, response, error) in
        if let data = data {
            let json = try? JSON(data: data)
            if let tokenString = json!["access_token"].string {
                callback(tokenString, nil)
            }else {
                callback(nil, error)
            }
        }
    }
    task.resume()
}
//**************************************************************************
//Set WiFi status ( True / False ) *****************************************
//**************************************************************************
public func setWifi(token: String, status: String, secret: String, callback:@escaping (_ okString: String?)->()){
    let bodyData: String = "flag=\(status)"
    var req = URLRequest(url: URL(string: "https://einrichten-vtu.telekom-dienste.de:44300/acs/api/rs/device/wifi/enable")!)
    req.addValue(secret, forHTTPHeaderField: "secret")
    req.addValue(token, forHTTPHeaderField: "token")
    req.httpMethod = "POST"
    req.httpBody = bodyData.data(using: .utf8)
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: req){ (data, response, error) in
        if let data = data {
            let json = try? JSON(data: data)
            if let okString = json!["result"].string {
                callback(okString)
            }
        }
    }
    task.resume()
}
//**************************************************************************
//CHeck if WiFi is on or off ***********************************************
//**************************************************************************
public func checkWifi(token: String, secret: String, callback:@escaping ( _ wifi24IsOn: Bool?) -> () ) {
    var wifi24IsOn: Bool?
    var url = URLComponents(string: "https://einrichten-vtu.telekom-dienste.de:44300/acs/api/rs/device/property/get")!
    url.queryItems = [
        URLQueryItem(name: "names", value: "[\"Device.WiFi.Radio.[WLAN_2_4].Status\"]")
    ]
    var checkSettingsReq = URLRequest(url: url.url!)
    checkSettingsReq.addValue(secret, forHTTPHeaderField: "secret")
    checkSettingsReq.addValue(token, forHTTPHeaderField: "token")
    checkSettingsReq.httpMethod = "GET"
    let checkSettingsSession = URLSession(configuration: .default)
    let checkSettingsTask = checkSettingsSession.dataTask(with: checkSettingsReq) { (data, response, error) in
        if let data = data {
            let json = try? JSON(data: data)
            let JSONwifiIsON24 = json!["result"][0]["value"].string
            if JSONwifiIsON24 == "UP"{
                wifi24IsOn = true
            } else if JSONwifiIsON24 == "Down" {
                wifi24IsOn = false
            }
            callback(wifi24IsOn)
        }
        if let error = error {
            print(error)
        }
    }
    checkSettingsTask.resume()
}
//**************************************************************************
//Function get Router information ******************************************
//**************************************************************************

public func getInformation(token: String, secret: String, callback:@escaping (_ download: String?, _ upload: String?, _ mediumType: String?) -> () ){
    ///access/info
    var infoReq = URLRequest(url: URL(string: "https://einrichten-vtu.telekom-dienste.de:44300/acs/api/rs/access/info")!)
    infoReq.addValue(secret, forHTTPHeaderField: "secret")
    infoReq.addValue(token, forHTTPHeaderField: "token")
    infoReq.httpMethod = "GET"
    let infoSession = URLSession(configuration: .default)
    let infoTask = infoSession.dataTask(with: infoReq) { (data, response, error) in
        if let data = data {
            let json = try? JSON(data: data)
            let download = json!["result"]["access_down_speed"].string
            let upload = json!["result"]["access_up_speed"].string
            let mediumType = json!["result"]["access_medium_type"].string
            if download != nil && upload != nil && mediumType != nil {
                callback(download!, upload!, mediumType!)
            }else {
                print("ACS Antwortet nicht!")
            }
        }
        if let error = error {
            print(error)
        }
    }
    infoTask.resume()
}
//**************************************************************************
//Get WLan-SSID ************************************************************
//**************************************************************************
public func getSSID(token: String, secret: String, callback:@escaping(_ ssid: String) -> () ){
    var ssidUrl = URLComponents(string: "https://einrichten-vtu.telekom-dienste.de:44300/acs/api/rs/device/property/get")!
    ssidUrl.queryItems = [ URLQueryItem(name: "names", value: "[\"Device.WiFi.SSID.1.SSID\"]") ]
    var ssidReq = URLRequest(url: ssidUrl.url!)
    ssidReq.addValue(secret, forHTTPHeaderField: "secret")
    ssidReq.addValue(token, forHTTPHeaderField: "token")
    let ssidSession = URLSession(configuration: .default)
    let ssidTast = ssidSession.dataTask(with: ssidReq) { (data, response, error) in
        if let data = data {
            let json = try? JSON(data: data)
            let ssid = json!["result"][0]["value"].string
            callback(ssid!)
        }
    }
    ssidTast.resume()
}
//**************************************************************************
//Set password & SSID ******************************************************
//**************************************************************************
public func setCredentials(token: String, setSSID: String, setPassword: String, secret: String, callback:@escaping (_ okString: String?)->()){
    let bodyData: String = "ssid=\(setSSID)&key=\(setPassword)"
    var req = URLRequest(url: URL(string: "https://einrichten-vtu.telekom-dienste.de:44300/acs/api/rs/device/wifi/change")!)
    req.addValue(secret, forHTTPHeaderField: "secret")
    req.addValue(token, forHTTPHeaderField: "token")
    req.httpMethod = "POST"
    req.httpBody = bodyData.data(using: .utf8)
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: req){ (data, response, error) in
        if let data = data {
            let json = try? JSON(data: data)
            if let okString = json!["result"].string {
                callback(okString)
            }
        }
    }
    task.resume()
}

