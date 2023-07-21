//
//  MockData.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 20.07.2023.
//

import Foundation

final class MockData {
    let mock = [
        TodoItem(text: "1", importance: .important, deadline: nil, isDone: false, dateCreated: Date(), dateEdited: nil),
        TodoItem(text: "2", importance: .low, deadline: nil, isDone: false, dateCreated: Date(), dateEdited: nil),
        TodoItem(text: "3", importance: .important, deadline: nil, isDone: true, dateCreated: Date(), dateEdited: nil),
        TodoItem(text: "4", importance: .basic, deadline: Date(timeIntervalSince1970: 168993422), isDone: false, dateCreated: Date(), dateEdited: nil),
    ]
}
