//
//  TaskListViewControllerTests.swift
//  ToDoListTests
//
//  Created by Богдан Топорин on 04.02.2025.
//
import XCTest
@testable import ToDoList

class TaskListViewControllerTests: XCTestCase {
    
    var viewController: TaskListViewController!
    var viewModel: TaskViewModel!
    
    override func setUp() {
        super.setUp()
        let apiClient = APIClient()
        let taskStore = TaskStore()
        viewModel = TaskViewModel(apiClient: apiClient, taskStore: taskStore)
        viewController = TaskListViewController(taskViewModel: viewModel)
        
        viewController.loadViewIfNeeded()
    }
    
    func testTableViewHasDataSource() {
        XCTAssertNotNil(viewController.taskListView.tableView.dataSource)
    }
    
    func testNumberOfRowsInSection() {
        viewModel.deleteAll()
        let task = TaskModel(id: 1, title: "Test Task", todo: "Test Task", completed: false, userId: 1, createdAt: "")
        viewModel.addTask(task: task)
        viewController.taskListView.tableView.reloadData()
        XCTAssertEqual(viewController.taskListView.tableView.numberOfRows(inSection: 0), 1)
    }
}
