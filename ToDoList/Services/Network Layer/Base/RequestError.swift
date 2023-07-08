//
//  RequestError.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode(_ statusCode: Int)
    case unknown
    case notFound
    case requestError
    case errorFromServer
    case connectionError
}
