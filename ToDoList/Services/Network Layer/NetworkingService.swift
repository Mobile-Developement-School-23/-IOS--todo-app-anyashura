//
//  NetworkingService.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation


protocol NetworkingService {
    func getItemsList(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func addTodoItem(_ todoItem: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func changeTodoItem(_ todoItem: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func deleteTodoItem(_ id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func getItem(id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func putAllTodoItems(_ todoItems: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void)
}
