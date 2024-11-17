import SwiftUI
import Vision
import VisionKit

@MainActor
class DFModifyFrameViewModel: ObservableObject {
    
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
    
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    
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
    
    func detectSubject(inputImage: UIImage?) {
        
        Task { @MainActor in
            
            do {
                guard let inputImage = inputImage else { return }
                detectedObjects = try await self.analyzeImage(inputImage)
                print("탐지된 피사체: \(detectedObjects.count)")
//                try await Task.sleep(for: .seconds(1))
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
