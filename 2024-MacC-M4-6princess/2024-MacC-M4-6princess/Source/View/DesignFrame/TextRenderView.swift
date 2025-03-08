//
//  TextRenderView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/25/24.
//

import SwiftUI
import PhotosUI

struct TextRenderView: View {
    let style: TextStyle
    
    var body: some View {
        Text("없어짐")
        //            .font(style.font.applyFont(size: 20))
            .foregroundColor(style.color)
            .multilineTextAlignment(style.alignment)
            .lineSpacing(5)
            .padding(.vertical,3)
    }
}

struct TextStyle {
    var attributedString: NSAttributedString{
        didSet{
            print("TextStyle:\(attributedString.string)")
        }
    }
    var txt:String
    var font: NewFontStyle
    var color: Color
    {
        didSet {
            // 값이 변경될 때마다 프린트
            print("스타일컬러바뀜: \(color.toHex())")
        }
    }
    var alignment: TextAlignment
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
