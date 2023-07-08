//
//  DetailViewController.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 11.06.2023.
//

import UIKit
import CocoaLumberjackSwift
import FileCache

protocol DetailViewControllerDelegate: AnyObject {
    func itemDidChanged()
    func removeFromView(id: String)
    func updateFromView(todoItemView: TodoItemViewModel)

}

class DetailViewController: UIViewController {
    // MARK: - Enum
    enum Constants {
        static let deleteButtonText = ConstantsText.delete
        static let deleteButtonCornerRadius: CGFloat = 16
        static let deleteButtonHeight: CGFloat = 56
        static let spacing: CGFloat = 16
        static let insetsForTop = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        static let heightForTop: CGFloat = 56
        static let minimumLineSpacing: CGFloat = 10
        static let cornerRadiusForContainer: CGFloat = 16
        static let heightImportanceStack: CGFloat = 56
        static let heightDeadlineStack: CGFloat = 56
        static let heightTextView: CGFloat = 120
        static let insets = UIEdgeInsets(top: 17, left: 16, bottom: 12, right: 16)
    }
    
    // MARK: - Properties
    private var todoItemViewModel = TodoItemViewModel()
    private let fileCache = FileCache<TodoItem>()
    
    private let file = "first.json"
    private let firstDividedLine = DividedLineView()
    private let secondDividedLine = DividedLineView()
    private let id: String?
    
    private let networkingService = DefaultNetworkingService()
    var todoList = [TodoItem]()
    var completedItemsCountUpdated: ((Int) -> Void)?
    //        var todoListUpdated: (([TodoItemTableViewCell.DisplayData]) -> Void)?
    var errorOccurred: ((String) -> Void)?
    var updateActivityIndicatorState: ((Bool) -> Void)?
    var todoItemLoaded: ((TodoItem) -> Void)?
    var changesSaved: (() -> Void)?

    private var dataChanged: (() -> Void)?
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantsText.cancel, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let taskLabel: UILabel = {
        let label = UILabel()
        label.text = ConstantsText.task
        label.font = .toDoHeadline
        label.tintColor = .text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantsText.save, for: .normal)
        button.titleLabel?.font = .toDoBody
        button.setTitleColor(.saveColor, for: .normal)
        button.setTitleColor(.systemGray2, for: .disabled)
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackViewForAllViews: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let containerForStackView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cornerRadiusForContainer
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackViewForImportanceAndDeadline: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var textView: TextView = {
        let textView = TextView()
        textView.textAlignment = .left
        textView.backgroundColor = .subviewsBackground
        textView.font = .toDoBody
        textView.autocorrectionType = .no
        textView.layer.masksToBounds = true
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.delegateForText = self
        textView.textContainerInset = Constants.insets
        return textView
    }()
    
    private lazy var importanceView: ImportanceView = {
        let view = ImportanceView()
        view.delegate = self
        return view
    }()
    
    private lazy var deadLineView: DeadLineView = {
        let view = DeadLineView()
        view.delegate = self
        return view
    }()
    
    private lazy var deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.setTitleColor(.redColor, for: .normal)
        deleteButton.setTitleColor(.tertiaryLabel, for: .disabled)
        deleteButton.setTitle(Constants.deleteButtonText, for: .normal)
        deleteButton.titleLabel?.font = .toDoBody
        deleteButton.titleLabel?.textAlignment = .center
        deleteButton.layer.cornerRadius = Constants.deleteButtonCornerRadius
        deleteButton.backgroundColor = .subviewsBackground
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.isEnabled = false
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return deleteButton
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = .subviewsBackground
        datePicker.layer.masksToBounds = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerTapped(sender: )), for: .valueChanged)
        datePicker.isHidden = true
        return datePicker
    }()
    
    weak var delegate: DetailViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        secondDividedLine.isHidden = true
