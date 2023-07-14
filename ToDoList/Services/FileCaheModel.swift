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

class FileCaheModel {

    // нужно раскомментировать строчку и закомментировать ниже, чтобы поменять хранилище
    private let fileCacheDB = FileCacheSQLite()
    //    private let fileCacheDB = FileCacheCoreData()

    weak var delegate: TodoServiceDelegate?

    // MARK: - Methods

    func getTodoItems() -> [TodoItem] {
        let items = fileCacheDB.todoItems.sorted { $0.dateEdited ?? $0.dateCreated > $1.dateEdited ?? $1.dateCreated }
        return items
    }

    func getTodoItem(id: String) -> TodoItem? {
        return fileCacheDB.todoItems.first(where: { $0.id == id }) }

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        fileCacheDB.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
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
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
