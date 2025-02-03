//
//  TaskViewModelTests.swift
//  ToDoListTests
//
//  Created by Богдан Топорин on 04.02.2025.
//
import XCTest
@testable import ToDoList

class TaskViewModelTests: XCTestCase {
    
    var viewModel: TaskViewModel!
    
    override func setUp() {
        super.setUp()
        let apiClient = APIClient()
        let taskStore = TaskStore()
        viewModel = TaskViewModel(apiClient: apiClient, taskStore: taskStore)
        viewModel.deleteAll()
    }
    
    func testNumberOfTasks() {
        XCTAssertEqual(viewModel.numberOfTasks, 0)
    }
    
    func testAddTask() {
        let task = TaskModel(id: 1, title: "Test Task", todo: "Test Task", completed: false, userId: 1, createdAt: "")
        viewModel.addTask(task: task)
        
        XCTAssertEqual(viewModel.numberOfTasks, 1)
    }
    
    func testDeleteTask() {
        let task = TaskModel(id: 1, title: "Test Task", todo: "Test Task", completed: false, userId: 1, createdAt: "")
        viewModel.deleteTask(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(viewModel.numberOfTasks, 0)
    }
}
