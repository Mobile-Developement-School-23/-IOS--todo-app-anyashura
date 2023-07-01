//
//  ImportanceView.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 20.06.2023.
//

import Foundation
import UIKit

protocol ImportanceViewDelegate: AnyObject {
    func selectedImportance(importance: TodoItem.Importance)
}

final class ImportanceView: UIView {

    // MARK: - Enum
    enum Constants {
        static let insetsForImportance = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        static let insetsForSegmentedControl = UIEdgeInsets(top: 10, left: 0, bottom: -11, right: -12)
        static let insetsForDividedLine = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        static let dividedLineHeight: CGFloat = 1.0
        static let importanceCornerRadius: CGFloat = 16.0
        static let leadingInset: CGFloat = 16.0
        static let widthSegmentedControl: CGFloat = 150
        static let lowImportanceImage = "lowImportance"
        static let highImportanceImage = "highImportance"
    }

    // MARK: - Properties

    private let importanceLabel: UILabel = {
        let importanceLabel = UILabel()
        importanceLabel.translatesAutoresizingMaskIntoConstraints = false
        importanceLabel.text = ConstantsText.importance
        importanceLabel.font = .toDoBody
        importanceLabel.textColor = .text
        return importanceLabel
    }()

    private lazy var importanceSegmentedControl: UISegmentedControl = {
        let importance = UISegmentedControl()
        importance.translatesAutoresizingMaskIntoConstraints = false
        importance.insertSegment(with: UIImage(named: Constants.lowImportanceImage), at: 0, animated: true)
        importance.insertSegment(withTitle: "нет", at: 1, animated: true)
        importance.insertSegment(with: UIImage(named: Constants.highImportanceImage), at: 2, animated: true)
        importance.selectedSegmentIndex = 1
        importance.widthAnchor.constraint(equalToConstant: Constants.widthSegmentedControl).isActive = true
        importance.addTarget(self, action: #selector(switchImportance), for: .valueChanged)
        importance.backgroundColor = .segment
        importance.selectedSegmentTintColor = .segmentSelected
        let font = UIFont.toDoSubhead
        importance.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        return importance
    }()

    weak var delegate: ImportanceViewDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .subviewsBackground
        addSubviews()
        addConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func addSubviews() {
        addSubview(importanceLabel)
        addSubview(importanceSegmentedControl)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            importanceLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            importanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leadingInset),

            importanceSegmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: Constants.insetsForSegmentedControl.top),
            importanceSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.insetsForSegmentedControl.right),
            importanceSegmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.insetsForSegmentedControl.bottom)
        ])
    }

    @objc private func switchImportance(sender: UISegmentedControl) {
        var importance = TodoItem.Importance.normal
        switch importanceSegmentedControl.selectedSegmentIndex {
        case 0: importance = .low
        case 2: importance = .high
        default: importance = .normal
        }
        delegate?.selectedImportance(importance: importance)
    }

    // MARK: - Public methods

    func changeImportance(importance: TodoItem.Importance) {
        switch importance {
        case .low: importanceSegmentedControl.selectedSegmentIndex = 0
        case .normal: importanceSegmentedControl.selectedSegmentIndex = 1
        case .high: importanceSegmentedControl.selectedSegmentIndex = 2
        }
    }
}
