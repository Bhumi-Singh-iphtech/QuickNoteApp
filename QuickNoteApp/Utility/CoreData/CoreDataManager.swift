import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    // MARK: - Core Data Stack
    func initializeCoreData() {
        _ = persistentContainer
    }

    // 1. Initialize the container directly here
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         IMPORTANT: The name inside quotes ("Model") must match
         the name of your .xcdatamodeld file exactly!
         // Add this line inside your persistentContainer setup or init
         
    
         If your file is called "QuickNoteApp.xcdatamodeld", change "Model" below to "QuickNoteApp".
         */
        print("Core Data Path: \(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.path)")
        let container = NSPersistentContainer(name: "QuickNoteModel")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print(" Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // 2. Helper to access the context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Saving Data
    func saveVoiceNote(fileName: String, duration: String, levels: [Float], category: String, description: String) {
        let note = VoiceNoteEntity(context: context)
        note.audioFileName = fileName
        note.durationText = duration
        note.createdAt = Date()
        
        // Mapping based on your request:
        note.title = category         // From the Label on recording screen
        note.noteDescription = description // From the TextField on recording screen
        
        if let data = try? JSONEncoder().encode(levels) {
            note.waveformData = data
        }
        saveContext()
    }
    func deleteVoiceNote(note: VoiceNoteEntity) {
        // 1. Delete the physical file from the Documents folder
        if let fileName = note.audioFileName {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = path.appendingPathComponent(fileName)
            
            try? FileManager.default.removeItem(at: fileURL)
        }

        // 2. Delete the record from Core Data
        context.delete(note)
        
        // 3. Save the changes
        saveContext()
    }
    
    // MARK: - Fetching Data
    
    func fetchAllNotes() -> [VoiceNoteEntity] {
        let request: NSFetchRequest<VoiceNoteEntity> = VoiceNoteEntity.fetchRequest()
        // Sort by newest first
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching notes: \(error)")
            return []
        }
    }
    func saveVoiceNote(fileName: String, duration: String, levels: [Float]) {
        let note = VoiceNoteEntity(context: context)
        note.id = UUID().uuidString
        note.audioFileName = fileName
        note.createdAt = Date()
        note.durationText = duration
        
        // Convert Float array to Data to store in CoreData
        if let data = try? JSONEncoder().encode(levels) {
            note.waveformData = data
        }
        
        saveContext()
    }
    
    // MARK: - Helper
    
    private func saveContext() {
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
