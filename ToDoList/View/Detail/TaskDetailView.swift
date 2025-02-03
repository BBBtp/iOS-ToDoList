//
//  TaskDetailView.swift
//  ToDoList
//
//  Created by Богдан Топорин on 01.02.2025.
//
import UIKit
import SnapKit
import SkeletonView


protocol TaskDetailViewDelegate: AnyObject {
    func didUpdateTask(title: String, description: String, date: String)
    func didCreateTask(title: String, description: String, date: String)
}

final class TaskDetailView: UIView {

    weak var delegate: TaskDetailViewDelegate?
    
    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.font = .Bold.large
        textView.textColor = A.Colors.blackDynamic.color
        textView.textAlignment = .left
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false // Отключаем прокрутку
        textView.textContainer.lineBreakMode = .byWordWrapping // Перенос слов
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) // Дополнительные отступы
        return textView
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .Medium.medium
        textView.textColor = A.Colors.blackDynamic.color
        textView.textAlignment = .left
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false // Отключаем прокрутку
        textView.textContainer.lineBreakMode = .byWordWrapping // Перенос слов
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) // Дополнительные отступы
        return textView
    }()

    private let dateTextView: UITextView = {
        let textView = UITextView()
        textView.font = .Regular.medium
        textView.textColor = A.Colors.blackDynamic.color
        textView.textAlignment = .left
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false // Отключаем прокрутку
        textView.textContainer.lineBreakMode = .byWordWrapping // Перенос слов
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) // Дополнительные отступы
        return textView
    }()

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDelegates()
    }
    
    func config(with model: TaskModel?) {
        guard let model = model else {return}
        self.titleTextView.text = model.title
        self.descriptionTextView.text = model.todo
        self.dateTextView.text = model.createdAt
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [titleTextView, descriptionTextView, dateTextView].forEach {
            addSubview($0)
        }
        
        titleTextView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        dateTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextView.snp.bottom)
            make.left.equalTo(descriptionTextView.snp.left)
            make.right.equalTo(descriptionTextView.snp.right)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(dateTextView.snp.bottom).offset(16)
            make.left.equalTo(titleTextView.snp.left)
            make.right.equalTo(titleTextView.snp.right)
            make.height.equalTo(120)
        }
        titleTextView.tintColor = A.Colors.yellow.color
        descriptionTextView.tintColor = A.Colors.yellow.color
        titleTextView.becomeFirstResponder()
    }
    
    private func setupDelegates() {
            titleTextView.delegate = self
            descriptionTextView.delegate = self
            dateTextView.delegate = self
        }
    
    private func getCurrentDateString() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: Date())
        }
}

extension TaskDetailView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                if textView == titleTextView {
                    descriptionTextView.becomeFirstResponder()
                    dateTextView.text = getCurrentDateString()
                    return false
                } else if textView == descriptionTextView {
                    textView.resignFirstResponder()
                    return false
                }
            }
            return true
        }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.didUpdateTask(
            title: titleTextView.text ?? "",
            description: descriptionTextView.text ?? "",
            date: dateTextView.text ?? ""
        )
        
        delegate?.didCreateTask(
            title: titleTextView.text ?? "",
            description: descriptionTextView.text ?? "",
            date: dateTextView.text ?? ""
        )
    }
}
