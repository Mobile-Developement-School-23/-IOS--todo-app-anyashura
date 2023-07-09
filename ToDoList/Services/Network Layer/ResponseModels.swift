//
//  ResponseModels.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 06.07.2023.
//

import Foundation

struct ServerResponseList: Codable {
    let status: String
    let list: [TodoItemNetwork]
    let revision: Int
}

struct ServerResponseElement: Codable {
    let status: String
    let element: TodoItemNetwork
    let revision: Int
}

struct ServerRequestElement: Codable {
    var element: TodoItemNetwork
    init(element: TodoItemNetwork) {
        self.element = element
    }
}

struct ServerRequestList: Codable {
    var list: [TodoItemNetwork]
    init(list: [TodoItemNetwork]) {
        self.list = list
    }
}

struct TodoItemNetwork: Codable {
    let id: String
    let text: String
    let importance: String
    let isDone: Bool
    let deadline: Int?
    let dateCreated: Int
    let dateEdited: Int?
    let lastUpdatedBy: String

    init(_ todoItem: TodoItem) {
        id = todoItem.id
        text = todoItem.text
        importance = todoItem.importance.rawValue
        isDone = todoItem.isDone
        deadline = todoItem.deadline == nil ? nil : todoItem.deadline?.timeStamp
        dateCreated = todoItem.dateCreated.timeStamp
        dateEdited = todoItem.dateEdited == nil ? nil : todoItem.dateEdited?.timeStamp
        lastUpdatedBy = "kk"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.importance = try container.decode(String.self, forKey: .importance)
        self.isDone = try container.decode(Bool.self, forKey: .isDone)
        do {
            self.deadline = try container.decode(Int?.self, forKey: .deadline)
        } catch {
            self.deadline = nil
        }
        self.dateCreated = try container.decode(Int.self, forKey: .dateCreated)
        self.dateEdited = try container.decode(Int?.self, forKey: .dateEdited)
        self.lastUpdatedBy = try container.decode(String.self, forKey: .lastUpdatedBy)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case isDone = "done"
        case deadline
        case dateCreated = "created_at"
        case dateEdited = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(importance, forKey: .importance)
        try container.encode(isDone, forKey: .isDone)
        if deadline != nil {
            try container.encode(deadline, forKey: .deadline)
        }
        try container.encode(dateCreated, forKey: .dateCreated)
        if dateEdited != nil {
            try container.encode(dateEdited, forKey: .dateEdited)
        } else {
            try container.encode(dateCreated, forKey: .dateEdited)
        }
        try container.encode(lastUpdatedBy, forKey: .lastUpdatedBy)
    }
}
