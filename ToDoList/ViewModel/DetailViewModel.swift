//
//  DetailViewModel.swift
//  ToDoList
//
//  Created by Богдан Топорин on 01.02.2025.
//

final class DetailViewModel {
    var task: TaskModel

    init(task: TaskModel) {
        self.task = task
    }
    //MARK: - Public Methods
    func updateTask(title: String, description: String, date: String) {
        task.todo = description
        task.title = title
        task.createdAt = date
    }
    
    func createTask(title: String, description: String, date: String) -> TaskModel {
        if task.id == -1 { 
            task.id = Int.random(in: 1000...100000)
            task.userId = Int.random(in: 1000...100000)
        }
        task.title = title
        task.todo = description
        task.createdAt = date
        return task
    }
}
