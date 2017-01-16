//
//  ViewController.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 11/29/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import UIKit
import TinyAPIClient

class ViewController: UIViewController {

    let apiClient: ApiClient = {
        let client = ApiClient(configuration: nil)
        client.loggingEnabled = true
        return client
    }()

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
        let login = LoginRequest(email: "johndoe@icalialabs.com", password: "password")
        authService.login(loginRequest: login) { (result) in
            switch result {
            case .success(let user, let token):
                print("SUCCESS: USER = \(user)")
                print("ACCESS TOKEN = \(token)")
                // self.getUser(token: token)
                self.getUserEvents(token: token)
            case .error(let message):
                print("ERROR: \(message)")
            }
        }
    }

    func signup() {
        let signup = SignupRequest(name: "Johny Api", email: "johnyapi@icalialabs.com", password: "password")
        authService.signup(signupRequest: signup) { (result) in
            switch result {
            case .success(let user, let token):
                print("SUCCESS: USER = \(user)")
                print("ACCESS TOKEN = \(token)")
                // self.getUser(token: token)
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

    func getUserEvents(token: String) {
        apiClient.setAccessToken(token: token)
        service.userEvents() { (result: RemotelyResult<[Event]>) in
            switch result {
            case .success(let events, _):
                print("SUCCESS: EVENTS = \(events)")
            case .error(let message):
                print("ERROR: \(message)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

