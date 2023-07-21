//
//  Todo.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 20.07.2023.
//

import Foundation


struct TodoItem: Identifiable {

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

