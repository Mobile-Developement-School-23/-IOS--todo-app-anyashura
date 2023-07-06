//
//  ResponseModels.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 06.07.2023.
//

import Foundation

struct ListResponseModel: Codable {
    let status: String
    let list: [Item]
    let revision: Int?
    
    init(status: String = "ok", list: [Item], revision: Int? = nil) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}

struct ItemResponseModel: Codable {
    let status: String
    let element: Item
    let revision: Int?
    
    init(status: String = "ok", element: Item, revision: Int? = nil) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}

struct Item: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int?
    let isDone: Bool
    let dateCreated: Int
    let dateEdited: Int
    let lastUpdatedBy: String
    
    private enum CodingKeys: String, CodingKey {
        case id, text, importance, deadline
        case isDone = "done"
        case dateCreated = "created_at"
        case dateEdited = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}
