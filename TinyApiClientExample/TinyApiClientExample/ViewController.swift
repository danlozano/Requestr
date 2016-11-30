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

    let apiClient = ApiClient(configuration: nil)

    lazy var service: RemotelyService = {
        let service = RemotelyAPIService(apiClient: self.apiClient)
        return service
    }()

    lazy var authService: AuthService = {
        let service = AuthApiService(apiClient: self.apiClient)
        return service
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        login()
    }

    func login() {
        let login = LoginRequest(email: "daniel@icalialabs.com", password: "password")
        authService.login(loginRequest: login) { (result) in
            switch result {
            case .success(let user, let token):
                print("SUCCESS: USER = \(user)")
                print("ACCESS TOKEN = \(token)")
                self.getUser(token: token)
            case .error(let message):
                print("ERROR: \(message)")
            }
        }
    }

    func getUser(token: String) {
        apiClient.setAccessToken(token: token)
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

