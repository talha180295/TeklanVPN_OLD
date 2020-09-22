//
//  UsageResponse.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 23/09/2020.
//  Copyright © 2020 abc. All rights reserved.
//

import Foundation

// MARK: - Usage
struct UsageResponse: Codable {
    var success, usagelimit, usagetotal, remaining: String?
}
