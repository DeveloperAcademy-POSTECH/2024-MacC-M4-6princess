import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ImageModel") // .xcdatamodeld 파일명
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "file:///var/mobile/Containers/Data/Application/D1E76FBE-FB26-45FF-A12E-46214A60835E/Library/Application%20Support/ImageModel.sqlite")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
            
            #if DEBUG
            // CoreData 파일 위치 확인
            if let url = description.url {
                print("Core Data store URL: \(url)")
            }
            #endif
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
