//
//  TaskDetailViewController.swift
//  ToDoList
//
//  Created by Богдан Топорин on 29.01.2025.
//

import UIKit

protocol TaskUpdateDelegate: AnyObject {
    func didUpdateTask(_ task: TaskModel?, at indexPath: IndexPath)
    func didCreateTask(task: TaskModel)
}

final class DetailViewController: UIViewController {
    
    weak var delegate: TaskUpdateDelegate?
    
    private let taskDetailViewModel: DetailViewModel?
    let taskDetailView: TaskDetailView
    private let selectedIndexPath: IndexPath?
    private var isCreate: Bool
    // MARK: - Initializer
    
    init(taskDetailViewModel: DetailViewModel?, at indexPath: IndexPath?, isCreate: Bool) {
        
        self.taskDetailViewModel = taskDetailViewModel
        self.taskDetailView = TaskDetailView()
        self.selectedIndexPath = indexPath
        self.isCreate = isCreate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func loadView() {
        view = taskDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskDetailView.delegate = self
        view.backgroundColor = A.Colors.whiteDynamic.color
        navigationItem.largeTitleDisplayMode = .never
        let backButton = UIBarButtonItem()
        backButton.title = L.back
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = A.Colors.yellow.color
        taskDetailView.config(with: taskDetailViewModel?.task)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let task = taskDetailViewModel?.task,
              task.title != "",
              task.todo != "" else {
                return
            }
        
        if isCreate {
            if let task = taskDetailViewModel?.task {
                delegate?.didCreateTask(task: task)
            }
        } else {
            guard let selectedIndexPath else {return}
            delegate?.didUpdateTask(taskDetailViewModel?.task, at: selectedIndexPath)
        }
    }

}
// MARK: - TaskDetailViewDelegate
extension DetailViewController: TaskDetailViewDelegate {
    func didCreateTask(title: String, description: String, date: String) {
        taskDetailViewModel?.createTask(title: title, description: description, date: date)
    }
    
    func didUpdateTask(title: String, description: String, date: String) {
            taskDetailViewModel?.updateTask(title: title, description: description, date: date)
        }
}
