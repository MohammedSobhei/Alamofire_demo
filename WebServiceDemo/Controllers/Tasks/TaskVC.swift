//
//  TaskVC.swift
//  WebServiceDemo
//
//  Created by Mohammed Sobhei Abdualal on 10/27/18.
//  Copyright © 2018 Mohammed Sobhei Abdualal. All rights reserved.
//

import UIKit

class TaskVC: UIViewController {

    fileprivate let cellIdentifier = "TaskCell"
    fileprivate let cellHeight: CGFloat = 100.0
    @IBOutlet weak var tableView: UITableView!

    var tasks = [Task]()

    var refresher: UIRefreshControl = {

        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return refresher
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

//        add (+) add new task in navigationItem
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        navigationItem.rightBarButtonItem = addButton
        
        // to remove last empty cell
        tableView.tableFooterView = UIView()

        //to style separator in table view
        tableView.separatorInset = .zero
        tableView.contentInset = .zero
        
        // add refresher
        tableView.addSubview(refresher)
        
        // to register cell
        tableView.register(TaskCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        loadData()
    }

    var current_page = 1
    var last_page = 1
    var isLoading = false

    @objc private func addTask() {

        let alert = UIAlertController.init(title: "Add new task", message: "Enter Title", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        alert.addTextField { (txt: UITextField) in
            txt.placeholder = "Title"
            txt.textAlignment = .center
        }
        alert.addAction(UIAlertAction.init(title: "Add", style: UIAlertAction.Style.destructive, handler: { (action: UIAlertAction) in

            guard let title = alert.textFields?.first?.text?.trimmed, !title.isEmpty else { return }
            // add new task

            self.addNewTask(title: title)
        }))

        present(alert, animated: true, completion: nil)
    }

    private func addNewTask(title: String) {

        let newTask = Task(task: title)

        API.Tasks.createTask(newTask: newTask) { (newTask: Task?, error: Error?) in

            if let newTask = newTask {

                self.tasks.insert(newTask, at: 0)
                
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
    @objc private func loadData() {

        self.refresher.endRefreshing()
//        API.Tasks
        guard !isLoading else { return }

        isLoading = true
        API.Tasks.getTasks { (Tasks: [Task]?, error: Error?, last_page: Int) in
            self.isLoading = false
            if let tasks = Tasks {
                self.tasks = tasks
                self.tableView.reloadData()

                self.last_page = last_page
                self.current_page = 1

            }

        }
    }


    fileprivate func loadMore() {

        guard !isLoading else { return }
        guard current_page < last_page else { return }

        isLoading = true
        API.Tasks.getTasks(page: current_page + 1) { (Tasks: [Task]?, error: Error?, last_page: Int) in
            self.isLoading = false
            if let tasks = Tasks {
                self.tasks.append(contentsOf: tasks)
                self.tableView.reloadData()

                self.last_page = last_page
                self.current_page += 1

            }
        }
    }
}

extension TaskVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        
        let task = tasks[indexPath.row]
        cell.configureCell(task: task)
        
        return cell
    }


}


extension TaskVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    // user selection hide
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return false
        return true
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = self.tasks.count
        if indexPath.row == count - 1 {
            self.loadMore()
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let task = tasks[indexPath.row]

        let deleteAction = UITableViewRowAction.init(style: .default, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in

            self.handleDelete(task: task, indexPath: indexPath)
        }
        deleteAction.backgroundColor = .red

        let editAction = UITableViewRowAction.init(style: .default, title: "Edit") { (action: UITableViewRowAction, indexPath: IndexPath) in
            self.handleEdit(task: task, indexPath: indexPath)
        }
        editAction.backgroundColor = .lightGray
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        
        let editTask = task.copy() as! Task
        
        editTask.completed = !editTask.completed!
        
        API.Tasks.editTask(task: editTask) { (editTask:Task?, error:Error?) in
            
            if let editTask = editTask {
                if let index = self.tasks.index(of: task){
                    self.tasks.remove(at: index)
                    self.tasks.insert(editTask, at: index)
                    
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                }else{
                    self.loadData()
                }
            }
        }
        
    }


    private func handleDelete(task: Task, indexPath: IndexPath) {
        API.Tasks.deleteTask(task: task) { (success: Bool, error: Error?) in
            if success {
                if let index = self.tasks.firstIndex(of: task) {
                    self.tasks.remove(at: index)

                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                } else {
                    self.tableView.reloadData()
                }

            } else {

            }
        }
    }
    private func handleEdit(task: Task, indexPath: IndexPath) {

        let alert = UIAlertController.init(title: "Edit task", message: "Enter Title", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        alert.addTextField { (txt: UITextField) in
            txt.text = task.task
            txt.placeholder = "Title"
            txt.textAlignment = .center
        }
        alert.addAction(UIAlertAction.init(title: "Edit", style: UIAlertAction.Style.destructive, handler: { (action: UIAlertAction) in

            guard let title = alert.textFields?.first?.text?.trimmed, !title.isEmpty else { return }
            // edit task
            // copy because i used class
            let editTask = task.copy() as! Task
            editTask.task = title
            
            
            API.Tasks.editTask(task: editTask, completion: { (editTask: Task?, error: Error?) in

                if let editTask = editTask {
                    
                    if let index = self.tasks.firstIndex(of: editTask) {
                        
                        self.tasks.remove(at: index)
                        self.tasks.insert(editTask, at: index)

                        // refresh table view
                        self.tableView.beginUpdates()
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        self.tableView.endUpdates()
                    } else {
                        self.loadData()
                    }
                } else {

                }
            })
        }))

        present(alert, animated: true, completion: nil)
    }
}
