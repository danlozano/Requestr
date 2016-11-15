//
//  ActivityManager.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/15/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

struct ActivityManager {

    static private var activitiesCount = 0

    static func incrementActivityCount() {
        activitiesCount += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    static func decreaseActivityCount() {
        guard activitiesCount > 0 else {
            return
        }

        activitiesCount -= 1

        if activitiesCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
}
