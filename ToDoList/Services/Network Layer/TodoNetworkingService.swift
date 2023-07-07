//
//  TodoNetworkingService.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 07.07.2023.
//

import Foundation
import FileCache

// MARK: - Protocol

protocol TodoServiceDelegate: AnyObject {
    func update()
}

// MARK: - Properties

private var fileCache = FileCache<TodoItem>()
private var networkingService = DefaultNetworkingService()

private var isDirty = false

weak var delegate: TodoServiceDelegate?

