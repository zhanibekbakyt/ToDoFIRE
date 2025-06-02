//
//  TasksViewController.swift
//  ToDoFIRE
//
//  Created by Zhanibek Bakyt on 05.02.2025.
//

import UIKit
import Firebase
import FirebaseAuth

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value, with: { [weak self] (snapshot) in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tableView.reloadData()
        })
    }

    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = .clear
        let task = tasks[indexPath.row]
        let taskTitle = task.title
        let isCompleted = task.completed
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = taskTitle
        cell.accessoryType = isCompleted ? .checkmark : .none
        task.ref?.updateChildValues(["completed": isCompleted])
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let task = self.tasks[indexPath.row]
            
            let alertController = UIAlertController(title: "Edit Task",
                                                    message: "Update your task name",
                                                    preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.text = task.title
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let textField = alertController.textFields?.first,
                      let newTitle = textField.text, !newTitle.isEmpty,
                      newTitle != task.title else {
                    completionHandler(false)
                    return
                }
                
                let updatedTask = Task(title: newTitle, userId: self.user.uid)
                let updatedRef = self.ref.child(newTitle.lowercased())
                updatedRef.setValue(updatedTask.convertToDictionary())
                task.ref?.removeValue()
                
                completionHandler(true)
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            
            self.present(alertController, animated: true, completion: nil)
        }
        editAction.backgroundColor = .systemBlue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let task = self.tasks[indexPath.row]
            task.ref?.removeValue()
            completionHandler(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        
        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed": isCompleted])
    }
    
    func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }

    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField()
        
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first,
                  let taskTitle = textField.text, !taskTitle.isEmpty else { return }
            
            let task = Task(title: taskTitle, userId: self?.user.uid ?? "")
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
