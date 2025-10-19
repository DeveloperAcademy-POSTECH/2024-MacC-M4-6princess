import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins
import VisionKit

@MainActor
class DFEditViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
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
    
    @Published var toastMessageOpacity: CGFloat = 1
    @Published var removingLoadingOpacity: CGFloat = 0
    
    // MARK: - Private Properties
    
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    private let maxHistoryCount = 10 // ✅ 히스토리 최대 개수 제한
    
    // MARK: - UI Methods
    
    func changeMessageOpacity() {
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.toastMessageOpacity -= 0.1
            }
        }
    }
    
    // MARK: - Image Analysis
    
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
        Task { @MainActor [weak self] in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            do {
                guard let inputImage = inputImage else {
                    print("Input image is nil")
                    completionHandler(false)
                    return
                }
                
                self.detectedObjects = try await self.analyzeImage(inputImage)
                print("탐지된 피사체: \(self.detectedObjects.count)")
                
                for i in self.detectedObjects {
                    self.interaction.highlightedSubjects.insert(i)
                    try await self.generateImageForAllSelectedObjects()
                }
                
                completionHandler(true)
            } catch {
                print("Failed to detect objects: \(error)")
                completionHandler(false)
            }
        }
    }
    
    // MARK: - Scale & Transform
    
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
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.width * 4/3)
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
        }
        return scale
    }
    
    // MARK: - Image Dimensions
    
    func getWidth() -> CGFloat {
        return inputImage?.size.width ?? 0
    }
    
    func getHeight() -> CGFloat {
        return inputImage?.size.height ?? 0
    }
    
    // MARK: - Mask Image
    
    func showMaskImage(content: some View) {
        let render = ImageRenderer(content: content)
        render.scale = 1
        self.inputImage = render.uiImage
        self.removeBackground()
        
        if self.maskImageList.count == 0 && self.maskImage != nil {
            self.maskImageList.append(self.maskImage)
        }
    }
    
    // MARK: - Drawing
    
    func drawLines(startLocation: CGPoint, location: CGPoint) {
        if lines.isEmpty {
            lines = [Line(
                color: .white,
                points: [startLocation],
                mode: Mode(rawValue: selectionModeIndex)!,
                lineWidth: thickness / magnifyScale
            )]
        } else {
            var newLine = Line(
                color: .white,
                points: [],
                mode: Mode(rawValue: selectionModeIndex)!,
                lineWidth: thickness / magnifyScale
            )
            
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
            if (selected == "brush" && selectionModeIndex == 0) ||
               (selected == "erase" && selectionModeIndex == 1) {
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
                context.stroke(
                    path,
                    with: .color(line.color),
                    style: StrokeStyle(
                        lineWidth: line.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            } else {
                context.blendMode = .clear
                context.stroke(
                    path,
                    with: .color(line.color),
                    style: StrokeStyle(
                        lineWidth: line.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            }
        }
    }
    
    // MARK: - History Management (개선됨)
    
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
    
    func appendMaskImage(_ inputImage: UIImage?) {
        guard let image = inputImage else { return }
        
        // ✅ 미래 히스토리 제거 (redo 불가능하게)
        if indexOfMask < maskImageList.count - 1 {
            maskImageList.removeSubrange((indexOfMask + 1)...)
        }
        
        // ✅ 최대 개수 제한 (메모리 관리)
        if maskImageList.count >= maxHistoryCount {
            maskImageList.removeFirst()
            indexOfMask = maxHistoryCount - 1
        } else {
            indexOfMask += 1
        }
        
        maskImageList.append(image)
        maskImage = maskImageList[indexOfMask]
        opacity = 0.4
        maskColor = .pink
        
        print("Mask history count: \(maskImageList.count), current index: \(indexOfMask)")
    }
    
    // MARK: - Background Removal
    
    func createResult(completionHandler: @escaping (Bool) -> Void) {
        var resultImage: UIImage?
        
        guard let inputImage = CIImage(image: inputImage ?? UIImage()) else {
            print("Failed to create CIImage")
            completionHandler(false)
            return
        }
        
        Task { @MainActor [weak self] in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            if let maskImage = self.maskImage {
                let outputImage = self.apply(mask: CIImage(image: maskImage)!, to: inputImage)
                resultImage = self.convertToUIImage(ciImage: outputImage)
                self.resultImage = resultImage
                completionHandler(true)
            } else {
                print("Mask image is nil")
                completionHandler(false)
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
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            guard let fakeMask = self.createMask(from: inputImage) else {
                print("Failed to create mask")
                return
            }
            
            let maskImage = self.apply(mask: fakeMask, to: fakeMask)
            let outputImage = self.apply(mask: maskImage, to: inputImage)
            
            resultImage = self.convertToUIImage(ciImage: outputImage)
            mask = self.convertToUIImage(ciImage: maskImage)
            
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
                let mask = try result.generateScaledMaskForImage(
                    forInstances: result.allInstances,
                    from: handler
                )
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
        guard let cgImage = CIContext(options: nil).createCGImage(
            ciImage,
            from: ciImage.extent
        ) else {
            fatalError("Failed to render CGImage")
        }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Memory Management
    
    /// 메모리 정리 (MainActor에서 호출 가능)
    func cleanup() {
        // 이미지 제거
        maskImage = nil
        resultImage = nil
        inputImage = nil
        outputImage = nil
        
        // 배열 제거
        maskImageList.removeAll()
        lines.removeAll()
        detectedObjects.removeAll()
        
        // 인터랙션 초기화
        interaction.analysis = nil
        interaction.highlightedSubjects.removeAll()
        
        // 인덱스 초기화
        indexOfMask = 0
        
        // 상태 초기화
        magnifyScale = 1.0
        lastScale = 1.0
        draggedOffSet = .zero
        accumulatedOffSet = .zero
        selectionModeIndex = 3
        thickness = 10.0
        clickedButton = false
        isRenderFailed = false
        
        print("DFEditViewModel cleaned up")
    }
    
    /// 일부 상태만 초기화 (화면 전환 시)
    func resetState() {
        magnifyScale = 1.0
        lastScale = 1.0
        draggedOffSet = .zero
        accumulatedOffSet = .zero
        deleteLines = false
        isShowThick = false
        showPreview = false
        clickedButton = false
    }
    
    deinit {
        print("DFEditViewModel deinitialized")
    }
}
