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

// MARK: - SignUPResponse
class SignUPResponse: Codable {
    var result, message : String?
}
