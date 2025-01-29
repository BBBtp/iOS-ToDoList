//
//  TaskModel.swift
//  ToDoList
//
//  Created by Богдан Топорин on 29.01.2025.
//

import Foundation


struct TaskModel {
    var id: Int
    var title: String?
    var todo: String?
    var createdAt: Date
    var isCompleted: Bool
    var userId: Int
    
    init(id: Int,title: String, todo: String, createdAt: Date, isCompleted: Bool, userId: Int) {
        self.id = id
        self.title = title
        self.todo = todo
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.userId = userId
    }
}
