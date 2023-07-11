//
//  TodoItemViewModel.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 21.06.2023.
//

import Foundation

struct TodoItemViewModel {
    var id: String?
    var text: String?
    var importance: TodoItem.Importance  = .basic
    var deadline: Date?
}
