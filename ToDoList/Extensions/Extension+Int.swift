//
//  Extension+Int.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 21.06.2023.
//

import Foundation

// convert Int to Date
extension Int {
    var dateFormat: Date? {
        return Date(timeIntervalSince1970: Double(self))
    }
}
