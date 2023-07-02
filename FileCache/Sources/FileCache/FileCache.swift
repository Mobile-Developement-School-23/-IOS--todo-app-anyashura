import Foundation
import CocoaLumberjackSwift

public protocol TodoItemProtocol {
    associatedtype TodoItemType: TodoItemProtocol
    var id: String { get }
    var json: Any { get }
    var csvString: String { get }

    static func parseCSV(csvString: String) -> TodoItemType?
    static func parse(json: Any) -> TodoItemType?
}

public class FileCache<Item: TodoItemProtocol> {
    // MARK: - Properties
    public private(set) var todoItems = [Item]()

    private let rightCSVHeader = ["id", "text", "importance", "deadline", "isDone", "dateCreated", "dateEdited"]

    // MARK: - Init

    public init() { }

    // MARK: - Methods

    // add new item, if id is different
    public func add(todoItem: Item) throws {
        if !todoItems.contains(where: { $0.id == todoItem.id }) {
            todoItems.append(todoItem)
        } else {
            DDLogError(FileCacheErrors.sameID(id: todoItem.id).errorDescription ?? "")
            throw FileCacheErrors.sameID(id: todoItem.id)
        }
    }

    // delete item with id
    @discardableResult
    public func delete(todoItemID: String) -> Item? {
        if let deletedTodo = todoItems.first(where: { $0.id == todoItemID }) {
            todoItems.removeAll(where: { $0.id == todoItemID })
            return deletedTodo
        } else {
            return nil
        }
    }

    // update existing item
    public func update(todoItem: Item) throws {
        guard let index = todoItems.firstIndex(where: { $0.id == todoItem.id }) else { throw FileCacheErrors.noID }
        todoItems[index] = todoItem
    }

    // save data to JSON
    public func save(file: String) throws {
        let jsonTodoItems = todoItems.map { $0.json }
        guard JSONSerialization.isValidJSONObject(jsonTodoItems),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonTodoItems) else {
            throw FileCacheErrors.invalidJsonSerialization
        }
        guard let fileURL = getURL(file: file) else { throw FileCacheErrors.invalidFileAccess }
        do {
            try jsonData.write(to: fileURL)
        } catch {
            DDLogError(FileCacheErrors.savingError.errorDescription ?? "")
            throw FileCacheErrors.savingError
        }
    }
    // save data to CSV file
    // add header in order to know name of fields
    public func saveToSCV(file: String) throws {
        let csvTodoItems = todoItems.map { $0.csvString }.joined(separator: "\n")
        let rightCSVHeaderStr = rightCSVHeader.map {$0}.joined(separator: ",") + "\n"
        let csvTodoItemsWithHeader = "\(rightCSVHeaderStr) \(csvTodoItems)"
        guard let fileURL = getURL(file: file) else { throw FileCacheErrors.invalidFileAccess }
        do {
            try csvTodoItemsWithHeader.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            DDLogError(FileCacheErrors.savingError.errorDescription ?? "")
            throw FileCacheErrors.savingError
        }
    }
    // load data from CSV file
    public func loadFromCSV(file: String) throws {
        guard let fileURL = getURL(file: file) else { throw FileCacheErrors.invalidFileAccess }
        let csvString = try String(contentsOf: fileURL)
        let rows = csvString.components(separatedBy: "\n")
        let headers = rows[0].components(separatedBy: ",")
        guard rightCSVHeader.count == headers.count else {
            DDLogError(FileCacheErrors.invalidCSV.errorDescription ?? "")
            throw FileCacheErrors.invalidCSV
        }
        for index in 0..<rightCSVHeader.count {
            if rightCSVHeader[index] == headers[index] {
                continue
            } else {
                DDLogError(FileCacheErrors.invalidCSV.errorDescription ?? "")
                throw FileCacheErrors.invalidCSV
            }
        }
        for row in rows.dropFirst() {
            guard let todoItem = Item.parseCSV(csvString: row) as? Item else {
                DDLogError(FileCacheErrors.loadingError.errorDescription ?? "")
                throw FileCacheErrors.loadingError
            }
            todoItems.append(todoItem)
        }
    }
    // load data from JSON
    public func load(file: String) throws {
        guard let fileURL = getURL(file: file) else { throw FileCacheErrors.invalidFileAccess }
        let jsonData = try Data(contentsOf: fileURL)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)

        guard let jsonDict = jsonObject as? [Any] else {
            DDLogError(FileCacheErrors.invalidJSON.errorDescription ?? "")
            throw FileCacheErrors.invalidJSON
        }
        todoItems = jsonDict.compactMap { Item.parse(json: $0) as? Item }
    }

    public func deleteFile(file: String) throws {
        guard let fileURL = getURL(file: file) else {
            DDLogError(FileCacheErrors.invalidFileAccess.errorDescription ?? "")
            throw FileCacheErrors.invalidFileAccess
        }
        try FileManager.default.removeItem(atPath: fileURL.path)
    }

    // get path to file
    private func getURL(file: String) -> URL? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(file, isDirectory: false)
        return url
    }
}
