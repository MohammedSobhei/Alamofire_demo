//
//  Task.swift
//  WebServiceDemo
//
//  Created by Mohammed Sobhei Abdualal on 10/27/18.
//  Copyright © 2018 Mohammed Sobhei Abdualal. All rights reserved.
//
//

import UIKit
import SwiftyJSON

class Task: NSObject, NSCopying {

    var id: Int!
    var task: String!
    var completed: Bool?

    init(id: Int = 0, task: String) {
        self.id = id
        self.task = task
    }
    init?(dict: [String: JSON]) {
        guard let id = dict["id"]?.toInt, let task = dict["task"]?.string else {
            return nil
        }

        self.id = id
        self.task = task
        self.completed = dict["completed"]?.toBool ?? false
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copyTask = Task(id: self.id, task: self.task!)
        copyTask.completed = self.completed
        
        print(1)
        return copyTask
    }
}
