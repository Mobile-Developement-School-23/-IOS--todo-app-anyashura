//
//  FileCache.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 11.06.2023.
//

import Foundation

//MARK: - Protocol
protocol FileCacheProtocol {
    func add(todoItem: TodoItem) throws
    func delete(todoItemID: String) throws
    func update(todoItem: TodoItem) throws
    func save(file: String) throws
    func saveToSCV(file: String) throws
    func loadFromCSV(file: String) throws
    func load(file: String) throws
}

final class FileCache: FileCacheProtocol {
    // MARK: - Properties
    private (set) var todoItems = [TodoItem]()
    
    private let rightCSVHeader = ["id", "text", "importance", "deadline", "isDone", "dateCreated", "dateEdited"]
    
    // MARK: - Methods
    
    //add new item, if id is different
    func add(todoItem: TodoItem) throws {
        if !todoItems.contains(where: { $0.id == todoItem.id }) {
            todoItems.append(todoItem)
        } else {
            throw FileCacheErrors.sameID(id: todoItem.id)
        }
    }
    
    //delete item with id
    func delete(todoItemID: String) {
        todoItems.removeAll(where: { $0.id == todoItemID })
    }
    
    //update existing item
    func update(todoItem: TodoItem) throws {
        guard let index = todoItems.firstIndex(where: { $0.id == todoItem.id }) else { throw FileCacheErrors.noID }
        todoItems[index] = todoItem
    }
    
    //save data to JSON
    func save(file: String) throws {
        let jsonTodoItems = todoItems.map { $0.json }
        guard JSONSerialization.isValidJSONObject(jsonTodoItems),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonTodoItems) else {
            throw FileCacheErrors.invalidJsonSerialization
        }
        guard let fileURL = getURL(file: file) else { throw FileCacheErrors.invalidFileAccess }
        do {
            try jsonData.write(to: fileURL)
        } catch {
            throw FileCacheErrors.savingError
        }
    }
    //save data to CSV file
    //add header in order to know name of fields
    func saveToSCV(file: String) throws {
        let csvTodoItems = todoItems.map { $0.csvString }.joined(separator: "\n")
        let rightCSVHeaderStr = rightCSVHeader.map {$0}.joined(separator: ",") + "\n"
        let csvTodoItemsWithHeader = "\(rightCSVHeaderStr) \(csvTodoItems)"
        guard let fileURL = getURL(file: file) else { throw FileCacheErrors.invalidFileAccess }
        do {
            try csvTodoItemsWithHeader.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw FileCacheErrors.savingError
        }
    }
    //load data from CSV file
    func loadFromCSV(file: String) throws {
        guard let fileURL = getURL(file: file) else { throw FileCacheErrors.invalidFileAccess }
        let csvString = try String(contentsOf: fileURL)
        let rows = csvString.components(separatedBy: "\n")
        let headers = rows[0].components(separatedBy: ",")
        guard rightCSVHeader.count == headers.count else {
            throw FileCacheErrors.invalidCSV
        }
        for index in 0..<rightCSVHeader.count {
            if rightCSVHeader[index] == headers[index] {
                continue
            } else {
                throw FileCacheErrors.invalidCSV
            }
        }
        for row in rows.dropFirst(){
            let todoItem = TodoItem.parseCSV(csvString: row)
            guard todoItem != nil  else {
                throw FileCacheErrors.loadingError
            }
            todoItems.append(todoItem!)
        }
    }
    //load data from JSON
    func load(file: String) throws {
        guard let fileURL = getURL(file: file) else { throw FileCacheErrors.invalidFileAccess }
        let jsonData = try Data(contentsOf: fileURL)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
        
        guard let jsonDict = jsonObject as? [Any] else {
            throw FileCacheErrors.invalidJSON
        }
        todoItems = jsonDict.compactMap { TodoItem.parse(json: $0) }
    }
    
    //get path to file
    private func getURL(file: String) -> URL? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(file, isDirectory: false)
        return url
    }
}
// MARK: - Enum with errors descriptions
enum FileCacheErrors: LocalizedError {
    case sameID(id: String)
    case invalidJSON
    case invalidFileAccess
    case invalidJsonSerialization
    case savingError
    case invalidCSV
    case loadingError
    case noID
    
    var errorDescription: String? {
        switch self {
        case .sameID(let id):
            return "id \"\(id)\" уже существует"
        case .invalidJSON:
            return "Невалидный JSON"
        case .invalidFileAccess:
            return "Проблема с доступом к документам"
        case .invalidJsonSerialization:
            return "Проблема с серилизацией JSON"
        case .savingError:
            return "Не удается сохранить файл"
        case .invalidCSV:
            return "Невалидный файл CSV"
        case .loadingError:
            return "Проблема с загрузкой файла"
        case .noID:
            return "Задачи с таким ID не существует"
        }
    }
}
