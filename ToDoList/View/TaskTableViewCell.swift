//
//  TaskCell.swift
//  ToDoList
//
//  Created by Богдан Топорин on 29.01.2025.
//

import UIKit
import SkeletonView
import SnapKit

protocol TaskCellDelegate: AnyObject {
    func didTapStatusButton(at indexPath: IndexPath)
    func didTapDeleteButton(at indexPath: IndexPath)
    func didTapTaskCell(at indexPath: IndexPath)
}


final class TaskTableViewCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - Private properties
    weak var delegate: TaskCellDelegate?
    private var indexPath: IndexPath?
    
    private enum Constants {
        static let skeletonText = "             "
        enum ImageView {
            static let cornerRadius: CGFloat = 12
            static let widthAndHeight: CGFloat = 108
        }
        enum InfoStackView {
            static let spacing: CGFloat = 4
            static let leadingInset: CGFloat = 20
            static let height: CGFloat = 42
        }
        enum PriceStackView {
            static let spacing: CGFloat = 2
            static let width: CGFloat = 100
        }
        enum ViewWithContent {
            static let inset: CGFloat = 20
        }
        enum DeleteButton {
            static let widthAndHeight: CGFloat = 40
        }
    }
    
    private let viewWithContent: UIView = {
        let view = UIView()
        view.backgroundColor = A.Colors.whiteDynamic.color
        return view
    }()

    private let statusButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.backgroundColor = A.Colors.whiteDynamic.color
        button.addTarget(self, action: #selector(handleButtonPressDown), for: .touchDown)
        button.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(handleButtonPressUp), for: [.touchUpInside, .touchCancel, .touchDragExit])
        return button
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 6
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTaskTap))
        stackView.addGestureRecognizer(tapGesture)
        for subview in [titleLabel, todoLabel,dateLabel] {
            stackView.addArrangedSubview(subview)
        }
        stackView.skeletonCornerRadius = 12
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .Medium.medium
        label.textColor = A.Colors.blackDynamic.color
        label.text = Constants.skeletonText
        label.skeletonCornerRadius = 12
        return label
    }()
    
    private let todoLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.medium
        label.textColor = A.Colors.blackDynamic.color
        label.skeletonCornerRadius = 12
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.medium
        label.textColor = .gray
        label.text = Constants.skeletonText
        label.skeletonCornerRadius = 12
        return label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
        setupContextMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Context Menu
    
    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        viewWithContent.addInteraction(interaction)
    }
    
    // MARK: - Overridden methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Public methods
    
    func configCell(model: TaskModel, at indexPath: IndexPath) {
        self.indexPath = indexPath
        updateStatusButton(isCompleted: model.completed)
        titleLabel.text = model.title
        todoLabel.text = model.todo
        dateLabel.text = model.createdAt
        let textColor: UIColor = model.completed ? .gray : A.Colors.blackDynamic.color
        titleLabel.textColor = textColor
        titleLabel.textColor = textColor
        todoLabel.textColor = textColor
    }
    
    func updateStatusButton(isCompleted: Bool) {
        let image = isCompleted ? A.Icons.complete.image : A.Icons.uncomplete.image
        self.statusButton.setImage(image, for: .normal)
    }

    // MARK: - Private methods
    
    private func setupUI() {
        backgroundColor = A.Colors.whiteDynamic.color
        contentView.addSubview(viewWithContent)
        viewWithContent.isUserInteractionEnabled = true

        [titleStackView,statusButton].forEach {
            viewWithContent.addSubview($0)
        }
        
        [viewWithContent, titleStackView,statusButton].forEach {
            $0.isSkeletonable = true
        }
        
        self.isSkeletonable = true
        contentView.isSkeletonable = true
    }
    
    private func setupLayout() {
        viewWithContent.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints { make in
            make.leading.equalTo(statusButton.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(12)
            make.width.equalTo(288)
        }
        
        statusButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.height.equalTo(24)
        }
    }
}

extension TaskTableViewCell {
    @objc private func handleButtonPressDown() {
        UIView.animate(withDuration: 0.2) {
            self.statusButton.alpha = 0.6
            self.statusButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func handleButtonPressUp() {
        UIView.animate(withDuration: 0.2) {
            self.statusButton.alpha = 1.0
            self.statusButton.transform = .identity
        }
    }
    
    @objc private func statusButtonTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapStatusButton(at: indexPath)
    }
    
    @objc private func handleTaskTap() {
            guard let indexPath = indexPath else { return }
            delegate?.didTapTaskCell(at: indexPath)
        }
}

// MARK: - UIContextMenuInteractionDelegate

extension TaskTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: L.edit, image: UIImage(systemName: "pencil")) { [weak self] _ in
                guard let self = self, let indexPath = self.indexPath else { return }
                self.delegate?.didTapTaskCell(at: indexPath)
            }
            
            let shareAction = UIAction(title: L.share, image: UIImage(systemName: "square.and.arrow.up")) { _ in
            }
            
            let deleteAction = UIAction(title: L.delete, image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                guard let self = self, let indexPath = self.indexPath else { return }
                self.delegate?.didTapDeleteButton(at: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
    
    private func setHighlightedAppearance() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.backgroundColor = A.Colors.lightGrayDynamic.color
            self.viewWithContent.backgroundColor = A.Colors.lightGrayDynamic.color
            self.titleLabel.textColor = A.Colors.blackDynamic.color
            self.todoLabel.textColor = A.Colors.blackDynamic.color
            self.dateLabel.textColor = .gray
            self.statusButton.isHidden = true
        }
    }

    private func setDefaultAppearance() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.backgroundColor = A.Colors.whiteDynamic.color
            self.viewWithContent.backgroundColor = A.Colors.whiteDynamic.color
            self.titleLabel.textColor = A.Colors.blackDynamic.color
            self.todoLabel.textColor = A.Colors.blackDynamic.color
            self.dateLabel.textColor = A.Colors.lightGrayDynamic.color
            self.statusButton.isHidden = false
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
            setHighlightedAppearance()
        }

        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
            setDefaultAppearance()
        }
}

