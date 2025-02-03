//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by Богдан Топорин on 29.01.2025.
//

import Foundation

protocol TaskViewModelDelegate: AnyObject {
    func didUpdateTasks()
}

class TaskViewModel {
    
    private let apiClient: APIClient
    private let taskStore: TaskStore
    weak var delegate: TaskViewModelDelegate?
    
    private var allTasks: [TaskModel]? {
        didSet {
            delegate?.didUpdateTasks()
            onNFTListLoaded?()
        }
    }
   
    private(set) var tasks: [TaskModel]? {
        didSet {
            delegate?.didUpdateTasks()
            onNFTListLoaded?()
        }
    }
    
    var onNFTListLoaded: (() -> Void)?
    var onNFTListLoadError: ((String) -> Void)?
    var numberOfTasks: Int {
        return taskStore.numberOfItemsInSection(0)
    }
    
    private let isFirstLaunchKey = "isFirstLaunch"
    
    init(apiClient: APIClient, taskStore: TaskStore) {
        self.apiClient = apiClient
        self.taskStore = taskStore
    }
    //MARK: - Public Methods
    func updateTask(at index: IndexPath, updatedTask: TaskModel?) {
        guard let updatedTask = updatedTask else { return }
        taskStore.updateTask(updatedTask: updatedTask, at: updatedTask.id)
        loadTasksFromCoreData()
    }
    
    func addTask(task: TaskModel?) {
        guard let task = task else { return }
        taskStore.addTask(task: task)
        loadTasksFromCoreData()
    }
    
    func deleteTask(at index: IndexPath) {
        guard let taskToDelete = tasks?[index.row] else { return }
        
        taskStore.deleteTask(at: taskToDelete.id)
        loadTasksFromCoreData()
    }

    func fetchTasks() {
        if isFirstLaunch() {
            loadTasksFromAPI()
        } else {
            loadTasksFromCoreData()
        }
    }
    
    func filterTasks(with searchText: String?) {
        guard let searchText = searchText, !searchText.isEmpty, let allTasks = allTasks else {
            tasks = allTasks ?? []
            return
        }
        tasks = allTasks.filter { $0.todo.lowercased().contains(searchText.lowercased()) }
    }
    
    func task(at index: Int) -> TaskModel? {
        guard let tasks = tasks, index >= 0, index < tasks.count else { return nil }
        return tasks[index]
    }
    
    func getEmptyTask() -> TaskModel {
        let task = TaskModel(id: -1,
                             title: "",
                             todo: "",
                             completed: false,
                             userId: -1,
                             createdAt: "")
        return task
    }
    
    func deleteAll(){
        taskStore.deleteAllTasks()
    }
    
    //MARK: - Private Methods
    private func isFirstLaunch() -> Bool {
        let isFirstLaunch = UserDefaults.standard.bool(forKey: isFirstLaunchKey)
        if !isFirstLaunch {
            UserDefaults.standard.set(true, forKey: isFirstLaunchKey)
        }
        return !isFirstLaunch
    }
    
    private func loadTasksFromAPI() {
        apiClient.fetchTasks(skip: 0, limit: 30) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let tasks):
                self.processFetchedTasks(tasks.todos)
            case .failure(let error):
                self.handleFetchError(error)
            }
        }
    }

    private func loadTasksFromCoreData() {
        DispatchQueue.main.async {
            let tasks = self.taskStore.fetchTasks()
            self.allTasks = tasks
            self.tasks = tasks
        }
    }

    private func processFetchedTasks(_ tasks: [TaskModelResponse]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let taskModels = tasks.map { taskResponse in
                return TaskModel(
                    id: taskResponse.id,
                    title: nil,
                    todo: taskResponse.todo,
                    completed: taskResponse.completed,
                    userId: taskResponse.userId,
                    createdAt: nil
                )
            }
            
            self.syncWithCoreData(tasks: taskModels)

            DispatchQueue.main.async {
             
                self.allTasks = taskModels
                self.tasks = taskModels
            }
        }
    }

    private func handleFetchError(_ error: Error) {
        DispatchQueue.main.async {
            self.onNFTListLoadError?("Failed to fetch tasks: \(error.localizedDescription)")
        }
    }
    
    private func syncWithCoreData(tasks: [TaskModel]?) {
        guard let tasks = tasks else { return }
        taskStore.syncWithAPI(tasks: tasks)
    }
}
