//
//  CustomCategoryManager.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 16/01/26.
//

import Foundation

class CustomCategoryManager {
    static let shared = CustomCategoryManager()
    private let key = "SavedCustomCategories"

    func saveCategory(_ name: String) {
        var current = fetchCategories()
        if !current.contains(name) {
            current.append(name)
            UserDefaults.standard.set(current, forKey: key)
        }
    }

    func fetchCategories() -> [String] {
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}
