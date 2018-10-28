//
//  TaskCell.swift
//  WebServiceDemo
//
//  Created by Mohammed Sobhei Abdualal on 10/28/18.
//  Copyright © 2018 Mohammed Sobhei Abdualal. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
    }

    func configureCell(task:Task) {
        textLabel?.text = task.task
        backgroundColor = task.completed! ? .yellow : .clear
    }

}
