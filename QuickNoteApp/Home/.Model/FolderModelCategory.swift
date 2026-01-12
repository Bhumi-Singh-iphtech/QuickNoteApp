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
        case .personal: return "person"
        case .work: return "work_icon"
        case .school: return "graduation"
        case .travel: return "travel."
        case .ideas: return "icon_music"
        case .finance: return "icon_finance"
        case .health: return "icon_health"
        }
    }
}
