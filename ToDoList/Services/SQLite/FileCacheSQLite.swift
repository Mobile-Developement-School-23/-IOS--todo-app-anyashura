//
//  FileCacheSQLite.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 12.07.2023.
//

import Foundation
import SQLite

final class FileCacheSQLite: FileCacheDBService {
    enum Constants {
        static let idKey = "id"
        static let textKey = "text"
        static let importanceKey = "importance"
        static let deadlineKey = "deadline"
        static let isDoneKey = "isDone"
        static let dateCreatedKey = "dateCreated"
        static let dateEditedKey = "dateEdited"
        static let tableName = "TodoItems"

    }
    private (set) var todoItems: [TodoItem] = []
    private var database: Connection?

    private let todoItemsTable = Table(Constants.tableName)

    private let id = Expression<String>(Constants.idKey)
    private let text = Expression<String>(Constants.textKey)
    private let importance = Expression<String>(Constants.importanceKey)
    private let deadline = Expression<Date?>(Constants.deadlineKey)
    private let isDone = Expression<Bool>(Constants.isDoneKey)
    private let dateCreated = Expression<Date>(Constants.dateCreatedKey)
    private let dateEdited = Expression<Date?>(Constants.dateEditedKey)

    private let file = "file2.sqlite3"

    private var pathForDB: String? {
        let pathForDB = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        return pathForDB
    }

    // MARK: - Init

    init() {
        guard let pathForDB = pathForDB else { return }
        let database = try? Connection("\(pathForDB)/\(file)")
        self.database = database
        do {
            try createTable()
        } catch let error {
            print("\(error)")
        }
    }

    // MARK: - Methods

    func load(completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                try self.loadAllItemsFromDataBase()
                completion(.success(self.todoItems))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func save(items: [TodoItem], completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            do {
                try self?.saveIntoDatabase(items: items) { items in
                    completion(.success(items))
                }
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func insert(item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                try self.insertIntoDatabase(item: item)
                completion(.success(item))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func replace(item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                try self.replaceIntoDatabase(item: item)
                completion(.success(item))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func delete(_ id: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                try self.deleteFromDatabase(id)
                completion(.success(()))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    private func createTable() throws {
        guard let pathForDB = pathForDB else { return }
        if !FileManager.default.fileExists(atPath: "\(pathForDB)/\(file)") {
            FileManager.default.createFile(atPath: "\(pathForDB)/\(file)", contents: nil, attributes: nil)
        }
        let connection = try Connection("\(pathForDB)/\(file)")
        try connection.run(todoItemsTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(text)
            table.column(importance)
            table.column(deadline)
            table.column(isDone)
            table.column(dateCreated)
            table.column(dateEdited)
        })
    }

    private func loadAllItemsFromDataBase() throws {
        guard let base = database else { return }
        todoItems.removeAll()
        for row in try base.prepare(todoItemsTable) {
            if let todoItem = TodoItem.parseSQL(row: row) {
                todoItems.append(todoItem)
            }
        }
    }

    private func saveIntoDatabase(items: [TodoItem], completion: ([TodoItem]) -> Void) throws {
        guard let base = database else { return }
        try loadAllItemsFromDataBase()
        let itemsIds = items.map({$0.id})
        let dbItemsIds = todoItems.map({$0.id})
        let itemsToDelete = todoItemsTable.filter(!itemsIds.contains(id))
        let itemsToInsert = items.filter({!dbItemsIds.contains($0.id)})
        let itemsToReplace = items.filter({dbItemsIds.contains($0.id)})

        try base.run(itemsToDelete.delete())

        for item in itemsToInsert {
            try insertIntoDatabase(item: item)
        }
        for item in itemsToReplace {
            try replaceIntoDatabase(item: item)
        }
        todoItems = items
        completion(items)
    }

    // можно использовать любой из этих методов

    //    private func insertIntoDatabase(item: TodoItem) throws {
    //        guard let base = database else { return }
    //        try base.run(item.sqlInsertStatement)
    //        todoItems.append(item)
    //    }

    private func insertIntoDatabase(item: TodoItem) throws {
        guard let base = database else { return }
        let insert = todoItemsTable.insert(id <- item.id,
                                           text <- item.text,
                                           importance <- item.importance.rawValue,
                                           deadline <- item.deadline,
                                           isDone <- item.isDone,
                                           dateCreated <- item.dateCreated,
                                           dateEdited <- item.dateEdited)
        try base.run(insert)
        todoItems.append(item)
    }

    private func replaceIntoDatabase(item: TodoItem) throws {
        guard let base = database else { return }
        let insert = todoItemsTable.insert(or: .replace,
                                           id <- item.id,
                                           text <- item.text,
                                           importance <- item.importance.rawValue,
                                           deadline <- item.deadline,
                                           isDone <- item.isDone,
                                           dateCreated <- item.dateCreated,
                                           dateEdited <- item.dateEdited)
        try base.run(insert)
        todoItems.removeAll(where: { $0.id == item.id })
        todoItems.append(item)
    }

    private func deleteFromDatabase(_ id: String) throws {
        guard let base = database else { return }
        let todoItem = todoItemsTable.filter(self.id == id)
        try base.run(todoItem.delete())
        todoItems.removeAll(where: { $0.id == id })
    }
}
