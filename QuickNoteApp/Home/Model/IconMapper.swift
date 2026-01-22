//
//  IconMapper.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 16/01/26.
//



import Foundation

struct IconMapper {
    static func getSymbolName(for title: String) -> String {
        let lowerTitle = title.lowercased().trimmingCharacters(in: .whitespaces)
        
        
        let mapping: [String: String] = [
            "gym": "figure.cross.training",
            "fitness": "heart",
            "cooking": "fork.knife",
            "food": "cart",
            "music": "music.note",
            "ideas": "lightbulb",
            "shopping": "bag",
            "home": "house",
            "car": "car",
            "money": "dollarsign.circle",
            "book": "book",
            "coding": "command"
        ]
        
    
        return mapping[lowerTitle] ?? "folder.fill"
    }
}