//        do {
//            try fileCache.loadFile(file: <#T##String#>, completion: <#T##(Result<[TodoItem], Error>) -> Void#>)
//        } catch {
//            DDLogError("File loading error")
//        }
        addSubviews()
        addConstraints()
        setUpObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let id = id else { return }
        loadFromCache(id: id)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let orientation = UIDevice.current.orientation
        
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            deleteButton.isHidden = true
            containerForStackView.isHidden = true
        default:
            deleteButton.isHidden = false
            containerForStackView.isHidden = false
        }
    }
    
    // MARK: - Init
    
    init(id: String?) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configure(todoItem: TodoItem) {
        todoItemViewModel = TodoItemViewModel(id: todoItem.id)
        updateView()
    }
}

// MARK: - Private methods

extension DetailViewController {
    private func loadFromCache(id: String) {
        if let todo = fileCache.todoItems.first(where: { $0.id == id }) {
            todoItemViewModel.importance = todo.importance
            todoItemViewModel.deadline = todo.deadline
            todoItemViewModel.id = todo.id
            todoItemViewModel.text = todo.text
            updateView()
        }
    }
    
    private func addSubviews() {
        view.addSubview(topStackView)
        topStackView.addArrangedSubview(cancelButton)
        topStackView.addArrangedSubview(taskLabel)
        topStackView.addArrangedSubview(saveButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackViewForAllViews)
        
        stackViewForAllViews.addArrangedSubview(textView)
        stackViewForAllViews.addArrangedSubview(containerForStackView)
        
        containerForStackView.addSubview(stackViewForImportanceAndDeadline)
        
        stackViewForImportanceAndDeadline.addArrangedSubview(importanceView)
        stackViewForImportanceAndDeadline.addArrangedSubview(firstDividedLine)
        stackViewForImportanceAndDeadline.addArrangedSubview(deadLineView)
        stackViewForImportanceAndDeadline.addArrangedSubview(secondDividedLine)
        stackViewForImportanceAndDeadline.addArrangedSubview(datePicker)
        
        stackViewForAllViews.addArrangedSubview(deleteButton)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.insetsForTop.left),
            topStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.insetsForTop.right),
            topStackView.heightAnchor.constraint(equalToConstant: Constants.heightForTop),
            
            scrollView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            stackViewForAllViews.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackViewForAllViews.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackViewForAllViews.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackViewForAllViews.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackViewForAllViews.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.heightTextView),
            importanceView.heightAnchor.constraint(equalToConstant: Constants.heightImportanceStack),
            deadLineView.heightAnchor.constraint(equalToConstant: Constants.heightDeadlineStack),
            
            stackViewForImportanceAndDeadline.topAnchor.constraint(equalTo: containerForStackView.topAnchor),
            stackViewForImportanceAndDeadline.leadingAnchor.constraint(equalTo: containerForStackView.leadingAnchor),
            stackViewForImportanceAndDeadline.trailingAnchor.constraint(equalTo: containerForStackView.trailingAnchor),
            stackViewForImportanceAndDeadline.bottomAnchor.constraint(equalTo: containerForStackView.bottomAnchor),
            
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButtonHeight)
        ])
    }
    
    @objc private func datePickerTapped(sender: UIDatePicker) {
        datePickerTapped(for: sender.date)
    }
    
    private func datePickerTapped(for date: Date) {
        todoItemViewModel.deadline = date
        setDateForButton(date)
        UIView.animate(withDuration: Double(0.3), animations: {
            self.datePicker.isHidden = true
        })
        secondDividedLine.isHidden = true
    }
    
    private func setDateForButton(_ date: Date) {
        deadLineView.setDate(date)
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        delegate?.updateFromView(todoItemView: todoItemViewModel)
//        guard
//            let text = todoItemViewModel.text
//        else {
//            return
//        }
//        let importance = todoItemViewModel.importance
//
//        let todoItem: TodoItem
//        if let id = self.id {
//            todoItem = TodoItem(id: id, text: text, importance: importance, deadline: todoItemViewModel.deadline, isDone: false)
//            do {
//                try fileCache.update(todoItem: todoItem)
//            } catch {
//                DDLogError("File updating error")
//            }
//        } else {
//            todoItem = TodoItem(text: text, importance: importance, deadline: todoItemViewModel.deadline, isDone: false)
//            do {
//                try fileCache.add(todoItem: todoItem)
//            } catch {
//                DDLogError("Item adding error")
//            }
//        }
//        do {
//            try fileCache.save(file: file)
//        } catch {
//            DDLogError("File saving error")
//        }
//
//        delegate?.itemDidChanged()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteButtonTapped() {
        guard let id = todoItemViewModel.id else {
            return
        }
        delegate?.removeFromView(id: id)
//        fileCache.delete(todoItemID: id)
//        do {
//            try fileCache.save(file: file)
//        } catch {
//            DDLogError("File saving error")
//        }
//
//        delegate?.itemDidChanged()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateView() {
        textView.text = todoItemViewModel.text
        textView.delegateForText?.textViewDidChange(with: todoItemViewModel.text ?? "")
        textView.textViewDidEndEditing(textView)
        deadLineView.setSwitch(isOn: todoItemViewModel.deadline == nil ? false : true)
        importanceView.changeImportance(importance: todoItemViewModel.importance)
        datePicker.isHidden = true
        secondDividedLine.isHidden = true
    }
}


