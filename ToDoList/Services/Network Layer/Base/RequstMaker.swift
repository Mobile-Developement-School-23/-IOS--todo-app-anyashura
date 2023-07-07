//
//  RequstMaker.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 07.07.2023.
//

import Foundation

enum RequestMaker {
    case getAllTodoItemsList
    case updateTodoItemsList(revision: String)
    case getTodoItem(id: String)
    case addTodoItem(revision: String)
    case updateTodoItem(id: String, revision: String)
    case deleteTodoItem(id: String, revision: String)
}

extension RequestMaker: Endpoint {
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return "beta.mrdekk.ru"
    }
    
    var path: String {
        switch self {
        case .getTodoItem(id: let id):
            return "todobackend/list/\(id)"
        case .updateTodoItem:
            return "todobackend/list/"
        case .deleteTodoItem(id: let id):
            return "todobackend/list/"
        default:
            return "todobackend/list"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .getAllTodoItemsList:
            return .get
        case .updateTodoItemsList:
            return .patch
        case .getTodoItem:
            return .get
        case .addTodoItem:
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
        case .getAllTodoItemsList:
            return [
                "Authorization": "Bearer \(authToken)",
                "X-Generate-Fails": "50"
            ]
        case .updateTodoItemsList(revision: let revision):
            return [
                "Authorization": "Bearer \(authToken)",
                "X-Last-Known-Revision": "\(revision)",
                "X-Generate-Fails": "50"
            ]
        case .getTodoItem(id: _):
            return [
                "Authorization": "Bearer \(authToken)",
                "X-Generate-Fails": "50"
            ]
        case .addTodoItem(revision: let revision):
            return [
                "Authorization": "Bearer \(authToken)",
                "X-Last-Known-Revision": "\(revision)",
                "X-Generate-Fails": "50"
            ]
        case .updateTodoItem(revision: let revision):
            return [
                "Authorization": "Bearer \(authToken)",
                "X-Last-Known-Revision": "\(revision)",
                "X-Generate-Fails": "50"
            ]
        case .deleteTodoItem(revision: let revision):
            return [
                "Authorization": "Bearer \(authToken)",
                "X-Last-Known-Revision": "\(revision)",
                "X-Generate-Fails": "50"
            ]
        }
    }
}
