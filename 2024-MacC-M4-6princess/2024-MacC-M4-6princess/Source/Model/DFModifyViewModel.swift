import SwiftUI
import Vision
import VisionKit
import CoreData

@MainActor
class DFModifyViewModel: ObservableObject {
    
    @Published var btnOpacity: Double = 0.0
    @Published var accumulatedOffset = CGSize.zero
    @Published var image: UIImage?
    @Published var isShowCamera: Bool = false
    @Published var detectedObjects: Set<ImageAnalysisInteraction.Subject> = []
    @Published var outputImage: UIImage?
    @Published var magnifyScale = 1.0
    @Published var lastScale = 1.0
    @Published var draggedOffSet: CGSize = .zero
    @Published var accumulatedOffSet: CGSize = .zero
    @Published var location: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @Published var angle: Angle = .degrees(0)
    @Published var current: Angle = .degrees(0)
    @Published var isPushedSaveBtn: Bool = false
    @Published var saveStateText: String = ""
    @Published var indexOfImageList: Int = 0
    @Published var imageList: [subjectImage] = []
    @Published var isShowImagePickerView: Bool = false
    @Published var imageHistory: [subjectImage] = []
    @Published var frameImage: UIImage?

    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    
    func onAppearTask(image: UIImage) {
        
        detectSubject(inputImage: image)
        makeImageList()
        
    }
    
    func saveImage(view: some View, inputImage: UIImage, context: NSManagedObjectContext) {
        
        btnOpacity = 1
        
        Task {
            // 저장 완료 메시지 숨기기
            let render = ImageRenderer(content: view.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
            render.scale = scaleCompute(inputImage)
            frameImage = render.uiImage
            addImage(albumImageData: frameImage?.pngData(), context: context)
            try await Task.sleep(nanoseconds: 1_000_000_000)
            btnOpacity = 0
            isShowCamera = true
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
    
    
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.width * 4/3)
        
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
        }
        return scale
    }
    
    func makeImageList() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            var inputImage = subjectImage()
            
            inputImage.image = self.outputImage
            
            self.imageHistory.append(inputImage)
        }
    }

    
    
    func makeHistory() {
        
        var inputImage = subjectImage()
        
        inputImage.image = outputImage
        inputImage.angle = angle
        inputImage.scale = magnifyScale
        inputImage.offSet = draggedOffSet

        if imageList.count > 0 {
            indexOfImageList += 1
        }
        
        imageList.append(inputImage)
        
    }
    
    
    func reDo() {
        
        if indexOfImageList > 0 {
            indexOfImageList -= 1
            angle = imageList[indexOfImageList].angle
            current = imageList[indexOfImageList].angle
            magnifyScale = imageList[indexOfImageList].scale
            draggedOffSet = imageList[indexOfImageList].offSet
        }
    }
    
    func unDo() {
        
        if imageList.count - 1 > indexOfImageList {
            indexOfImageList += 1
            angle = imageList[indexOfImageList].angle
            current = imageList[indexOfImageList].angle
            magnifyScale = imageList[indexOfImageList].scale
            draggedOffSet = imageList[indexOfImageList].offSet
        }
    }
    
    func setScaleValue(minimum: CGFloat, maximum: CGFloat) {
        
        if magnifyScale < minimum {
            magnifyScale = minimum
            
        } else if magnifyScale > maximum {
            magnifyScale = maximum
        }
        lastScale = 1.0
        
    }
    
    func setScaleVolume(_ magnify: CGFloat) {
        
        let scaleVolume = magnify / lastScale
        magnifyScale *= scaleVolume
        lastScale = magnify
    }
    
    private func analyzeImage(_ image: UIImage) async throws -> Set<ImageAnalysisInteraction.Subject> {
        
        let configuration = ImageAnalyzer.Configuration([.visualLookUp])
        let analysis = try await analyzer.analyze(image, configuration: configuration)
        interaction.analysis = analysis
        let detectedSubjects = await interaction.subjects
        return detectedSubjects
    }
    
    private func detectSubject(inputImage: UIImage?) {
        
        Task { @MainActor in
            
            do {
                guard let inputImage = inputImage else { return }
                detectedObjects = try await self.analyzeImage(inputImage)
                print("탐지된 피사체: \(detectedObjects.count)")
                for i in detectedObjects {
                    interaction.highlightedSubjects.insert(i)
                    try await generateImageForAllSelectedObjects()
                }
                
            } catch {
                print("none object detected")
            }
            
        }
    }
    
    private func generateImageForAllSelectedObjects() async throws {
        let allSubjectsImage = try await interaction.image(for: interaction.highlightedSubjects)
        outputImage = allSubjectsImage
    }

}
