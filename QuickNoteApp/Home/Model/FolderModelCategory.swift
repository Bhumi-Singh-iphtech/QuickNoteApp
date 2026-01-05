//
//  FolderModelCategory.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 05/01/26.
//

enum FolderCategory: String, CaseIterable {
    case personal = "Personal"
    case work = "Work"
    case school = "School"
    case travel = "Travel"
    case ideas = "Music"
    case finance = "Finance"
    case health = "Health"

    var iconAssetName: String {
        switch self {
        case .personal: return "user"
        case .work: return "work_icon"
        case .school: return "graduation-cap"
        case .travel: return "luggage (2)"
        case .ideas: return "icon_music"
        case .finance: return "icon_finance"
        case .health: return "icon_health"
        }
    }
}
