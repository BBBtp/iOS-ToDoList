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
            sectionNameKeyPath: "todo",
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

    // MARK: - Private Methods
    private func addTask(taskModel: TaskModel) throws {
        let newTask = Task(context: context)
        newTask.id = Int64(taskModel.id)
        newTask.title = taskModel.title
        newTask.todo = taskModel.todo
        newTask.createdAt = taskModel.createdAt
        newTask.isCompleted = taskModel.isCompleted
        newTask.userId = Int64(taskModel.userId)
        try? context.save()
    }
    
    private func updateTask(at indexPath: IndexPath, taskModel: TaskModel) throws {
        let task = fetchedResultsController.object(at: indexPath)
        task.title = taskModel.title
        task.todo = taskModel.todo
        task.createdAt = taskModel.createdAt
        task.isCompleted = taskModel.isCompleted
        task.userId = Int64(taskModel.userId)
        try? context.save()
    }
    
    private func deleteTask(at indexPath: IndexPath) throws {
        let task = fetchedResultsController.object(at: indexPath)
        context.delete(task)
        try? context.save()
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
