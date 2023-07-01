//
//  AddNewTableViewCell.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 30.06.2023.
//

import UIKit

final class NewTableViewCell: UITableViewCell {

    // MARK: - Properties

    private let newItemLabel: UILabel = {
        let label = UILabel()
        label.text = ConstantsText.new
        label.textColor = .placeholderText
        label.font = .toDoBody
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configureCellWith(firstCell: Bool) {
        if firstCell {
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }

    private func configureUI() {
        backgroundColor = .subviewsBackground
        selectionStyle = .none
        layer.cornerRadius = 16

        addSubviews()
        addConstraints()
    }

    private func addSubviews() {
        contentView.addSubview(newItemLabel)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            newItemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 52),
            newItemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            newItemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            newItemLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17)
        ])
    }
}
