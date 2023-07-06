//
//  NetworkingService.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation

enum NetworkingService {
    case getAllTodoItemsList(revision: Int)
    case updateTodoItemsList(_ todoItem: TodoItem, completion: (Result<TodoItem, Error>) -> Void)
    case getTodoItem
    case createTodoItem(_ todoItem: TodoItem, completion: (Result<TodoItem, Error>) -> Void)
    case updateTodoItem(_ todoItems: [TodoItem], completion: (Result<[TodoItem], Error>) -> Void)
    case deleteTodoItem(_ id: String, completion: (Result<TodoItem, Error>) -> Void)
}


extension NetworkingService: Endpoint {
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return "beta.mrdekk.ru"
    }
    
    var path: String {
        return "todobackend/list"
    }
    
    var method: RequestMethod {
        switch self {
        case .getAllTodoItemsList:
            return .get
        case .updateTodoItemsList:
            return .patch
        case .getTodoItem:
            return .get
        case .createTodoItem:
            return .post
        case .updateTodoItem:
            return .put
        case .deleteTodoItem:
            return .delete
        }
    }
    
    var header: [String : String]? {
        let authToken = "Shurjaeva_A"
        switch self {
        case .getAllTodoItemsList(revision: let revision):
            return [
                "Authorization": authToken,
                "Content-Type": "application/json",
                "X-Last-Known-Revision": "\(revision)"
            ]
        default:
            return [
                "Authorization": authToken,
                "Content-Type": "application/json",
            ]
        }
    }
}
