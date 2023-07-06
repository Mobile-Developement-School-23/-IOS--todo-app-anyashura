//
//  DefaultNetworkingService.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation

final class DefaultNetworkingService: HTTPClient {
    
    private var revision: Int = 0
    private let deviceID: String = ""
    
    func getTodoList() async throws -> [TodoItem]? {
        let request = try createRequest(endpoint: RequestMaker.getAllTodoItemsList)
        let (data, _) = try await setRequest(request)
        let response = try JSONDecoder().decode(ListResponseModel.self, from: data)
        return response.list.compactMap(makeTodoFromResponse(itemFromResponse:))
    }
    
    func updateTodoList(todoList: [TodoItem]) async throws -> [TodoItem] {
        let listRsponseModel = ListResponseModel(list: todoList.map { makeResponseFromTodo(item: $0)})
        let requestBody = try JSONEncoder().encode(listRsponseModel)
        var request = try createRequest(endpoint: RequestMaker.updateTodoItemsList(revision: "\(revision)"))
        request.httpBody = requestBody
        
        let (data, _) = try await setRequest(request)
        let response = try JSONDecoder().decode(ListResponseModel.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return response.list.compactMap(makeTodoFromResponse(itemFromResponse: ))
    }
    
    func getTodoItem(id: String) async throws -> TodoItem? {
        let request = try createRequest(endpoint: RequestMaker.getTodoItem(id: id))
        let (data, _) = try await setRequest(request)
        let response = try JSONDecoder().decode(ItemResponseModel.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return makeTodoFromResponse(itemFromResponse: response.element)
    }
    
    @discardableResult
    func addTodoItem(todoItem: TodoItem) async throws -> TodoItem? {
        let todoItemResponse = ItemResponseModel(element: makeResponseFromTodo(item: todoItem))
        var request = try createRequest(endpoint: RequestMaker.createTodoItem(revision: "\(revision)"))
        let requestBody = try JSONEncoder().encode(todoItemResponse)
        request.httpBody = requestBody
        let (data, _) = try await setRequest(request)
        let response = try JSONDecoder().decode(ItemResponseModel.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return makeTodoFromResponse(itemFromResponse: response.element)
    }
    
    @discardableResult
    func updateTodoItem(todoItem: TodoItem) async throws -> TodoItem? {
        let todoItemResponse = ItemResponseModel(element: makeResponseFromTodo(item: todoItem))
        let requestBody = try JSONEncoder().encode(todoItemResponse)
        var request = try createRequest(endpoint: RequestMaker.updateTodoItem(id: todoItem.id, revision: "\(revision)"))
        request.httpBody = requestBody
        let (data, _) = try await setRequest(request)
        let response = try JSONDecoder().decode(ItemResponseModel.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return makeTodoFromResponse(itemFromResponse: response.element)
    }
    
    @discardableResult
    func deleteTodoItem(id: String) async throws -> TodoItem? {
        let request = try createRequest(endpoint: RequestMaker.deleteTodoItem(id: id, revision: "\(revision)"))
        let (data, _) = try await setRequest(request)
        let response = try JSONDecoder().decode(ItemResponseModel.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return makeTodoFromResponse(itemFromResponse: response.element)
    }
    
    private func setRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.noResponse
        }
        try checkErrors(statusCode: response.statusCode)
        return (data, response)
    }
    
    func checkErrors(statusCode: Int) throws {
        switch statusCode {
        case 100 ... 299:
            return
        case 400:
            throw RequestError.requestError
        case 401:
            throw RequestError.unauthorized
        case 404:
            throw RequestError.notFound
        case (500...599):
            throw RequestError.errorFromServer
        default:
            throw RequestError.unexpectedStatusCode(statusCode)
        }
    }
    
    private func makeTodoFromResponse(itemFromResponse: Item) -> TodoItem? {
        guard let importance = TodoItem.Importance(rawValue: itemFromResponse.importance),
              let dateCreated = itemFromResponse.dateCreated.dateFormat else { return nil }
        let id = String(itemFromResponse.id)
        let deadline = itemFromResponse.deadline?.dateFormat
        let dateEdited = itemFromResponse.dateEdited.dateFormat
        return TodoItem(
            id: id,
            text: itemFromResponse.text,
            importance: importance,
            deadline: deadline,
            isDone: itemFromResponse.isDone,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
    }
    
    private func makeResponseFromTodo(item: TodoItem) -> Item {
        let itemOfResponseModel = Item(
            id: item.id,
            text: item.text,
            importance: item.importance.rawValue,
            deadline: item.deadline?.timeStamp,
            isDone: item.isDone,
            dateCreated: item.dateCreated.timeStamp,
            dateEdited: item.dateEdited?.timeStamp ?? item.dateCreated.timeStamp,
            lastUpdatedBy: deviceID
        )
        return itemOfResponseModel
    }
}

