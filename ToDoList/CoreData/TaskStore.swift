//
//  TaskStore.swift
//  ToDoList
//
//  Created by Богдан Топорин on 29.01.2025.
//

import Foundation
import CoreData
import UIKit

struct TaskStoreUpdate {
    let insertedSections: [Int]
    let deletedSections: [Int]
    let insertedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
    let updatedIndexes: [IndexPath]
    let movedIndexes: [(from: IndexPath, to: IndexPath)]
}

protocol TaskStoreDelegate: AnyObject {
    func didUpdate(_ update: TaskStoreUpdate)
}

final class TaskStore: NSObject {
    
    private let context: NSManagedObjectContext
    weak var delegate: TaskStoreDelegate?
    private var insertedSections: [Int] = []
    private var deletedSections: [Int] = []
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    private var updatedIndexes: [IndexPath] = []
    private var movedIndexes: [(from: IndexPath, to: IndexPath)] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        let fetchRequest = Task.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "todo", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            print("Error performing fetch: \(error.localizedDescription)")
        }
        
        return controller
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
    }
    
    override init() {
        let context = CoreDataManager.shared.context
        self.context = context
    }
    //MARK: - Public Methods
    
    func syncWithAPI(tasks: [TaskModel]) {
        for taskModel in tasks {
            if let existingTask = getTask(by: taskModel.id) {
                updateTaskInCoreData(updatedTask: taskModel, at: existingTask)
            } else {
                addTask(task: taskModel)
            }
        }
    }
    
    func addTask(task: TaskModel) {
        do {
            try addTask(taskModel: task)
            
        } catch {
            print("Ошибка при добавлении задачи: \(error)")
        }
    }
    
    func updateTask(updatedTask: TaskModel, at id: Int) {
        do{
            try updateTask(at: Int64(id), taskModel: updatedTask)
        } catch {
            print("Ошибка при изменении задачи: \(error)")
        }
    }
    
    
    func fetchTasks() -> [TaskModel] {
        var taskModels: [TaskModel] = []
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        do {
            let tasks = try context.fetch(fetchRequest)
            taskModels = tasks.map { task in
                let taskResponse = TaskModelResponse(
                    id: Int(task.id),
                    todo: task.todo ?? "",
                    completed: task.isCompleted,
                    userId: Int(task.userId)
                )
                return TaskModel(
                    id: taskResponse.id,
                    title: task.title,
                    todo: taskResponse.todo,
                    completed: taskResponse.completed,
                    userId: taskResponse.userId,
                    createdAt: task.createdAt 
                )
            }
        } catch {
            print("Ошибка при извлечении задач из Core Data: \(error.localizedDescription)")
        }
        
        return taskModels
    }

    
    func deleteTask(at id: Int) {
        do{
            try deleteTaskFromCoreData(at: Int64(id))
        } catch {
            print("Ошибка при удалении задачи: \(error)")
        }
    }
    
    func deleteAllTasks() {
        do{
            try deleteAll()
        } catch {
            print("Ошибка при удалении \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func addTask(taskModel: TaskModel) throws {
        let newTask = Task(context: context)
        newTask.id = Int64(taskModel.id)
        newTask.title = taskModel.title
        newTask.todo = taskModel.todo
        newTask.isCompleted = taskModel.completed
        newTask.userId = Int64(taskModel.userId)
        newTask.createdAt = taskModel.createdAt
        
        do {
            try context.save()
        } catch {
            print("Failed to save task: \(error.localizedDescription)")
        }
    }
    
    private func deleteAll() throws {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let trackers = try context.fetch(fetchRequest)
        trackers.forEach { context.delete($0) }
        try context.save()
    }

    private func updateTask(at id: Int64, taskModel: TaskModel) throws {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %lld", id)

        do {
            let tasks = try context.fetch(fetchRequest)

            guard let task = tasks.first else {
                print("❌ Задача с id \(id) не найдена")
                return
            }
            task.todo = taskModel.todo
            task.isCompleted = taskModel.completed
            task.userId = Int64(taskModel.userId)
            task.title = taskModel.title
            task.createdAt = taskModel.createdAt
            try context.save()
        } catch {
            print("❌ Ошибка обновления задачи: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func updateTaskInCoreData(updatedTask: TaskModel, at task: Task) {
        task.title = updatedTask.title
        task.createdAt = updatedTask.createdAt
        task.todo = updatedTask.todo
        task.isCompleted = updatedTask.completed
        task.userId = Int64(updatedTask.userId)
        try? context.save()
    }
    
    private func deleteTaskFromCoreData(at id: Int64) throws {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %lld", id)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            if let taskToDelete = tasks.first {
                context.delete(taskToDelete)
                try context.save()
            }
        } catch {
            print("Ошибка удаления задачи: \(error.localizedDescription)")
        }
    }
    
    private func getTask(by id: Int) -> Task? {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            return tasks.first
        } catch {
            print("Error fetching task by id: \(error.localizedDescription)")
            return nil
        }
    }
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TaskStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSections.removeAll()
        deletedSections.removeAll()
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
        updatedIndexes.removeAll()
        movedIndexes.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.append(sectionIndex)
        case .delete:
            deletedSections.append(sectionIndex)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes.append(newIndexPath)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexes.append(indexPath)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndexes.append((from: oldIndexPath, to: newIndexPath))
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TaskStoreUpdate(
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            updatedIndexes: updatedIndexes,
            movedIndexes: movedIndexes
        )
        delegate?.didUpdate(update)
    }
}
