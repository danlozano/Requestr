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

    let apiClient = ApiClient(configuration: .default)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func test() {

        let user = User(name: "Daniel Lozano", age: 27, date: Date())

        apiClient.DELETE("/user/123", rootKey: "user", body: nil) { (result: ApiResult<User>) in

        }

        apiClient.POST("/user", rootKey: "user", body: user) { (result: ApiResult<EmptyResult>) in
            switch result {
            case .success(let resource, let meta):
                let user = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }

        apiClient.GET("/users", rootKey: "users") { (result: ApiResult<[User]>) in
            switch result {
            case .success(let resource, let meta):
                let users = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(users) : \(pagination) : \(headers)")
            default:
                break
            }
        }

        apiClient.GET("/user", params: ["thing" : "thing"]) { (result: ApiResult<User>) in
            switch result {
            case .success(let resource, let meta):
                let user = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }

        apiClient.GET("/post", rootKey: "user") { (result: ApiResult<User>) in
            switch result {
            case .success(let resource, let meta):
                let user = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }

        apiClient.GET("/user") { (result: ApiResult<User>) in
            switch result {
            case .success(let resource, let meta):
                let user = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }
        
    }

}

