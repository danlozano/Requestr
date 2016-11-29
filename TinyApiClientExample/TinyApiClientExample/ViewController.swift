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
        apiClient.loggingEnabled = true
        let service = RemotelyService(apiClient: apiClient)
        return service
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let login = LoginRequest(email: "daniel@icalialabs.com", password: "password")
        service.login(loginRequest: login) { (result) in
            switch result {
            case .success(let user, _):
                print("SUCCESS: USER = \(user)")
            default:
                print("ERROR")
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

