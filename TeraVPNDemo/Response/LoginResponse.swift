//
//  LoginResponse.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 16/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let loginResponse = try? newJSONDecoder().decode(LoginResponse.self, from: jsonData)

import Foundation

// MARK: - LoginResponse
class LoginResponse: Codable {
    var success, message, name, username, password: String?
    var nextdue, curloc, query, package: String?
    var server: [Server]?
    var usage: Usage?
    var adblocker: String?

    init(success: String?, message: String?, name: String?, username: String?, password: String?, nextdue: String?, curloc: String?, query: String?, package: String?, server: [Server]?, usage: Usage?, adblocker: String?) {
        self.success = success
        self.message = message
        self.name = name
        self.username = username
        self.password = password
        self.nextdue = nextdue
        self.curloc = curloc
        self.query = query
        self.package = package
        self.server = server
        self.usage = usage
        self.adblocker = adblocker
    }
}

// MARK: - Server
class Server: Codable {
    var serverIP, serverPort, desc, country: String?
    var city: String?
    var type: TypeEnum?
    var flag: String?

    enum CodingKeys: String, CodingKey {
        case serverIP = "server_ip"
        case serverPort = "server_port"
        case desc, country, city, type, flag
    }

    init(serverIP: String?, serverPort: String?, desc: String?, country: String?, city: String?, type: TypeEnum?, flag: String?) {
        self.serverIP = serverIP
        self.serverPort = serverPort
        self.desc = desc
        self.country = country
        self.city = city
        self.type = type
        self.flag = flag
    }
}

enum TypeEnum: String, Codable {
    case basic = "basic"
}

// MARK: - Usage
class Usage: Codable {
    var usagelimit, usagetotal, ratelimit, limitrange: String?
    var remaining: Int?

    init(usagelimit: String?, usagetotal: String?, ratelimit: String?, limitrange: String?, remaining: Int?) {
        self.usagelimit = usagelimit
        self.usagetotal = usagetotal
        self.ratelimit = ratelimit
        self.limitrange = limitrange
        self.remaining = remaining
    }
}
