//
//  FileCacheErrors.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 21.06.2023.
//

import Foundation

// MARK: - Enum with errors descriptions
enum FileCacheErrors: LocalizedError {
    case sameID(id: String)
    case invalidJSON
    case invalidFileAccess
    case invalidJsonSerialization
    case savingError
    case invalidCSV
    case loadingError
    case noID

    var errorDescription: String? {
        switch self {
        case .sameID(let id):
            return "id \"\(id)\" уже существует"
        case .invalidJSON:
            return "Невалидный JSON"
        case .invalidFileAccess:
            return "Проблема с доступом к документам"
        case .invalidJsonSerialization:
            return "Проблема с серилизацией JSON"
        case .savingError:
            return "Не удается сохранить файл"
        case .invalidCSV:
            return "Невалидный файл CSV"
        case .loadingError:
            return "Проблема с загрузкой файла"
        case .noID:
            return "Задачи с таким ID не существует"
        }
    }
}
