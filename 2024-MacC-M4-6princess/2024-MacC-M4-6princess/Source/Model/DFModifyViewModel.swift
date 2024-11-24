import SwiftUI
import Vision
import VisionKit
import CoreData

@MainActor
class DFModifyViewModel: ObservableObject {
    
    @Published var btnOpacity: Double = 0.0
    
    @Published var showCamera: Bool = false
    @Published var showImagePickerView: Bool = false

    @Published var isPushedSaveBtn: Bool = false
    @Published var saveStateText: String = ""
    
    @Published var outputImage: UIImage?
    @Published var indexOfImageList: Int = 0
    @Published var imageList: [SubjectImage] = []
    @Published var imageHistory: [SubjectImage] = []
    
    @Published var frameImage: UIImage?
    
    @Published var showTextView: Bool = false
    @Published var showStickerSheet: Bool = false
    
    @Published var isAlert: Bool = false
    
    func saveImage(view: some View, inputImage: UIImage, context: NSManagedObjectContext, completionHandler: @escaping () -> Void) {
        
        btnOpacity = 1
        
        Task {
            // 저장 완료 메시지 숨기기
            let render = ImageRenderer(content: view.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
//            render.scale = scaleCompute(inputImage)
            render.scale = UIScreen.main.scale
            frameImage = render.uiImage
            addImage(albumImageData: frameImage?.pngData(), context: context)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completionHandler()
        }
        
    }
    
    func saveContext(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    func addImage(albumImageData: Data?, context: NSManagedObjectContext) {
        
        let newImage = StoreImages(context: context)
        
        newImage.image = albumImageData
        newImage.uuid = UUID()
        newImage.isSelected = false
        
        saveContext(context: context)
    }
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.width * 4/3)
        
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
        }
        return scale
    }
    
    func makeImageList() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            var inputImage = SubjectImage()
            
            inputImage.image = self.outputImage
            
            self.imageHistory.append(inputImage)
        }
    }
    
    func makeImage(view: some View, image: UIImage) -> UIImage? {
        
        let resultImage: UIImage?
        let render = ImageRenderer(content: view)
        render.scale = scaleCompute(image)
        if let rend = render.uiImage {
            if indexOfImageList < imageList.count - 1 {
                for _ in indexOfImageList+1..<imageList.count {
                    imageList.removeLast()
                }
            }
            imageList[indexOfImageList].image = rend
            indexOfImageList += 1
            
        }
        resultImage = imageList[indexOfImageList].image
        return resultImage
    }
    
//    func addImage(albumImageData: Data?, subjectImageData: Data?, context: NSManagedObjectContext) {
//        
//        let newImage = StoreImages(context: context)
//        
//        newImage.image = albumImageData
//        newImage.subjectImage = subjectImageData
//        newImage.uuid = UUID()
//        newImage.isSelected = false
//        newImage.angle = angle.degrees
//        newImage.x = draggedOffSet.width
//        newImage.y = draggedOffSet.height
//        newImage.scale = magnifyScale
//        
//        saveContext(context: context)
//    }
    
    
//    func reDo() {
//        
//        if indexOfImageList > 0 {
//            indexOfImageList -= 1
//            angle = imageList[indexOfImageList].angle
//            current = imageList[indexOfImageList].angle
//            magnifyScale = imageList[indexOfImageList].scale
//            draggedOffSet = imageList[indexOfImageList].offSet
//        }
//    }
//    
//    func unDo() {
//        
//        if imageList.count - 1 > indexOfImageList {
//            indexOfImageList += 1
//            angle = imageList[indexOfImageList].angle
//            current = imageList[indexOfImageList].angle
//            magnifyScale = imageList[indexOfImageList].scale
//            draggedOffSet = imageList[indexOfImageList].offSet
//        }
//    }

}
