//
//  DFTextViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/24/24.
//

import Foundation
import SwiftUI
import PhotosUI
class DFTextViewModel: ObservableObject {
    @Published var txt = ""
    @Published var selectedFont: FontStyle = .modern
    @Published var fontSize: Double = 20
    @Published var fontColor: Color = ColorPreset.colorPallete[0]
    @Published var renderedImage: UIImage?
    @Published var keyboardHeight: CGFloat = 0 // 키보드 높이 상태
    @Published var tab = 0
    @Published var colorNum = 0
    @Published var textAlignment: TextAlignment = .center // 텍스트 정렬 상태
    let colorChip: [Color] = ColorPreset.colorPallete
    
    // 정렬 방향 정의
    enum SwipeDirection {
        case left, right
    }
    // 정렬 상태 변경 함수 -> swift했을 때만
    func computeNextAlignment(for current: TextAlignment, direction: SwipeDirection) -> TextAlignment {
        switch (current, direction) {
            case (.center, .left): return .leading
            case (.center, .right): return .trailing
            case (.leading, .right): return .center
            case (.trailing, .left): return .center
            case (.leading, .left): return .leading // 유지
            case (.trailing, .right): return .trailing // 유지
                //            default: return .center
        }
    }
    
    /// 정렬 이미지명을 String으로 출력
    func imageForAlignment(_ alignment: TextAlignment) -> String {
        switch alignment {
        case .leading:
            return "df.alignment.leading"
        case .center:
            return "df.alignment.center"
        case .trailing:
            return "df.alignment.trailing"

        }
    }
    
    //TODO: 함수명 바꾸기
    /// 누를 때마다 정렬이 바뀜
    func toggleTextAlignment() {
        switch textAlignment {
        case .leading:
                textAlignment = .center
        case .center:
                textAlignment = .trailing
        case .trailing:
                textAlignment = .leading
      
        }
    }
    
    /// DFTextView에서 사용
    @MainActor
    func renderTextImage(text: String){
        let tmp = ImageRenderer(
            content: TextRenderView(
                style: TextStyle(rawText: text, font: selectedFont, color: fontColor, alignment: textAlignment)
            )
        )
        //TODO: scale 계산 부분 넣기
        tmp.scale = 10
        if let uiImage = tmp.uiImage {
            renderedImage = uiImage
        }
        else{
            print("text render 실패")
        }
    }
    
    /// DFTextModifyView에서 사용
    @MainActor
    func renderTextImage(text: String, style: TextStyle){
        let renderer = ImageRenderer(
            content: TextRenderView(
                style: style
            )
        )
        renderer.scale = 10
        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
            
        }
        else{
            print("render 실패")
        }
    }
    
}
//MARK: ViewModel 만드는 대신 extension으로 함수만 따로 뺌
extension DFTextView{
    
    
    
    
    
}


// PHPickerViewController를 사용하는 SwiftUI Wrapper
struct LayerPhotoPicker2: UIViewControllerRepresentable {
    @Binding var layerImages: [LayerModel]
    var screenSize: CGSize
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: LayerPhotoPicker2
        
        init(_ parent: LayerPhotoPicker2) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                let newOrder = self.parent.layerImages.count + 1
                                let newLayerImage = LayerModel(image: uiImage, order: newOrder, position: CGPoint(x: self.parent.screenSize.width/2, y: self.parent.screenSize.height/3))
                                self.parent.layerImages.append(newLayerImage)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
