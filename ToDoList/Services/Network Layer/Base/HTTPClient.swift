//
//  HTTPClient.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation


protocol HTTPClient {
    func createRequest(endpoint: Endpoint) throws -> URLRequest
    
}
extension HTTPClient {
    func createRequest(endpoint: Endpoint) throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path
        guard let url = urlComponents.url else {
            throw RequestError.invalidURL
        }
        // Печатаем ссылку запроса
        print("Делаем запрос по адресу", url)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header
        return request
    }
}
