//
//  DeadLineView.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 21.06.2023.
//

import Foundation
import UIKit

protocol DeadLineViewDelegate: AnyObject {
    @MainActor func dateButtonTapped()
    @MainActor func switcherTapped(isOn: Bool)
}

final class DeadLineView: UIView {

    // MARK: - Enum
    enum Constants {
        static let textViewCornerRadius: CGFloat = 16.0
        static let insetsForStackView = UIEdgeInsets(top: 9, left: 16, bottom: 16, right: 0)
        static let rightInsetForSwitcher: CGFloat = -12.0
        static let insetsForDividedLine = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        static let heightForDate: CGFloat = 18
    }

    // MARK: - Properties

    private let deadlineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let deadlineBeforeLabel: UILabel = {
        let label = UILabel()
        label.text = ConstantsText.deadlineBefore
        label.font = .toDoBody
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateOfDeadlineButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.saveColor, for: .normal)
        button.titleLabel?.font = .toDoFootnote
        button.setTitle("", for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var switcherForDeadline: UISwitch = {
        let switcherForDeadline = UISwitch()
        switcherForDeadline.subviews[0].subviews[0].backgroundColor = .segment
        switcherForDeadline.addTarget(self, action: #selector(switcherTapped(_:)), for: .valueChanged)
        switcherForDeadline.translatesAutoresizingMaskIntoConstraints = false
        return switcherForDeadline
    }()

    weak var delegate: DeadLineViewDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .subviewsBackground

        addSubviews()
        addConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func addSubviews() {
        addSubview(switcherForDeadline)
        addSubview(deadlineStackView)
        deadlineStackView.addArrangedSubview(deadlineBeforeLabel)
        deadlineStackView.addArrangedSubview(dateOfDeadlineButton)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            deadlineStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.insetsForStackView.left),
            deadlineStackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            dateOfDeadlineButton.heightAnchor.constraint(equalToConstant: Constants.heightForDate),
            dateOfDeadlineButton.leadingAnchor.constraint(equalTo: deadlineStackView.leadingAnchor),

            switcherForDeadline.centerYAnchor.constraint(equalTo: centerYAnchor),
            switcherForDeadline.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: Constants.rightInsetForSwitcher
            )
        ])
    }

    @objc private func switcherTapped(_ sender: UISwitch) {
        delegate?.switcherTapped(isOn: sender.isOn)
    }

    @objc private func dateButtonTapped() {
        delegate?.dateButtonTapped()
    }

    // MARK: - Methods

    func switcherIsON(for date: Date) {
        dateOfDeadlineButton.isHidden = false
        setDate(date)
    }

    func switcherIsOff() {
        dateOfDeadlineButton.isHidden = true
        dateOfDeadlineButton.setTitle(nil, for: .normal)
    }

    func setDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = formatter.string(from: date)
        dateOfDeadlineButton.setTitle(dateString, for: .normal)
        dateOfDeadlineButton.isHidden = false
        deadlineStackView.layoutIfNeeded()
    }

    func setSwitch(isOn: Bool) {
        switcherForDeadline.isOn = isOn
        delegate?.switcherTapped(isOn: isOn)
    }
}
