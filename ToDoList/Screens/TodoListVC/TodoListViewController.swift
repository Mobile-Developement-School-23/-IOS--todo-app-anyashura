//
//  TodoListViewController.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 26.06.2023.
//

import UIKit
import CocoaLumberjackSwift
import FileCache

final class TodoListViewController: UIViewController {
    
    enum Constants {
        static let insetsForTable = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        static let cellIDTodo = "TodoListTableViewCell"
        static let cellIDNewTodo = "NewTableViewCell"
        static let headerID = "HeaderForTodoListTableView"
        static let navBarLeadingInset: CGFloat = 16.0
        static let tableLeadingInset: CGFloat = 16.0
        static let tableTrailingInset: CGFloat = -16.0
        static let addItemBottomInset: CGFloat = -54.0
        static let nameForCircleImage = "doneGray"
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchedtodoCellViewModels = [TodoCellViewModel]()
    private var filterIsActive: Bool {
        searchController.isActive
    }
    
    private let model = FileCaheModel()
    private var countOfDoneTasks = 0
    private var todoCellViewModels = [TodoCellViewModel]()
    private var completedTasksAreHidden: Bool = false
    private var lastUpdatedByDevice = UIDevice.current.identifierForVendor?.uuidString
    private var selectedCellFrame: CGRect?
    
    private let topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .background
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var todoListTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .subviewsBackground
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.register(HeaderForTodoListTableView.self, forHeaderFooterViewReuseIdentifier: Constants.headerID)
        table.register(TodoListTableViewCell.self, forCellReuseIdentifier: Constants.cellIDTodo)
        table.register(NewTableViewCell.self, forCellReuseIdentifier: Constants.cellIDNewTodo)
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var addNewItem: AddNewItem = {
        let addItem = AddNewItem()
        addItem.addTarget(self, action: #selector(addNewItemTapped), for: .touchUpInside)
        addItem.translatesAutoresizingMaskIntoConstraints = false
        return addItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(UIDevice.current.identifierForVendor?.uuidString, forKey: "lastUpdatedBy")
        model.delegate = self
        model.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateViewModels()
            case .failure(let error):
                DDLogError(error)
            }
        }
        
        configureNavBar()
        configureSearchBar()
        view.backgroundColor = .background
        addSubviews()
        addConstraints()
    }
    
    private func configureSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.showsSearchResultsController = true
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    private func configureNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        title = ConstantsText.myTasks
        navigationController?.additionalSafeAreaInsets.left = Constants.navBarLeadingInset
    }
    
    private func addSubviews() {
        view.addSubview(todoListTableView)
        view.addSubview(addNewItem)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            todoListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            todoListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.tableLeadingInset),
            todoListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.tableTrailingInset),
            todoListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            addNewItem.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.addItemBottomInset),
            addNewItem.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addNewItem.heightAnchor.constraint(equalToConstant: 44),
            addNewItem.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    
    @objc private func addNewItemTapped() {
        let controller = DetailViewController(id: nil)
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    private func taskCellTappedFor(id: String) {
        guard let todoItem = model.getTodoItems().first(where: { $0.id == id }) else { return }
        let controller = DetailViewController(id: id)
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = self
        controller.configure(todoItem: todoItem)
        self.present(controller, animated: true, completion: nil)
    }
    
    func updateViewModels() {
        let todoItems = model.getTodoItems()
        todoCellViewModels = todoItems
            .map { TodoCellViewModel.init(from: $0) }
            .filter { completedTasksAreHidden || !$0.isDone }
        countOfDoneTasks = todoItems.filter { $0.isDone }.count
        todoListTableView.reloadData()
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        guard indexPath.row != lastIndex else {
            let controller = DetailViewController(id: nil)
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        selectedCellFrame = tableView.convert(cell.frame, to: tableView.superview)
        
        let tappedTaskModelId = todoCellViewModels[indexPath.row].id
        taskCellTappedFor(id: tappedTaskModelId)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        guard indexPath.row != lastIndex else { return nil }
        
        let configuration = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
            let tappedTaskModelId = self.todoCellViewModels[indexPath.row].id
            let controller = DetailViewController(id: tappedTaskModelId)
            guard let todoItem = self.model.getTodoItems().first(where: { $0.id == tappedTaskModelId }) else { return nil }
            controller.configure(todoItem: todoItem)
            return controller
        }, actionProvider: nil)
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        guard let controller = animator.previewViewController else { return }
        animator.addCompletion {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !(tableView.cellForRow(at: indexPath) is TodoListTableViewCell) { return nil}
        
        let swipeCheckDone = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            guard let changedTaskModelId = self?.todoCellViewModels[indexPath.row].id else { return }
            guard let self = self else { return }
            guard let updatedTodoItem = self.model.getTodoItem(id: changedTaskModelId) else { return }
            let doneTodoItem = updatedTodoItem.done()
            self.model.changeTodoItem(todoItem: doneTodoItem) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.updateViewModels()
                case .failure(let error):
                    DDLogError(error)
                }
            }
        }
        swipeCheckDone.image = UIImage(named: Constants.nameForCircleImage)
        swipeCheckDone.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [swipeCheckDone])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !(tableView.cellForRow(at: indexPath) is TodoListTableViewCell) { return nil}
        
        let swipeDelete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
            guard let deletedTaskModelId = self?.todoCellViewModels[indexPath.row].id else { return }
            guard let self = self else { return }
            self.model.removeTodoItem(id: deletedTaskModelId) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.updateViewModels()
                case .failure(let error):
                    DDLogError(error)
                }
            }
        }
        swipeDelete.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [swipeDelete])
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterIsActive {
            return searchedtodoCellViewModels.count + 1
        }
        return todoCellViewModels.count + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderForTodoListTableView()
        header.layer.masksToBounds = true
        header.configureShowHideButton(completedTasksAreHidden: completedTasksAreHidden)
        header.configureIsDoneLabel(count: countOfDoneTasks)
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastIndex {
            let cell: NewTableViewCell? = tableView.dequeueReusableCell(
                withIdentifier: Constants.cellIDNewTodo,
                for: indexPath
            ) as? NewTableViewCell
            cell?.configureCellWith(firstCell: indexPath.row == 0)
            return cell ?? UITableViewCell()
        } else {
            let cell: TodoListTableViewCell? = tableView.dequeueReusableCell(
                withIdentifier: Constants.cellIDTodo,
                for: indexPath
            ) as? TodoListTableViewCell
            if filterIsActive {
                let filteredTodoCellViewModel = searchedtodoCellViewModels[indexPath.row]
                cell?.configureCellWith(model: filteredTodoCellViewModel, setTopMaskedCorners: indexPath.row == 0 ? true : false)
                cell?.delegate = self
                return cell ?? UITableViewCell()
            }
            let todoCellViewModel = todoCellViewModels[indexPath.row]
            cell?.configureCellWith(model: todoCellViewModel, setTopMaskedCorners: indexPath.row == 0 ? true : false)
            cell?.delegate = self
            return cell ?? UITableViewCell()
        }
    }
}

