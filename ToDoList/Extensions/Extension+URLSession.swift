//
//  Extension+URLSession.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation

extension URLSession {
    func customDataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation({ continuation in
            let task = dataTask(with: urlRequest) { (data, response, error) in
                if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                }
                if let error = error {
                    continuation.resume(throwing: error)
                }
            }
            if Task.isCancelled == true {
                task.cancel()
            } else {
                task.resume()
            }
        })
    }
}
