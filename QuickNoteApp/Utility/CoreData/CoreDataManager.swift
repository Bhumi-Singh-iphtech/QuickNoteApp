import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    // MARK: - Core Data Stack
    func initializeCoreData() {
        _ = persistentContainer
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "QuickNoteModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print(" Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Folder Management
    
    // 1. Create a new folder
    func createFolder(name: String) {
        let folder = FolderEntity(context: context)
        folder.title = name
        folder.dateCreated = Date()
        saveContext()
    }
    
    // 2. Fetch all folders
    func fetchAllFolders() -> [FolderEntity] {
        let request: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching folders: \(error)")
            return []
        }
    }

    // 🔥 3. DELETE FOLDER (ADD THIS FUNCTION) 🔥
    func deleteFolder(name: String) {
        let request: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        // Find the folder with the matching name
        request.predicate = NSPredicate(format: "title == %@", name)
        
        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object) // Delete from DB
            }
            saveContext() // Commit changes
            print("Folder '\(name)' deleted from CoreData")
        } catch {
            print("Error deleting folder: \(error)")
        }
    }
    
    // MARK: - Plain Note Management
    func savePlainNote(content: String, title: String, category: String) ->
        PlainNoteEntity {
            let note = PlainNoteEntity(context: context)
            note.content = content
            note.title = title
            note.category = category
            note.date = Date()
            saveContext()
            return note
        }
    
    // Add this inside CoreDataManager class, near the Plain Note section

    func createPlainNote(title: String, content: String, category: String) -> PlainNoteEntity {
        let note = PlainNoteEntity(context: context)
        note.title = title
        note.content = content
        note.category = category
        note.date = Date()
        
        // Save immediately
        if context.hasChanges {
            try? context.save()
        }
        
        return note
    }
    // In CoreDataManager.swift
    func fetchAllPlainNotes() -> [PlainNoteEntity] {
        let request: NSFetchRequest<PlainNoteEntity> = PlainNoteEntity.fetchRequest()
        // Sort by date (newest first)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching all plain notes: \(error)")
            return []
        }
    }
    func ensureDefaultFolders() {
        let request: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        
        do {
            // Use 'context' here as defined in your class
            let count = try context.count(for: request)
            if count == 0 {
                // No folders found, create the defaults
                let defaultFolders = ["Personal", "Work", "School", "Travel"]
                for folderName in defaultFolders {
                    let newFolder = FolderEntity(context: context)
                    newFolder.title = folderName
                    
                    newFolder.dateCreated = Date()
                }
                saveContext()
                print("Default folders initialized in Core Data.")
            }
        } catch {
            print("Error checking for default folders: \(error)")
        }
    }
    func fetchPlainNotes(for category: String) -> [PlainNoteEntity] {
        let request: NSFetchRequest<PlainNoteEntity> = PlainNoteEntity.fetchRequest()
        // Filter by the specific category name
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching notes for category \(category): \(error)")
            return []
        }
    }
    
    func deletePlainNote(_ note: PlainNoteEntity) {
        context.delete(note)
        saveContext()
    }
    
    // MARK: - Voice Note Management
    func saveVoiceNote(fileName: String, duration: String, levels: [Float], category: String, description: String) -> VoiceNoteEntity {
        let note = VoiceNoteEntity(context: context)
        note.audioFileName = fileName
        note.durationText = duration
        note.createdAt = Date()
        note.title = category // Category
        note.noteDescription = description // Title/Name
        
        if let data = try? JSONEncoder().encode(levels) {
            note.waveformData = data
        }
        saveContext()
        return note 
    }
    func fetchAllNotes() -> [VoiceNoteEntity] {
        let request: NSFetchRequest<VoiceNoteEntity> = VoiceNoteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching notes: \(error)")
            return []
        }
    }
    
    func deleteVoiceNote(note: VoiceNoteEntity) {
        if let fileName = note.audioFileName {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = path.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        context.delete(note)
        saveContext()
    }
    
    // Overloaded save for simpler calls if needed
    func saveVoiceNote(fileName: String, duration: String, levels: [Float]) {
        let note = VoiceNoteEntity(context: context)
        note.id = UUID().uuidString
        note.audioFileName = fileName
        note.createdAt = Date()
        note.durationText = duration
        if let data = try? JSONEncoder().encode(levels) {
            note.waveformData = data
        }
        saveContext()
    }
    
   func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("Data Saved Successfully")
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
extension Notification.Name {
    static let refreshHomeNotes = Notification.Name("RefreshHomeNotes")
}
extension Notification.Name {
    static let navigateToHome = Notification.Name("NavigateToHome")
}
