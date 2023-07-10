//
//  TodoNetworkingService.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 07.07.2023.
//

import Foundation
import FileCache
import CocoaLumberjackSwift

// MARK: - Protocol

protocol TodoServiceDelegate: AnyObject {
    func update()
}

// MARK: - Class

class NetworkModel {

    private var isDirty = false

    private let file = "first.json"


    private let networkService = DefaultNetworkingService()
    private let fileCache = FileCache<TodoItem>()

    weak var delegate: TodoServiceDelegate?

    // MARK: - Methods

    func getTodoItems() -> [TodoItem] {
        return fileCache.todoItems.reversed()
    }

    func getTodoItem(id: String) -> TodoItem? {
        return fileCache.todoItems.first(where: { $0.id == id }) }

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        fileCache.loadFile(file: file) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let todoItems):
                DispatchQueue.main.async { self.delegate?.update() }
                self.networkService.putAllTodoItems(todoItems) { result in
                    switch result {
                    case .success(let todoItems):
                        self.fileCache.removeAll()
                        for todoItem in todoItems {
                            try? self.fileCache.add(todoItem: todoItem)
                        }
                        self.fileCache.save(file: self.file) { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    completion(.success(()))
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            }
                        }
                    case .failure:
                        self.isDirty = true
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    }
                }
            case .failure:
                self.networkService.getItemsList { result in
                    switch result {
                    case .success(let todoItems):
                        for todoItem in todoItems {
                            try? self.fileCache.add(todoItem: todoItem)
                        }
                        self.fileCache.save(file: self.file) { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    completion(.success(()))
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }

    func addTodoItem(todoItem: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        try? fileCache.add(todoItem: todoItem)
        fileCache.save(file: file) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
                if self.isDirty {
                    self.networkService.putAllTodoItems(self.fileCache.todoItems) { result in
                        switch result {
                        case .success(let todoItems):
                            self.fileCache.removeAll()
                            for todoItem in todoItems {
                                try? self.fileCache.add(todoItem: todoItem)
                            }
                            self.fileCache.save(file: self.file) { result in
                                switch result {
                                case .success:
                                    DispatchQueue.main.async {
                                        completion(.success(()))
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        completion(.failure(error))
                                    }
                                }
                            }
                        case .failure:
                            self.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                } else {
                    self.networkService.addTodoItem(todoItem) { [weak self] result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        case .failure:
                            self?.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func changeTodoItem(todoItem: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard fileCache.delete(todoItemID: todoItem.id) != nil else { return }
        try? fileCache.add(todoItem: todoItem)
        fileCache.save(file: file) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
                if self.isDirty {
                    self.networkService.putAllTodoItems(self.fileCache.todoItems) { result in
                        switch result {
                        case .success(let todoItems):
                            self.fileCache.removeAll()
                            for todoItem in todoItems {
                                try? self.fileCache.add(todoItem: todoItem)
                            }
                            self.fileCache.save(file: self.file) { result in
                                switch result {
                                case .success:
                                    DispatchQueue.main.async {
                                        completion(.success(()))
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        completion(.failure(error))
                                    }
                                }
                            }
                        case .failure:
                            self.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                } else {
                    self.networkService.changeTodoItem(todoItem) { [weak self] result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        case .failure:
                            self?.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func removeTodoItem( id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard fileCache.delete(todoItemID: id) != nil else { return }
        fileCache.save(file: file) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
                if self.isDirty {
                    self.networkService.putAllTodoItems(self.fileCache.todoItems) { result in
                        switch result {
                        case .success(let todoItems):
                            self.fileCache.removeAll()
                            for todoItem in todoItems {
                                try? self.fileCache.add(todoItem: todoItem)
                            }
                            self.fileCache.save(file: self.file) { result in
                                switch result {
                                case .success:
                                    DispatchQueue.main.async {
                                        completion(.success(()))
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        completion(.failure(error))
                                    }
                                }
                            }
                        case .failure:
                            self.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                } else {
                    self.networkService.deleteTodoItem(id) { [weak self] result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        case .failure(let error):
                            self?.isDirty = true
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
