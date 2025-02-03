//
//  TaskListView.swift
//  ToDoList
//
//  Created by Богдан Топорин on 29.01.2025.
//
import Foundation
import UIKit
import SnapKit
import SkeletonView

final class TaskListView: UIView {
    
    // MARK: - Public properties
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = A.Colors.whiteDynamic.color
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.register(TaskTableViewCell.self)
        return tableView
    }()
    
    let countTaskTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.backgroundColor = A.Colors.lightGrayDynamic.color
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.register(TaskCountTableViewCell.self)
        return tableView
    }()
  
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        backgroundColor = A.Colors.whiteDynamic.color
    }
    
    private func setupLayout() {
        addSubview(tableView)
        addSubview(countTaskTableView)
        countTaskTableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(83)
        }
        tableView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(countTaskTableView.snp.top)
        }
    }
}
