//
//  LoginRequest.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 16/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import Foundation


// MARK: - LoginRequest
struct LoginRequest: Codable {
    var username, password: String?
}
