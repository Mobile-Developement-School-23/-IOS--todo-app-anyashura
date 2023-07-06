//
//  DefaultNetworkingService.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation

final class DefaultNetworkingService: HTTPClient {
    private func checkStatusCode(response: HTTPURLResponse) throws {
           switch response.statusCode {
           case (100...299):
               return
           case (300...399):
               throw RequestError.unknown
           case (400...499):
               throw RequestError.unknown
           case (500...599):
               throw RequestError.unknown
           default:
               throw RequestError.unexpectedStatusCode(response.statusCode)
           }
       }
    
    func getTodoList() async throws -> [TodoItem]? {
        guard let request = try createRequest(endpoint: NetworkingService.getTodoItem) else { return nil }
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(ListResponseModel.self, from: data)
        return response.list.compactMap(mapData(element:))
    }
    
    private func performRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.unknown
        }
        try checkStatusCode(response: response)
        return (data, response)
    }
        
    
    
    private func mapData(element: Item) -> TodoItem? {
            guard
                let importance = TodoItem.Importance(rawValue: element.importance),
                let dateCreated = element.dateCreated.dateFormat
            else {
                return nil
            }
        
        let id = element.id
        
        let deadline = element.deadline?.dateFormat
        let dateEdited = element.dateEdited.dateFormat
print(TodoItem(
    id: id,
    text: element.text,
    importance: importance,
    deadline: deadline,
    isDone: element.isDone,
    dateCreated: dateCreated,
    dateEdited: dateEdited
))
            return TodoItem(
                id: id,
                text: element.text,
                importance: importance,
                deadline: deadline,
                isDone: element.isDone,
                dateCreated: dateCreated,
                dateEdited: dateEdited
            )
        }
    
    
    private let queue = DispatchQueue(label: "Queue", attributes: [.concurrent])
    private var revision: Int = 0
    
    func checkErrors(_ statusCode: Int) -> RequestError {
        switch statusCode {
        case 400:
            return .requestError
        case 401:
            return .unauthorized
        case 404:
            return .requestError
        default:
            return .unexpectedStatusCode(statusCode)
        }
    }
    
    
}
