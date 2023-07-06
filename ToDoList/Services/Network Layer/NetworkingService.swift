//
//  NetworkingService.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 04.07.2023.
//

import Foundation


protocol NetworkingService {
    func getAllTodoItemsList() async throws -> [TodoItem]
    func updateTodoItemsList(_ todoList: [TodoItem]) async throws -> [TodoItem]
    func getTodoItem(id: String) async throws -> TodoItem?
    @discardableResult func createTodoItem(_ todoItem: TodoItem) async throws -> TodoItem?
    @discardableResult func updateTodoItem(_ todoItem: TodoItem) async throws -> TodoItem?
    @discardableResult func deleteTodoItem(id: String) async throws -> TodoItem?
}

