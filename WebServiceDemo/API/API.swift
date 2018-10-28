//
//  API.swift
//  WebServiceDemo
//
//  Created by Mohammed Sobhei Abdualal on 10/27/18.
//  Copyright © 2018 Mohammed Sobhei Abdualal. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class API: NSObject {

    class User {

        static func login(email: String, password: String, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
            let url = URLs.login
            let parameters = [
                "email": email,
                "password": password
            ]
            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .responseJSON { (response) in

                    switch response.result {

                    case .failure(let error):
                        completion(false, error)
                    case .success(let value):
                        let json = JSON(value)

                        if let api_token = json["user"]["api_token"].string {
                            print(api_token)
                            Helper.saveApiToken(token: api_token)
                            completion(true, nil)
                        } else {
                            completion(false, nil)
                        }

                    }
            }
        }

        static func register(name: String, email: String, password: String, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
            let url = URLs.register
            let parameters = [
                "name": name,
                "email": email,
                "password": password,
                "password_confirmation": password
            ]

            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .responseJSON { (response) in

                    switch response.result {

                    case .failure(let error):
                        completion(false, error)
                    case .success(let value):
                        let json = JSON(value)
                        if let api_token = json["user"]["api_token"].string {
                            print(api_token)
                            Helper.saveApiToken(token: api_token)
                            completion(true, nil)
                        }

                    }
            }
        }


    }

    class Tasks {

        static func editTask(task: Task, completion: @escaping (_ task: Task?, _ error: Error?) -> Void) {
            guard let api_token = Helper.getApiToken() else {
                completion(nil, nil)
                return }
            let url = URLs.editTask
            let parameters: [String: Any] = [
                "api_token": api_token,
                "task_id": task.id!,
                "task": task.task!,
                "completed": task.completed?.toInt ?? 0
            ]

            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .responseJSON { (response) in

                    switch response.result {
                    case .failure(let error):
                        completion(nil, error)
                    case .success(let value):
                        let json = JSON(value)
                        guard let task = json["task"].dictionary, let editTask = Task(dict: task) else {
                            completion(nil, nil)
                            return }

                        completion(editTask, nil)
                    }
            }

        }

        static func deleteTask(task: Task, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
            guard let api_token = Helper.getApiToken() else {
                completion(false, nil)
                return }
            let url = URLs.deleteTask
            let parameters: [String: Any] = [
                "api_token": api_token,
                "task_id": task.id!
            ]

            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .responseJSON { (response) in

                    switch response.result {
                    case .failure(let error):
                        completion(false, error)
                    case .success(let value):
                        let json = JSON(value)
                        guard let status = json["status"].toInt, status == 1 else {
                            completion(false, nil)
                            return }

                        completion(true, nil)
                    }
            }

        }
        static func createTask(newTask: Task, completion: @escaping (_ newTask: Task?, _ error: Error?) -> Void) {

            guard let api_token = Helper.getApiToken() else {
                completion(nil, nil)
                return }
            let url = URLs.createTask
            let parameters = [
                "api_token": api_token,
                "task": newTask.task!
            ]

            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .responseJSON { (response) in

                    switch response.result {
                    case .failure(let error):
                        completion(nil, error)
                    case .success(let value):
                        let json = JSON(value)
//
                        print(json)
                        guard let taskDict = json["task"].dictionary, let task = Task(dict: taskDict) else {
                            completion(nil, nil)
                            return }

                        completion(task, nil)
                    }
            }
        }
        static func getTasks(page: Int = 1, completion: @escaping (_ tasks: [Task]?, _ error: Error?, _ last_page: Int) -> Void) {

            guard let api_token = Helper.getApiToken() else { completion(nil, nil, page)
                return }
            let url = URLs.tasks
            let parameters: [String: Any] = [
                "api_token": api_token,
                "page": page
            ]
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .responseJSON { (response) in

                    switch response.result {
                    case .failure(let error):
                        completion(nil, error, page)
                    case .success(let value):
                        let json = JSON(value)

                        guard let dataArr = json["data"].array else {
                            completion(nil, nil, page)
                            return
                        }

                        var tasks = [Task]()

                        for data in dataArr {
                            if let data = data.dictionary, let task = Task(dict: data) {
                                tasks.append(task)
                            }
                        }
                        let last_page = json["last_page"].int ?? page
                        completion(tasks, nil, last_page)
                    }
            }
        }
    }
}
