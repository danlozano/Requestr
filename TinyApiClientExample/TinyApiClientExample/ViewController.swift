//
//  ViewController.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 11/29/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import UIKit
import TinyApiClient

class ViewController: UIViewController {

    let service: RemotelyService = {
        let apiClient = ApiClient(configuration: .default)
        // apiClient.loggingEnabled = true
        let service = RemotelyAPIService(apiClient: apiClient)
        return service
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let login = LoginRequest(email: "daniel@icalialabs.com", password: "password")
        var accessToken: String?

        service.login(loginRequest: login) { (result) in
            switch result {
            case .success(let resource, let metadata):
                print("SUCCESS: USER = \(resource)")
                accessToken = metadata.accessToken
                print("ACCESS TOKEN = \(accessToken)")
            case .error(let message):
                print("ERROR: \(message)")
            }
        }

        guard let token = accessToken else {
            print("NO ACCESS TOKEN; RETURNING;")
            return
        }

        service.users() { (result) in
            switch result {
            case .success(let resource, _):
                print("SUCCESS: USERS = \(resource)")
            case .error(let message):
                print("ERROR: \(message)")
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

