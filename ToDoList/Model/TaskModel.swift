//
//  TaskModel.swift
//  ToDoList
//
//  Created by Богдан Топорин on 29.01.2025.
//

import Foundation


struct TaskModelResponse: Codable {
    var id: Int
    var todo: String
    var completed: Bool
    var userId: Int
    
    init(id: Int, todo: String, completed: Bool, userId: Int) {
        self.id = id
        self.todo = todo
        self.completed = completed
        self.userId = userId
    }
}

struct TaskModel: Codable {
    var id: Int
    var title: String?
    var todo: String
    var completed: Bool
    var userId: Int
    var createdAt: String?
    
    init(id: Int,title: String?, todo: String, completed: Bool, userId: Int, createdAt: String?) {
        self.id = id
        self.title = title
        self.todo = todo
        self.completed = completed
        self.userId = userId
        self.createdAt = createdAt
    }
}
