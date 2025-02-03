//
//  TaskCountTableViewCell.swift
//  ToDoList
//
//  Created by Богдан Топорин on 30.01.2025.
//

import UIKit
import SnapKit

protocol TaskCountTableViewCellDelegate: AnyObject {
    func didCreateTask()
}

final class TaskCountTableViewCell: UITableViewCell, ReuseIdentifying {
    
    
    weak var delegate: TaskCountTableViewCellDelegate?
    // MARK: - UI Elements
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.small
        label.textColor = A.Colors.blackDynamic.color
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = A.Colors.yellow.color
        button.backgroundColor = A.Colors.lightGrayDynamic.color
        button.layer.cornerRadius = 24
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(handleTapAddButton), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    // MARK: - Overridden methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func config(with taskCount: Int) {
        countLabel.text = L.Task.myTasks(taskCount)
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        contentView.addSubview(countLabel)
        contentView.addSubview(addButton)
        contentView.backgroundColor = A.Colors.lightGrayDynamic.color
        
        [contentView,countLabel,addButton].forEach {
            $0.isSkeletonable = true
        }
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(40)
        }
    }
}

extension TaskCountTableViewCell {
    @objc func handleTapAddButton() {
        delegate?.didCreateTask()
    }
}
