import SwiftUI
import Vision
import VisionKit

@MainActor
class DFModifyFrameViewModel: ObservableObject {
    
    @Published var btnOpacity: Double = 0.0
    @Published var imageHistory: [UIImage?] = []
    @Published var indexOfHistory: Int = 0
    @Published var currentSize = 0.0
    @Published var finalSize = 1.0
    @Published var currentAngle = Angle.zero
    @Published var finalAngle = Angle.zero
    @Published var draggedOffset = CGSize.zero
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
    @Published var anchor: UnitPoint = .zero
    @Published var isPushedSaveBtn: Bool = false
    
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    func setScaleValue(minimum: CGFloat, maximum: CGFloat) {
        
        if magnifyScale < minimum {
            
            magnifyScale = minimum
            draggedOffSet = .zero
            accumulatedOffSet = .zero
            
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
    
    func analyzeImage(_ image: UIImage) async throws -> Set<ImageAnalysisInteraction.Subject> {
        
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
                
            } catch {
                print("none object detected")
            }
            
        }
    }
    
    //    func generateImageForAllSelectedObjects() async throws {
    //
    //        let allSubjectsImage = try await self.interaction.image(for: self.interaction.highlightedSubjects)
    //        outputImage = allSubjectsImage
    //    }
    
    func extractsubject() {
        
        
        for i in detectedObjects {
            
            Task { @MainActor in
                
                if let objectImage = try? await i.image {
                    outputImage = objectImage
                    print("저장완료")
                } else {
                    print("저장실패")
                }
            }
            
        }
    }
}
