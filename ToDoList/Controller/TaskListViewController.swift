// TaskListViewController.swift
// ToDoList
//
// Created by Богдан Топорин on 29.01.2025.
//

import UIKit
import SkeletonView

final class TaskListViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let taskViewModel: TaskViewModel
    let taskListView: TaskListView // для тестов убрали приват
    private let searchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: - Initializer
    
    init(taskViewModel: TaskViewModel) {
        self.taskViewModel = taskViewModel
        self.taskListView = TaskListView()
        super.init(nibName: nil, bundle: nil)
        self.taskViewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = taskListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        taskViewModel.fetchTasks()
        bind()
        taskListView.tableView.dataSource = self
        taskListView.countTaskTableView.dataSource = self
        taskListView.tableView.delegate = self
        taskListView.countTaskTableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showSkeletonIfNeeded()
    }
    
    // MARK: - Private methods
    
    private func configureNavigationBar() {
        navigationItem.title = L.tasksTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = A.Colors.whiteDynamic.color
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: A.Colors.blackDynamic.color,
        ]
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L.search
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.tintColor = A.Colors.blackDynamic.color
    }
    
    private func showSkeletonIfNeeded() {
        if taskViewModel.tasks == nil {
            taskListView.tableView.visibleCells.forEach {
                $0.showAnimatedSkeleton(transition: .crossDissolve(0.25))
            }
            taskListView.countTaskTableView.visibleCells.forEach {
                $0.showAnimatedSkeleton(transition: .crossDissolve(0.25))
            }
        }
    }
    
    private func bind() {
        taskViewModel.onNFTListLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.taskListView.tableView.reloadData()
                self?.taskListView.countTaskTableView.reloadData()
            }
        }
        taskViewModel.onNFTListLoadError = { [weak self] error in
            DispatchQueue.main.async {
                preconditionFailure(error)
            }
        }
    }

    private func reloadData() {
        taskListView.tableView.reloadData()
    }
    
    //MARK: - Public Methods
    func updateTaskCompletion(at indexPath: IndexPath, isCompleted: Bool) {
        var task = taskViewModel.task(at: indexPath.row)
        task?.completed = isCompleted
        guard let updatedTask = task else { return }
        
        taskViewModel.updateTask(at: indexPath, updatedTask: updatedTask)

        DispatchQueue.main.async {
            self.taskListView.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func deleteTask(at indexPath: IndexPath) {
        taskViewModel.deleteTask(at: indexPath)
        
        DispatchQueue.main.async {
            if self.taskViewModel.numberOfTasks > indexPath.row {
                self.taskListView.tableView.performBatchUpdates({
                    self.taskListView.tableView.deleteRows(at: [indexPath], with: .automatic)
                }, completion: nil)
            } else {
                self.taskListView.tableView.reloadData()
            }
        }
    }
}

// MARK: - TaskViewModelDelegate

extension TaskListViewController: TaskViewModelDelegate {
    func didUpdateTasks() {
        taskListView.tableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        taskListView.countTaskTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        
        if taskViewModel.numberOfTasks == 0 {
            let label = UILabel()
            label.text = L.empty
            label.textAlignment = .center
            label.textColor = .gray
            taskListView.tableView.backgroundView = label
        } else {
            taskListView.tableView.backgroundView = nil
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TaskListViewController: UITableViewDataSource, UITableViewDelegate, SkeletonTableViewDataSource {
    
    func collectionSkeletonView(
        _ skeletonView: UITableView,
        cellIdentifierForRowAt indexPath: IndexPath
    ) -> ReusableCellIdentifier {
        switch skeletonView {
        case taskListView.tableView:
            return TaskTableViewCell.defaultReuseIdentifier
        case taskListView.countTaskTableView:
            return TaskCountTableViewCell.defaultReuseIdentifier
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case taskListView.tableView:
            return taskViewModel.numberOfTasks
        case taskListView.countTaskTableView:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case taskListView.tableView:
            let cell: TaskTableViewCell = tableView.dequeueReusableCell()
            if let task = taskViewModel.task(at: indexPath.row) {
                cell.hideSkeleton(transition: .crossDissolve(0.25))
                cell.configCell(model: task, at: indexPath)
                cell.delegate = self
            }
            return cell
        case taskListView.countTaskTableView:
            let cell: TaskCountTableViewCell = tableView.dequeueReusableCell()
            cell.hideSkeleton(transition: .crossDissolve(0.25))
            cell.config(with: taskViewModel.numberOfTasks)
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = taskViewModel.task(at: indexPath.row)
        task?.completed.toggle()
        updateTaskCompletion(at: indexPath, isCompleted: task?.completed ?? false)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UISearchResultsUpdating

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        taskViewModel.filterTasks(with: searchController.searchBar.text)
    }
}

extension TaskListViewController: TaskStoreDelegate {
    func didUpdate(_ update: TaskStoreUpdate) {
        taskListView.tableView.performBatchUpdates({
            if !update.deletedIndexes.isEmpty {
                taskListView.tableView.deleteRows(at: update.deletedIndexes, with: .automatic)
            }
            if !update.deletedSections.isEmpty {
                taskListView.tableView.deleteSections(IndexSet(update.deletedSections), with: .automatic)
            }
            if !update.insertedSections.isEmpty {
                taskListView.tableView.insertSections(IndexSet(update.insertedSections), with: .automatic)
            }
            if !update.insertedIndexes.isEmpty {
                taskListView.tableView.insertRows(at: update.insertedIndexes, with: .automatic)
            }
            if !update.updatedIndexes.isEmpty {
                taskListView.tableView.reloadRows(at: update.updatedIndexes, with: .automatic)
            }
            for move in update.movedIndexes {
                taskListView.tableView.moveRow(at: move.from, to: move.to)
            }
        }, completion: nil)
    }
}

// MARK: - TaskCellDelegate
extension TaskListViewController: TaskCellDelegate {
    func didTapTaskCell(at indexPath: IndexPath) {
        guard let task = taskViewModel.task(at: indexPath.row) else { return }
        let detailViewModel = DetailViewModel(task: task)
        let detailVC = DetailViewController(taskDetailViewModel: detailViewModel, at: indexPath, isCreate: false)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func didTapStatusButton(at indexPath: IndexPath) {
        guard var task = taskViewModel.task(at: indexPath.row) else { return }
        updateTaskCompletion(at: indexPath, isCompleted: !task.completed)
    }
    
    func didTapDeleteButton(at indexPath: IndexPath) {
        deleteTask(at: indexPath)
    }
}

// MARK: - TaskCountTableViewCellDelegate
extension TaskListViewController: TaskCountTableViewCellDelegate {
    func didCreateTask() {
        let task = taskViewModel.getEmptyTask()
        let detailViewModel = DetailViewModel(task: task)
        let detailVC = DetailViewController(taskDetailViewModel: detailViewModel, at: nil, isCreate: true)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
// MARK: - TaskUpdateDelegate
extension TaskListViewController: TaskUpdateDelegate {
    func didUpdateTask(_ task: TaskModel?, at indexPath: IndexPath) {
        taskViewModel.updateTask(at: indexPath, updatedTask: task)
        DispatchQueue.main.async {
            self.taskListView.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func didCreateTask(task: TaskModel) {
        taskViewModel.addTask(task: task)
        DispatchQueue.main.async {
            self.taskListView.tableView.reloadData()
        }
    }
}
