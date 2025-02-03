//
//  TaskDetailViewController.swift
//  ToDoListTests
//
//  Created by Богдан Топорин on 04.02.2025.
//
import XCTest
@testable import ToDoList

class DetailViewControllerTests: XCTestCase {
    
    var viewController: DetailViewController!
    var mockDelegate: MockTaskUpdateDelegate!
    var detailViewModel: DetailViewModel!
    
    override func setUp() {
        super.setUp()
        let task = TaskModel(id: 1, title: "Test Task", todo: "Test Description", completed: false, userId: 1, createdAt: "2025-01-01")
        detailViewModel = DetailViewModel(task: task)
        viewController = DetailViewController(taskDetailViewModel: detailViewModel, at: IndexPath(row: 0, section: 0), isCreate: false)
        mockDelegate = MockTaskUpdateDelegate()
        viewController.delegate = mockDelegate
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        mockDelegate = nil
        detailViewModel = nil
        super.tearDown()
    }
    
    func testUpdateTask() {
        viewController.didUpdateTask(title: "Updated Title", description: "Updated Description", date: "2025-01-02")
        
        XCTAssertEqual(detailViewModel.task.title, "Updated Title")
        XCTAssertEqual(detailViewModel.task.todo, "Updated Description")
    }
    
    func testDelegateCalledOnUpdate() {
        viewController.didUpdateTask(title: "Updated Title", description: "Updated Description", date: "2025-01-02")
        viewController.viewWillDisappear(true)
        XCTAssertTrue(mockDelegate.didUpdateTaskCalled)
    }
    
   
    func testCreateTask() {
        
        viewController = DetailViewController(taskDetailViewModel: detailViewModel, at: nil, isCreate: true)
        viewController.delegate = mockDelegate
        viewController.loadViewIfNeeded()
        viewController.didCreateTask(title: "New Task", description: "New Description", date: "2025-01-03")
        viewController.viewWillDisappear(true)
        XCTAssertTrue(mockDelegate.didCreateTaskCalled)
    }
}

class MockTaskUpdateDelegate: TaskUpdateDelegate {
    var didUpdateTaskCalled = false
    var didCreateTaskCalled = false
    
    func didUpdateTask(_ task: TaskModel?, at indexPath: IndexPath) {
        didUpdateTaskCalled = true
    }
    
    func didCreateTask(task: TaskModel) {
        didCreateTaskCalled = true
    }
}
