//
//  FileCacheSQLiteService.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 12.07.2023.
//

import Foundation

protocol FileCacheDBService {
    func save(items: [TodoItem], completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void)
    func load(completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void)
    func insert(item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void)
    func replace(item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void)
    func delete(_ id: String, completion: @escaping (Swift.Result<Void, Error>) -> Void)
}
