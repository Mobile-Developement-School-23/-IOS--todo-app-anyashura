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

    private var fileCache = FileCache<TodoItem>()
    private let file = "first.json"
    private var countOfDoneTasks = 0
    private var todoCellViewModels = [TodoCellViewModel]()
    private var completedTasksAreHidden: Bool = false
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
        do {
            try fileCache.load(file: file)
        } catch {
            DDLogError("File loading error")
        }
        updateViewModels()
        configureNavBar()
        view.backgroundColor = .background
        addSubviews()
        addConstraints()
        loadTodoList()
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

    private func removeTodoItem(id: String) {
        fileCache.delete(todoItemID: id)
        do {
            try fileCache.save(file: file)
        } catch {
            DDLogError("File saving error")
        }
    }

    private func ifTaskIsDone(id: String) {
        if let todoItem = fileCache.delete(todoItemID: id) {
            do {
                try fileCache.add(todoItem: TodoItem(
                    id: todoItem.id,
                    text: todoItem.text,
                    importance: todoItem.importance,
                    deadline: todoItem.deadline,
                    isDone: todoItem.isDone == false ? true : false,
                    dateCreated: todoItem.dateCreated,
                    dateEdited: todoItem.dateEdited))
            } catch {
                DDLogError("File deleting error")
            }
            do {
                try fileCache.save(file: file)
            } catch {
                DDLogError("File saving error")
            }
        }
    }

    private func taskCellTappedFor(id: String) {
        guard let todoItem = fileCache.todoItems.first(where: { $0.id == id }) else { return }
        let controller = DetailViewController(id: id)
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = self
        controller.configure(todoItem: todoItem)
        self.present(controller, animated: true, completion: nil)
    }

    func updateViewModels() {
        todoCellViewModels = fileCache.todoItems.map { TodoCellViewModel.init(from: $0) }.filter { completedTasksAreHidden || !$0.isDone }
        countOfDoneTasks = fileCache.todoItems.filter { $0.isDone }.count
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
            guard let todoItem = self.fileCache.todoItems.first(where: { $0.id == tappedTaskModelId }) else { return nil }
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
            self?.ifTaskIsDone(id: changedTaskModelId)
            self?.updateViewModels()
        }
        swipeCheckDone.image = UIImage(named: Constants.nameForCircleImage)
        swipeCheckDone.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [swipeCheckDone])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if !(tableView.cellForRow(at: indexPath) is TodoListTableViewCell) { return nil}

        let swipeDelete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
            guard let deletedTaskModelId = self?.todoCellViewModels[indexPath.row].id else { return }
            self?.removeTodoItem(id: deletedTaskModelId)
            self?.updateViewModels()
        }
        swipeDelete.image = UIImage(systemName: "trash.fill")

        return UISwipeActionsConfiguration(actions: [swipeDelete])
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            let todoCellViewModel = todoCellViewModels[indexPath.row]
            cell?.configureCellWith(model: todoCellViewModel, setTopMaskedCorners: indexPath.row == 0 ? true : false)
            cell?.delegate = self
            return cell ?? UITableViewCell()
        }
    }
}

extension TodoListViewController: TodoListTableViewCellDelegate {
    func statusChangedFor(id: String) {
        ifTaskIsDone(id: id)
        updateViewModels()
    }
}

extension TodoListViewController: DetailViewControllerDelegate {
    func itemDidChanged() {
        do {
            try fileCache.load(file: file)
        } catch {
            DDLogError("File loading error")
        }
        updateViewModels()
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
