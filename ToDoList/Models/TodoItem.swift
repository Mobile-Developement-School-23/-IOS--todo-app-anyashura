//
//  TodoItem.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 11.06.2023.
//

import Foundation
import FileCache
import SQLite
import CoreData


struct TodoItem {
    
    // MARK: - Enum
    enum Importance: String {
        case low
        case basic
        case important
    }
    // MARK: - Properties
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let dateCreated: Date
    let dateEdited: Date?
    
    // MARK: - Init
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool,
        dateCreated: Date = Date.now,
        dateEdited: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.dateCreated = dateCreated
        self.dateEdited = dateEdited
    }
}

// MARK: - Extensions
extension TodoItem: TodoItemProtocol {
    var json: Any {
        var dictionary: [String: Any] = [:]
        
        dictionary[Constants.id] = self.id
        dictionary[Constants.text] = self.text
        dictionary[Constants.isDone] = self.isDone
        dictionary[Constants.dateCreated] = self.dateCreated.timeStamp
        if importance != .basic {
            dictionary[Constants.importance] = self.importance.rawValue
        }
        if let deadline = deadline {
            dictionary[Constants.deadline] = deadline.timeStamp
        }
        if let dateEdited = dateEdited {
            dictionary[Constants.dateEdited] = dateEdited.timeStamp
        }
        return dictionary
    }
    
    var sqlInsertStatement: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        var deadlineStr = ""
        if let deadlineToStr = self.deadline {
            deadlineStr = "'" + formatter.string(from: deadlineToStr) + "'"
        } else {
            deadlineStr = "NULL"
        }
        
        var dateEditedStr = ""
        if let dateEditedToStr = self.dateEdited {
            dateEditedStr = "'" + formatter.string(from: dateEditedToStr) + "'"
        } else {
            dateEditedStr = "NULL"
        }
        
        let isDoneStr = self.isDone ? "1" : "0"
        
        let sqlStatement = "REPLACE INTO \"TodoItems\" (" +
        "\"\(Constants.id)\", " +
        "\"\(Constants.text)\", " +
        "\"\(Constants.importance)\", " +
        "\"\(Constants.deadline)\", " +
        "\"\(Constants.isDone)\", " +
        "\"\(Constants.dateCreated)\", " +
        "\"\(Constants.dateEdited)\")" +
        " VALUES (" +
        "'\(self.id)', " +
        "'\(self.text)', " +
        "'\(self.importance.rawValue)', " +
        "\(deadlineStr), " +
        "\(isDoneStr), " +
        "'\(formatter.string(from: self.dateCreated))', " +
        "\(dateEditedStr))"
        print(sqlStatement)
        return sqlStatement
    }
    
    static func parseSQL(row: Row) -> TodoItem? {
        return self.init(
            id: row[Constants.idSQL],
            text: row[Constants.textSQL],
            importance: Importance(rawValue: row[Constants.importanceSQL]) ?? .basic,
            deadline: row[Constants.deadlineSQL],
            isDone: row[Constants.isDoneSQL],
            dateCreated: row[Constants.dateCreatedSQL],
            dateEdited: row[Constants.dateEditedSQL]
        )
    }
    static func parseCoreData(entity: TodoItemEntity) -> TodoItem? {
        guard let id = entity.id,
              let text = entity.text,
              let importance = TodoItem.Importance(rawValue: entity.importance ?? "basic")
        else { return nil }
//        let deadline = entity.deadline
//        let dateEdited = entity.dateEdited
//        let dateCreated = entity.dateCreated
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: entity.deadline,
            isDone: entity.isDone,
            dateCreated: entity.dateCreated ?? Date(),
            dateEdited: entity.dateEdited
        )
    }
    
    var coreDataEntity: TodoItemEntity? {
        let context = CoreDataContainer.shared.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "TodoItemEntity", in: context)
        else { return nil }
        
        let toDoItem = TodoItemEntity(entity: entity, insertInto: nil)
        toDoItem.id = id
        toDoItem.text = text
        toDoItem.importance = importance.rawValue
        toDoItem.dateCreated = dateCreated
        toDoItem.deadline = deadline
        toDoItem.dateEdited = dateEdited
        toDoItem.isDone = isDone
        
        return toDoItem
    }
    
    
    var csvString: String {
        var importanceForCSV = ""
        if importance != .basic {
            importanceForCSV = self.importance.rawValue
        }
        var deadlineForCSV = ""
        if let deadline = deadline {
            deadlineForCSV = String(deadline.timeStamp)
        }
        var dateEditedForCSV = ""
        if let dateEdited = dateEdited {
            dateEditedForCSV = String(dateEdited.timeStamp)
        }
        let text = TodoItem.replaceSymbols(in: self.text, what: ",", with: "~")
        
        return "\(self.id),\(text),\(importanceForCSV),\(deadlineForCSV), \(String(self.isDone)),\(String(self.dateCreated.timeStamp)),\(dateEditedForCSV)"
    }
    
    static func parseCSV(csvString: String) -> TodoItem? {
        let values = csvString.components(separatedBy: ",")
        let id = values[0]
        let text = replaceSymbols(in: values[1], what: "~", with: ",")
        var isDone = false
        if values[4] == " true" {
            isDone = true
        }
        var deadline: Date?
        if values[3] != "" {
            deadline = Int(values[3])?.dateFormat
        }
        let dateCreated = Int(values[5])?.dateFormat ?? Date.now
        var dateEdited: Date?
        if values[6] != "" {
            dateEdited = Int(values[3])?.dateFormat
        }
        let importance = Importance(rawValue: values[2]) ?? Importance.basic
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
    }
    
    static func parse(json: Any) -> TodoItem? {
        guard let dictionary = json as? [String: Any] else {
            return nil
        }
        guard let id = dictionary[Constants.id] as? String,
              let text = dictionary[Constants.text] as? String,
              let isDone = dictionary[Constants.isDone] as? Bool,
              let dateCreated = (dictionary[Constants.dateCreated] as? Int)?.dateFormat else {
            return nil
        }
        var importance = Importance.basic
        if let importanceString = dictionary[Constants.importance] as? String,
           let importanceFromDict = Importance(rawValue: importanceString) {
            importance = importanceFromDict
        }
        let deadline = (dictionary[Constants.deadline] as? Int)?.dateFormat
        let dateEdited = (dictionary[Constants.dateEdited] as? Int)?.dateFormat
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
    }
    
    func done() -> TodoItem {
        TodoItem(id: self.id,
                 text: self.text,
                 importance: self.importance,
                 deadline: self.deadline,
                 isDone: self.isDone == false ? true : false,
                 dateCreated: self.dateCreated,
                 dateEdited: Date.now)
    }
    
    // function for corner case, when in field "text" there is a symbol the same as separator
    static func replaceSymbols(in string: String, what replace: Character, with replacement: Character) -> String {
        return String(string.map { $0 == replace ? replacement : $0 })
    }
}

// MARK: - Constants
extension TodoItem {
    
    enum Constants {
        static let id = "id"
        static let text = "text"
        static let importance = "importance"
        static let deadline = "deadline"
        static let isDone = "isDone"
        static let dateCreated = "dateCreated"
        static let dateEdited = "dateEdited"
        static let idSQL = Expression<String>("id")
        static let textSQL = Expression<String>("text")
        static let importanceSQL = Expression<String>("importance")
        static let deadlineSQL = Expression<Date?>("deadline")
        static let isDoneSQL = Expression<Bool>("isDone")
        static let dateCreatedSQL = Expression<Date>("dateCreated")
        static let dateEditedSQL = Expression<Date?>("dateEdited")
    }
}
