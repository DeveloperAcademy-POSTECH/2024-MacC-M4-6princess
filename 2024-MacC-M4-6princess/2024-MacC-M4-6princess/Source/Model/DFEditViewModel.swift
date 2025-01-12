import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins
import VisionKit

@MainActor
class DFEditViewModel: ObservableObject {
    
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
    
    @Published var selectionModeIndex: Int = 3
    @Published var lines: [Line] = []
    @Published var thickness: Double = 10.0
    
    @Published var detectedObjects: Set<ImageAnalysisInteraction.Subject> = []
    @Published var clickedButton = false
    @Published var isRenderFailed = false
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    
    private func generateImageForAllSelectedObjects() async throws {
        let allSubjectsImage = try await interaction.image(for: interaction.highlightedSubjects)
        outputImage = allSubjectsImage
    }
    
    private func analyzeImage(_ image: UIImage) async throws -> Set<ImageAnalysisInteraction.Subject> {
        
        let configuration = ImageAnalyzer.Configuration([.visualLookUp])
        let analysis = try await analyzer.analyze(image, configuration: configuration)
        interaction.analysis = analysis
        let detectedSubjects = await interaction.subjects
        return detectedSubjects
    }
    
    func detectSubject(inputImage: UIImage?, completionHandler: @escaping (Bool) -> Void) {
          Task { @MainActor in
              do {
                  guard let inputImage = inputImage else {
                      print("Input image is nil")
                      completionHandler(false) // 실패
                      return
                  }
                  
                  detectedObjects = try await self.analyzeImage(inputImage)
                  print("탐지된 피사체: \(detectedObjects.count)")
                  
                  for i in detectedObjects {
                      interaction.highlightedSubjects.insert(i)
                      try await generateImageForAllSelectedObjects()
                  }
                  
                  completionHandler(true) // 성공
              } catch {
                  print("Failed to detect objects: \(error)")
                  completionHandler(false) // 실패
              }
          }
      }
    
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
    
    func showMaskImage(content: some View) {
        
        let render = ImageRenderer(content: content)
        render.scale = 1
        self.inputImage = render.uiImage
        self.removeBackground()
        if self.maskImageList.count == 0 && self.maskImage != nil {
            self.maskImageList.append(self.maskImage)
        }
        
    }
    
    func drawLines(startLocation: CGPoint, location: CGPoint) {
        if lines.isEmpty  {
            lines = [Line(color: .white, points: [startLocation], mode: Mode(rawValue: selectionModeIndex)!, lineWidth: thickness  / magnifyScale)]
        } else {
            var newLine = Line(color: .white, points: [], mode:  Mode(rawValue: selectionModeIndex)!, lineWidth: thickness  / magnifyScale)
            if startLocation != lines[lines.count - 1].points.first {
                newLine.points = [startLocation]
                lines.append(newLine)
                print("Start new point")
            } else {
                print("Change point event")
                let changedValue = location
                lines[lines.count - 1].points.append(changedValue)
            }
        }
    }
    
    func toolSelect(_ selected: String) {
        
        if selectionModeIndex != 3 {
            
            if (selected == "brush" && selectionModeIndex == 0) || (selected == "erase" && selectionModeIndex == 1) {
                selectionModeIndex = 3
            } else if selected == "brush" && selectionModeIndex == 1 {
                selectionModeIndex = 0
            } else if selected == "erase" && selectionModeIndex == 0 {
                selectionModeIndex = 1
            }
            
        } else {
            
            if selected == "brush" {
                selectionModeIndex = 0
                
            } else {
                selectionModeIndex = 1
            }
        }
    }
    
    func deleteAllLines() {
        if deleteLines {
            lines.removeAll()
            deleteLines = false
        }
    }
    
    func updateLine(context: inout GraphicsContext) {
        
        for line in lines {
            var path = Path()
            path.addLines(line.points)
            if line.mode == .draw {
                context.blendMode = .normal
                context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
            } else {
                context.blendMode = .clear
                context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
            }
        }
    }
    
//    func scaleCompute(_ image: UIImage) -> CGFloat {
//        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.height * 0.76)
//        
//        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
//            scale = image.size.width / UIScreen.main.bounds.width
//            print("\(scale)")
//        }
//        print("\(image.size.width)  \(image.size.height)")
//        print("\(UIScreen.main.bounds.width) \(UIScreen.main.bounds.height)")
//        return scale
//    }
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.width * 4/3)
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
        }
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
    func createResult(completionHandler: @escaping (Bool) -> Void) {
           var resultImage: UIImage?
           
           guard let inputImage = CIImage(image: inputImage ?? UIImage()) else {
               print("Failed to create CIImage")
               completionHandler(false) // 실패
               return
           }
           
           Task { @MainActor in
               if let maskImage = maskImage {
                   let outputImage = apply(mask: CIImage(image: maskImage)!, to: inputImage)
                   resultImage = convertToUIImage(ciImage: outputImage)
                   self.resultImage = resultImage
                   completionHandler(true) // 성공
               } else {
                   print("Mask image is nil")
                   completionHandler(false) // 실패
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