// MARK: - ImportanceViewDelegate
extension DetailViewController: ImportanceViewDelegate {
    func selectedImportance(importance: TodoItem.Importance) {
        todoItemViewModel.importance = importance
        deleteAndSaveIsEnabledToggle()
    }
}

// MARK: - TextViewDelegate
extension DetailViewController: TextViewDelegate {
    func textViewDidChange(with text: String) {
        todoItemViewModel.text = text
        deleteAndSaveIsEnabledToggle()
    }
}

extension DetailViewController {
    func deleteAndSaveIsEnabledToggle() {
        guard
            !(todoItemViewModel.text == nil || todoItemViewModel.text?.isEmpty == true)
        else {
            saveButton.isEnabled = false
            deleteButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        deleteButton.isEnabled = true
        guard todoItemViewModel.id != nil else {
            deleteButton.isEnabled = false
            return
        }
    }
}

// MARK: - DeadLineViewDelegate
extension DetailViewController: DeadLineViewDelegate {
    func switcherTapped(isOn: Bool) {
        if isOn {
            if todoItemViewModel.deadline == nil {
                todoItemViewModel.deadline = Date.now + 60 * 60 * 24
            }
            UIView.animate(withDuration: Double(0.3), animations: {
                self.datePicker.isHidden = false
            })
            secondDividedLine.isHidden = false
            datePicker.setDate(todoItemViewModel.deadline!, animated: false)
            deadLineView.switcherIsON(for: todoItemViewModel.deadline!)
        } else {
            todoItemViewModel.deadline = nil
            UIView.animate(withDuration: Double(0.3), animations: {
                self.datePicker.isHidden = true
            })
            secondDividedLine.isHidden = true
            deadLineView.switcherIsOff()
        }
    }

     func dateButtonTapped() {

        if datePicker.isHidden {
            UIView.animate(withDuration: Double(0.3), animations: {
                self.datePicker.isHidden = false
            })
            secondDividedLine.isHidden = false
        } else {
            UIView.animate(withDuration: Double(0.3), animations: {
                self.datePicker.isHidden = true
            })
            secondDividedLine.isHidden = true
        }
        if let date = todoItemViewModel.deadline {
            datePicker.setDate(date, animated: false)
        }
    }
}

// MARK: - Keyboard and observers
extension DetailViewController {
    private func setUpObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func dismissKeyboard() {
        textView.endEditing(true)
    }
    
    private func addTapGestureRecognizerToDismissKeyboard() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardSize.cgRectValue.height
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.scrollIndicatorInsets = .zero
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

