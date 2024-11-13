import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins
import VisionKit

class DFFrameEditViewModel: ObservableObject {
    
    @Published var maskImage: UIImage?
    @Published var resultImage: UIImage?
    @Published var inputImage: UIImage?
    @Published var maskImageList: [UIImage?] = []
    @Published var indexOfMask: Int = 0
    @Published var maskColor: Color = .pink
    @Published var opacity: CGFloat = 0.4
    @Published var deleteLines: Bool = false
    @Published var isShowThick: Bool = false
    @Published var showPreview: Bool = false
    @Published var isShowModifyFrame: Bool = false
    @Published var magnifyScale = 1.0
    @Published var lastScale = 1.0
    @Published var draggedOffSet: CGSize = .zero
    @Published var accumulatedOffSet: CGSize = .zero
    @Published var outputImage: UIImage?
    @Published var detectedObjects: Set<ImageAnalysisInteraction.Subject> = []
    
//    let analyzer = ImageAnalyzer()
//    let interaction = ImageAnalysisInteraction()
//    
//    func analyzeImage(_ image: UIImage) async throws -> Set<ImageAnalysisInteraction.Subject> {
//        
//        let configuration = ImageAnalyzer.Configuration([.visualLookUp])
//        let analysis = try await analyzer.analyze(image, configuration: configuration)
//        interaction.analysis = analysis
//        let detectedSubjects = await interaction.subjects
//        return detectedSubjects
//    }
//    
//    func detectSubject(inputImage: UIImage?) {
//        
//        Task { @MainActor in
//            
//            do {
//                guard let inputImage = inputImage else { return }
    //                detectedObjects = try await self.analyzeImage(inputImage)
    //                print("탐지된 피사체: \(detectedObjects.count)")
//
//            } catch {
//                print("none object detected")
//            }
//            
//        }
//    }
//    
//    func extractsubject() {
//        
//        for i in detectedObjects {
//            
//            Task { @MainActor in
//                
//                if let objectImage = try? await i.image {
//                    outputImage = objectImage
//                } else {
//                    print("저장실패")
//                }
//            }
//            
//        }
//    }
    
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
    
    func getWidth() -> CGFloat {
        return inputImage?.size.width ?? 0
    }
    
    func getHeight() -> CGFloat {
        return inputImage?.size.height ?? 0
    }
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.height * 0.76)
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
            print("\(scale)")
        }
        print("\(image.size.width)  \(image.size.height)")
        print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
        return scale
    }
    
    func reDo() {
        if indexOfMask > 0 {
            indexOfMask -= 1
            maskImage = maskImageList[indexOfMask]
            deleteLines = true
        }
    }
    
    func unDo() {
        if maskImageList.count - 1 > indexOfMask {
            indexOfMask += 1
            maskImage = maskImageList[indexOfMask]
            deleteLines = true
        }
    }
    func createResult() {
        
        var resultImage: UIImage?
        
        guard let inputImage = CIImage(image: inputImage ?? UIImage()) else {
            print("Failed to create CIImage")
            return
        }
        
        Task { @MainActor in
            
            if let maskImage = maskImage {
                
                let outputImage = apply(mask: CIImage(image: maskImage)!, to: inputImage)
                resultImage = convertToUIImage(ciImage: outputImage)
                self.resultImage = resultImage
            }
        }
    }
    
    func removeBackground() {
        
        var mask: UIImage?
        var resultImage: UIImage?
        
        guard let inputImage = CIImage(image: inputImage ?? UIImage()) else {
            print("Failed to create CIImage")
            return
        }
        
        Task { @MainActor in
            guard let fakeMask = createMask(from: inputImage) else {
                print("Failed to create mask")
                return
            }
            
            let maskImage = apply(mask: fakeMask, to: fakeMask)
            
            let outputImage = apply(mask: maskImage, to: inputImage)
            resultImage = convertToUIImage(ciImage: outputImage)
            mask = convertToUIImage(ciImage: maskImage)
            self.maskImage = mask
            self.resultImage = resultImage
        }
    }
    
    //    func detectSubjects(from inputImage: CIImage) -> CIImage? {
    //
    //        let handler = VNImageRequestHandler(ciImage: inputImage)
    //        let detect = VNDetectHorizonRequest()
    ////        let request = VNTrackObjectRequest(detectedObjectObservation: detect)
    //
    //
    //    }
    
    private func createMask(from inputImage: CIImage) -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: inputImage)
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        do {
            try handler.perform([request])
            
            if let result = request.results?.first {
                let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                return CIImage(cvPixelBuffer: mask)
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func apply(mask: CIImage, to image: CIImage) -> CIImage {
        
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.maskImage = mask
        filter.backgroundImage = CIImage.empty()
        return filter.outputImage!
    }
    
    private func convertToUIImage(ciImage: CIImage) -> UIImage {
        
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {
            fatalError("Failed to render CGImage")
        }
        return UIImage(cgImage: cgImage)
    }
    
    func appendMaskImage(_ inputImage: UIImage?) {
        if let image = inputImage {
            if indexOfMask < maskImageList.count - 1 {
                for _ in indexOfMask+1..<maskImageList.count {
                    maskImageList.removeLast()
                }
            }
            maskImageList.append(image)
            indexOfMask += 1
            print("\(indexOfMask)")
            
        }
        maskImage = maskImageList[indexOfMask]
        opacity = 0.4
        maskColor = .pink
    }
    
}
