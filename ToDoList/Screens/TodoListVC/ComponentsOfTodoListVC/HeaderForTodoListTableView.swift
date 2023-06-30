//
//  HeaderForTodoListTableView.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 29.06.2023.
//

import Foundation
import UIKit

// MARK: - Protocol

protocol HeaderForTodoListTableViewDelegate: AnyObject {
    func showDoneTodoButton(completedTasksAreHidden: Bool)
}

// MARK: - Class

final class HeaderForTodoListTableView: UITableViewHeaderFooterView {
    
    // MARK: - Constants
    
    enum Constants {
        static let trailingInsetForShowHide: CGFloat = -16
        static let leadingInsetForIsDone: CGFloat = 16
    }
    
    // MARK: - Properties
    

    private let isDoneLabel: UILabel = {
        let label = UILabel()
        label.text = ConstantsText.isDone
        label.textColor = .placeholderText
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var showHideButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.saveColor, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .toDoHeadline
        button.setTitle(ConstantsText.show, for: .normal)
//        button.setTitle(ConstantsText.hide, for: .selected)
        button.setTitleColor(.systemGray, for: .highlighted)
        button.addTarget(self, action: #selector(showHideButtonTapped(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: HeaderForTodoListTableViewDelegate?
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundView?.backgroundColor = .clear
        addSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func addSubviews() {
        addSubview(isDoneLabel)
        addSubview(showHideButton)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            isDoneLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leadingInsetForIsDone),
            isDoneLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            showHideButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.trailingInsetForShowHide),
            showHideButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    @objc private func showHideButtonTapped(sender: UIButton) {
        delegate?.showDoneTodoButton(completedTasksAreHidden: !sender.isSelected)
    }
    
    func configureIsDoneLabel(count: Int) {
        isDoneLabel.text = ConstantsText.isDone + "\(count)"
    }
    
    func configureShowHideButton(completedTasksAreHidden: Bool) {
        if completedTasksAreHidden {
            showHideButton.setTitle(ConstantsText.show, for: .normal)
        } else {
            showHideButton.setTitle(ConstantsText.hide, for: .normal)
        }
    }
}
