//
//  AppMessages .swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 27/01/26.
//

import Foundation

enum AlertMessages {
    
    // MARK: - Titles
    enum Title {
        static let deleteNote = "Delete Note"
        static let deleteFolder = "Delete Folder"
        static let saveNote = "Save Note"
        static let addFolder = "Add Folder"
        static let moved = "Moved"
        static let saved = "Saved"
    }
    
    // MARK: - Messages
    enum Message {
        static let deleteNoteConfirmation = "Are you sure you want to delete this note?"
        static let deleteFolderConfirmation = "Do you want to delete this folder and all its notes?"
        static let saveNoteConfirmation = "Are you sure you want to save this note?"
      
        static let folderCategory = "Select a category"
        static func movedToFolder(_ name: String) -> String {
                   return "Note moved to \(name)"
               }
      
    }
    
    // MARK: - Button Actions
    enum Action {
        static let delete = "Delete"
        static let save = "Save"
        static let cancel = "Cancel"
        static let ok = "OK"
        static let add = "Add"
    }
}