extension TodoListViewController: TodoListTableViewCellDelegate {
    func statusChangedFor(id: String) {
        guard let updatedTodoItem = model.getTodoItem(id: id) else { return }
        let doneTodoItem = updatedTodoItem.done()
        model.changeTodoItem(todoItem: doneTodoItem) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateViewModels()
            case .failure(let error):
                DDLogError(error)
            }
        }
    }
}

extension TodoListViewController: HeaderForTodoListTableViewDelegate {
    func showDoneTodoButton(completedTasksAreHidden: Bool) {
        self.completedTasksAreHidden.toggle()
        updateViewModels()
    }
}

extension TodoListViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let frame = selectedCellFrame else { return nil }
        return AnimationPresenter(cellFrame: frame)
    }
}

extension TodoListViewController: TodoServiceDelegate {
    func update() {
        updateViewModels()
    }
}
extension TodoListViewController: DetailViewControllerDelegate {
    
    func removeFromView(id: String) {
        self.model.removeTodoItem(id: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateViewModels()
            case .failure(let error):
                DDLogError(error)
            }
        }
    }
    
    func updateFromView(todoItemView: TodoItemViewModel) {
        if let updatedId = todoItemView.id {
            guard let updatedTodoItem = model.getTodoItem(id: updatedId) else { return }
            model.changeTodoItem(
                todoItem: TodoItem(
                    id: updatedId,
                    text: todoItemView.text ?? "",
                    importance: todoItemView.importance,
                    deadline: todoItemView.deadline,
                    isDone: false,
                    dateCreated: updatedTodoItem.dateCreated,
                    dateEdited: Date.now
                )) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        self.updateViewModels()

                    case .failure(let error):
                        DDLogError(error)
                    }
                }
        } else {
            model.addTodoItem(todoItem: TodoItem(
                text: todoItemView.text ?? "",
                importance: todoItemView.importance,
                deadline: todoItemView.deadline,
                isDone: false)
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.updateViewModels()
                case .failure(let error):
                    DDLogError(error)
                }
            }
        }
    }
}

extension TodoListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterSearchText(text)
    }
    
    func filterSearchText(_ searchText: String) {
        searchedtodoCellViewModels = todoCellViewModels.filter { $0.text.string.contains(searchText.lowercased())}
        todoListTableView.reloadData()
    }
}
