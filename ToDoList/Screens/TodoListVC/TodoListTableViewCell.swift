//
//  TodoListTableViewCell.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 26.06.2023.
//

import UIKit

protocol TodoListTableViewCellDelegate: AnyObject {

    func statusChangedFor(id: String)
}

class TodoListTableViewCell: UITableViewCell {
    
    private let isDoneCircle: isDoneCircleControl = {
        let circle = isDoneCircleControl()
        circle.addTarget(self, action: #selector(isDoneCircleTapped(sender:)), for: .touchUpInside)
        circle.translatesAutoresizingMaskIntoConstraints = false
        return circle
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let todoItemLabel: UILabel = {
        let label = UILabel()
        label.font = .toDoBody
        label.numberOfLines = 3
        label.textColor = .text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deadlineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.font = .toDoSubhead
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .placeholderText
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dividedLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    weak var delegate: TodoListTableViewCellDelegate?
    private var todoCellViewModel: TodoCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(isDoneCircle)
        contentView.addSubview(stackView)
        contentView.addSubview(deadlineStackView)
        contentView.addSubview(chevronImageView)
        contentView.addSubview(dividedLineView)
        stackView.addArrangedSubview(todoItemLabel)
        stackView.addArrangedSubview(deadlineLabel)
    }
    
    private func addConstraints() {

        let heightConstraint = isDoneCircle.heightAnchor.constraint(equalToConstant: 24)
        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            isDoneCircle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            heightConstraint,
            isDoneCircle.widthAnchor.constraint(equalToConstant: 24),
            isDoneCircle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            deadlineStackView.leadingAnchor.constraint(equalTo: isDoneCircle.trailingAnchor, constant: 16),

            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: isDoneCircle.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            dividedLineView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            dividedLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividedLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dividedLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .subviewsBackground
        contentView.layer.cornerRadius = 16.0

        addSubviews()
        addConstraints()
    }
    
    func configureCellWith(model: TodoCellViewModel, setTopMaskedCorners: Bool) {
        todoCellViewModel = model
        todoItemLabel.attributedText = model.text
        deadlineLabel.attributedText = model.deadline
        if model.importance == .high {
            isDoneCircle.setRedColorForCircle(isHighImportance: true)
        } else {
            isDoneCircle.setRedColorForCircle(isHighImportance: false)
        }
        isDoneCircle.isSelected = model.isDone
        
        if setTopMaskedCorners {
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            contentView.layer.maskedCorners = []
        }
    }
    
    @objc private func isDoneCircleTapped(sender: UIControl) {
        guard let model = todoCellViewModel else { return }
        delegate?.statusChangedFor(id: model.id)
    }
}
