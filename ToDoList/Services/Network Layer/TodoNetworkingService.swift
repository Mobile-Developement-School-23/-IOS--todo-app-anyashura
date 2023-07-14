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
    private let fileCacheDB = FileCacheSQLite()

    weak var delegate: TodoServiceDelegate?

    // MARK: - Methods

    func getTodoItems() -> [TodoItem] {
        return fileCacheDB.todoItems.reversed()
    }

    func getTodoItem(id: String) -> TodoItem? {
        return fileCacheDB.todoItems.first(where: { $0.id == id }) }
    
    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        fileCacheDB.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let todoItems):
                DispatchQueue.main.async { self.delegate?.update() }
//                self.networkService.putAllTodoItems(todoItems) { result in
//                    switch result {
//                    case .success(let todoItems):
//                        self.fileCacheDB.save(items: todoItems) { result in
//                            switch result {
//                            case .success:
//                                DispatchQueue.main.async {
//                                    completion(.success(()))
//                                }
//                            case .failure(let error):
//                                DispatchQueue.main.async {
//                                    completion(.failure(error))
//                                }
//                            }
//                        }
//                    case .failure:
//                        self.isDirty = true
//                        DispatchQueue.main.async {
//                            completion(.success(()))
//                        }
//                    }
//                }
            case .failure:
                break
            }
        }
    }

    func addTodoItem(todoItem: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        fileCacheDB.insert(item: todoItem) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
//                if self.isDirty {
//                    self.networkService.putAllTodoItems(self.fileCacheDB.todoItems) { result in
//                        switch result {
//                        case .success(let todoItems):
//                            self.fileCacheDB.save(items: todoItems) { result in
//                                switch result {
//                                case .success:
//                                    DispatchQueue.main.async {
//                                        completion(.success(()))
//                                    }
//                                case .failure(let error):
//                                    DispatchQueue.main.async {
//                                        completion(.failure(error))
//                                    }
//                                }
//                            }
//                        case .failure:
//                            self.isDirty = true
//                            DispatchQueue.main.async {
//                                completion(.success(()))
//                            }
//                        }
//                    }
//                } else {
//                    self.networkService.addTodoItem(todoItem) { [weak self] result in
//                        switch result {
//                        case .success:
//                            DispatchQueue.main.async {
//                                completion(.success(()))
//                            }
//                        case .failure:
//                            self?.isDirty = true
//                            DispatchQueue.main.async {
//                                completion(.success(()))
//                            }
//                        }
//                    }
//                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func changeTodoItem(todoItem: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        fileCacheDB.replace(item: todoItem) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
//                if self.isDirty {
//                    self.networkService.putAllTodoItems(self.fileCacheDB.todoItems) { result in
//                        switch result {
//                        case .success(let todoItems):
//                            self.fileCacheDB.save(items: todoItems) { result in
//                                switch result {
//                                case .success:
//                                    DispatchQueue.main.async {
//                                        completion(.success(()))
//                                    }
//                                case .failure(let error):
//                                    DispatchQueue.main.async {
//                                        completion(.failure(error))
//                                    }
//                                }
//                            }
//                        case .failure:
//                            self.isDirty = true
//                            DispatchQueue.main.async {
//                                completion(.success(()))
//                            }
//                        }
//                    }
//                } else {
//                    self.networkService.changeTodoItem(todoItem) { [weak self] result in
//                        switch result {
//                        case .success:
//                            DispatchQueue.main.async {
//                                completion(.success(()))
//                            }
//                        case .failure:
//                            self?.isDirty = true
//                            DispatchQueue.main.async {
//                                completion(.success(()))
//                            }
//                        }
//                    }
//                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    func removeTodoItem( id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fileCacheDB.delete(id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
//                if self.isDirty {
//                    self.networkService.putAllTodoItems(self.fileCacheDB.todoItems) { result in
//                        switch result {
//                        case .success(let todoItems):
//                            self.fileCacheDB.save(items: todoItems) { result in
//                                switch result {
//                                case .success:
//                                    DispatchQueue.main.async {
//                                        completion(.success(()))
//                                    }
//                                case .failure(let error):
//                                    DispatchQueue.main.async {
//                                        completion(.failure(error))
//                                    }
//                                }
//                            }
//                        case .failure:
//                            self.isDirty = true
//                            DispatchQueue.main.async {
//                                completion(.success(()))
//                            }
//                        }
//                    }
//                } else {
//                    self.networkService.deleteTodoItem(id) { [weak self] result in
//                        switch result {
//                        case .success:
//                            DispatchQueue.main.async {
//                                completion(.success(()))
//                            }
//                        case .failure(let error):
//                            self?.isDirty = true
//                            DispatchQueue.main.async {
//                                completion(.failure(error))
//                            }
//                        }
//                    }
//                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
