//
//  TodoItemsEndpoint.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation

enum TodoItemsEndpoint {
    case getTodoItemsList(completion: (Result<[TodoItem], Error>) -> Void)
    case updateTodoItem(_ todoItem: TodoItem, completion: (Result<TodoItem, Error>) -> Void)
    case getTodoItem
    case deleteTodoItem(_ id: String, completion: (Result<TodoItem, Error>) -> Void)
    case createTodoItem(_ todoItem: TodoItem, completion: (Result<TodoItem, Error>) -> Void)
}

extension TodoItemsEndpoint: Endpoint {
    
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return "beta.mrdekk.ru"
    }
    
    var path: String {
        switch self {
        case .createTodoItem:
            return "/list/"
        case .updateTodoItem:
            return "/list"
        case .getTodoItem:
            return "/list/"
        case .deleteTodoItem:
            return "/list/"
        case .getTodoItemsList:
            return "/list"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .createTodoItem:
            return .get
        case .updateTodoItem:
            return .get
        case .getTodoItem:
            return .get
        case .deleteTodoItem:
            return .get
        case .getTodoItemsList:
            return .get
        }
    }
    func getHeader(revision: Int32) -> [String : String]? {}
//    var header: [String : String]? {

//        }
//    }
    
//    var body: [String : Any]? {
//        switch self {
//
//        }
//    }
}
