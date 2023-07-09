//
//  DefaultNetworkingService.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation

final class DefaultNetworkingService: NetworkingService {
    
    enum NetworkError: Error {
        case invalidURL
        case requestError
        case errorWithAuth
        case unknownError
        case serviceError(_ statusCode: Int)
        case notFound
    }
    
    private let queue = DispatchQueue.global()
    private let bearerToken = "procyoniform"
    private let path = "https://beta.mrdekk.ru/todobackend/list"
    
    private var currentRevision: Int
    
    init() {
        self.currentRevision = UserDefaults.standard.integer(forKey: "revision")

    }
    
    func getItemsList(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let urlRequest = createRequest(revision: currentRevision, requestMethod: RequestMethod.get)
                
        else {
            completion(.failure(RequestError.invalidURL))
            return
        }
        let task = createTaskForList(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }

    func addTodoItem(_ todoItem: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard var urlRequest = createRequest(revision: currentRevision, requestMethod: RequestMethod.post) else { completion(.failure(NetworkError.invalidURL))
            return
        }
        let networkRequest = ServerRequestElement(element: TodoItemNetwork(todoItem))
        urlRequest.httpBody = try? JSONEncoder().encode(networkRequest)
        let task = createTaskForElement(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }

    
    func changeTodoItem(_ todoItem: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard var urlRequest =  createRequest(additionalPath: todoItem.id, revision: currentRevision,  requestMethod: RequestMethod.put) else {
            completion(.failure(NetworkError.invalidURL)); return }
        let networkRequest = ServerRequestElement(element: TodoItemNetwork(todoItem))
        urlRequest.httpBody = try? JSONEncoder().encode(networkRequest)
        let task = createTaskForElement(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }

    
    func deleteTodoItem(_ id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard let urlRequest = createRequest(additionalPath: id, revision: currentRevision, requestMethod: RequestMethod.delete) else {
            completion(.failure(NetworkError.invalidURL)); return }
        let task = createTaskForElement(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }
    
    func getItem(id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard let urlRequest = createRequest(additionalPath: id, revision: currentRevision, requestMethod: RequestMethod.get) else {
            completion(.failure(NetworkError.invalidURL)); return }
        let task = createTaskForElement(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }

    func putAllTodoItems(_ todoItems: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard var urlRequest = createRequest(revision: currentRevision, requestMethod: RequestMethod.patch) else {
            completion(.failure(NetworkError.invalidURL)); return }
        let todoItemsNetwork = todoItems.map({TodoItemNetwork($0)})
        let networkRequest = ServerRequestList(list: todoItemsNetwork)
        urlRequest.httpBody = try? JSONEncoder().encode(networkRequest)
        let task = createTaskForList(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }
    
    // универсальный метод создания реквестов
    private func createRequest(additionalPath: String? = nil, revision: Int? = nil, requestMethod: RequestMethod) -> URLRequest? {
        var urlComponents = URLComponents()
        if let additionalPath = additionalPath {
            urlComponents.path = "\(path)/\(additionalPath)"
        } else {
            urlComponents.path = "\(path)"
        }
        guard let url = URL(string: urlComponents.path) else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = requestMethod.rawValue
        
        if let revision = revision {
            urlRequest.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        }
        return urlRequest
    }
    
    // универсальный метод для создания таски для списка элементов
    private func createTaskForList(completion: @escaping (Result<[TodoItem], Error>) -> Void,
                        urlRequest: URLRequest) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if response != nil, let data = data,
                      let networkResponse = try? JSONDecoder().decode(ServerResponseList.self, from: data) {
                let todoItems = networkResponse.list.map({TodoItem($0)})
                self.currentRevision = networkResponse.revision
                self.saveRevision(revision: self.currentRevision)
                completion(.success(todoItems))
            } else if let response = response as? HTTPURLResponse {
                completion(.failure(self.checkErrors(statusCode: response.statusCode)))
            } else {
                completion(.failure(NetworkError.unknownError))
            }
        }
        return task
    }
    
    // универсальный метод для создания таски для конкретного элемента
    private func createTaskForElement(completion: @escaping (Result<TodoItem, Error>) -> Void,
                           urlRequest: URLRequest) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                      let networkResponse = try? JSONDecoder().decode(ServerResponseElement.self, from: data) {
                self.currentRevision = networkResponse.revision
                self.saveRevision(revision: self.currentRevision)
                completion(.success(TodoItem(networkResponse.element)))
            } else if let response = response as? HTTPURLResponse {
                completion(.failure(self.checkErrors(statusCode: response.statusCode)))
            } else {
                completion(.failure(NetworkError.unknownError))
            }
        }
        return task
    }
    
    private func saveRevision(revision: Int) {
        currentRevision = revision
        UserDefaults.standard.set(currentRevision, forKey: "revision")
    }
    
    private func checkErrors(statusCode: Int) -> RequestError {
        switch statusCode {
        case 400:
            return RequestError.requestError
        case 401:
            return RequestError.unauthorized
        case 404:
            return RequestError.notFound
        case (500...599):
            return RequestError.errorFromServer
        default:
            return RequestError.unexpectedStatusCode(statusCode)
        }
    }
}

