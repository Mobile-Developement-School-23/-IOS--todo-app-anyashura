//
//  TodoItem.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 11.06.2023.
//

import Foundation
import FileCache

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
    }
}

extension TodoItem {
    init(_ todoItemNetwork: TodoItemNetwork) {
        id = todoItemNetwork.id
        text = todoItemNetwork.text
        importance = Importance(rawValue: todoItemNetwork.importance) ?? .basic
        if let updatedDeadline = todoItemNetwork.deadline {
            deadline = updatedDeadline.dateFormat
        } else {
            deadline = nil
        }
        isDone = todoItemNetwork.isDone
        dateCreated = todoItemNetwork.dateCreated.dateFormat ?? .now
        if let updatedDateEdited = todoItemNetwork.dateEdited {
            dateEdited = updatedDateEdited.dateFormat
        } else {
            dateEdited = nil
        }
    }

    func done() -> TodoItem {
        TodoItem(id: self.id,
                 text: self.text,
                 importance: self.importance,
                 deadline: self.deadline,
                 isDone: self.isDone == false ? true : false,
                 dateCreated: self.dateCreated,
                 dateEdited: self.dateEdited)
    }

}
