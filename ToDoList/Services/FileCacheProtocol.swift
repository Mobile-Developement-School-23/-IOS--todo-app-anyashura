//
//  FileCacheProtocol.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 21.06.2023.
//

import Foundation

// MARK: - Protocol
protocol FileCacheProtocol {
    func add(todoItem: TodoItem) throws
    func delete(todoItemID: String) throws -> TodoItem?
    func update(todoItem: TodoItem) throws
    func save(file: String) throws
    func saveToSCV(file: String) throws
    func loadFromCSV(file: String) throws
    func load(file: String) throws
}
