//
//  LoginResponse.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 16/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import Foundation

// MARK: - LoginResponse
struct LoginResponse: Codable {
    var success , message , name, username, password: String?
    var nextdue, curloc, query, package: String?
    var server: [Server]?
    var usage: Usage?
    var adblocker:String?
}

// MARK: - Server
struct Server: Codable {
    var serverIP, serverPort: String?
    var country: String?
    var city, type, flag: String?

    enum CodingKeys: String, CodingKey {
        case serverIP = "server_ip"
        case serverPort = "server_port"
        case country = "Country"
        case city = "City"
        case type
        case flag = "Flag"
    }
}

// MARK: - Usage
struct Usage: Codable {
    var usagelimit, usagetotal, limitrange: String?
//    var remaining: Int?
}
