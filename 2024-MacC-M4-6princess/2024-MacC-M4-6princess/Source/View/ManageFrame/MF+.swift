import SwiftUI
import CoreData

extension MFView {
    
    func loadSelectedFrame(completionHandler: @escaping () -> Void) {
        
        imageModel.imageList.removeAll()
        
        guard let frameId = frameManager.updateFrame else {
            frameManager.resultImage = nil
            return
        }
        
        let fetchRequest: NSFetchRequest<StoreImages> = StoreImages.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", frameId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            
            if let storedImage = results.first {
                
                getSubjects(storeImage: storedImage)
                
            } else {
                frameManager.resultImage = nil
            }
        } catch {
            print("Error fetching frame: \(error)")
            frameManager.resultImage = nil
        }
        completionHandler()
    }
    
    func getSubjects(storeImage: StoreImages) {
        
        let entity: StoreImages = storeImage
        
        if let subjects = entity.subjects?.allObjects as? [Subject] {
            
            for subject in subjects {
                
                let newImage = SubjectImage()
                
                if let image = subject.subImage, let originImage = subject.originalImage, let mask = subject.maskImage {
                    newImage.image = UIImage(data: image)
                    newImage.originalImage = UIImage(data: originImage)
                    newImage.maskImage = UIImage(data: mask)
                } else if let text = subject.text, let originText = subject.originalText {
                    newImage.text = UIImage(data: text)
                    newImage.textStyle = TextStyle(attributedString: NSAttributedString(string: ""), txt: originText, font: .modern, color: ColorPreset.colorPallete[0], alignment: .center, fontSize: 20)
                } else if let sticker = subject.sticker {
                    newImage.sticker = UIImage(data: sticker)
                }
                
                newImage.scale = subject.scale
                newImage.angle = Angle.degrees(subject.angle)
                newImage.offset = CGSize(width: subject.x, height: subject.y)
                newImage.isTapped = false
                if subject == subjects.last {
                    newImage.isTapped = true
                }
                
                if newImage.image != nil {
                    print("이미지 있음!!")
                }
                
                imageModel.imageList.append(newImage)
            }
        }
        
    }
    
}
