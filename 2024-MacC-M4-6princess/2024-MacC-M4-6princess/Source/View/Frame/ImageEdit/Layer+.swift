//
//  Layer+.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/14/24.
//

import SwiftUI
import PhotosUI


// PHPickerViewController를 사용하는 SwiftUI Wrapper
struct LayerPhotoPicker: UIViewControllerRepresentable {
    @Binding var layerImages: [LayerImage]
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
        let parent: LayerPhotoPicker
        
        init(_ parent: LayerPhotoPicker) {
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
                                let newLayerImage = LayerImage(image: uiImage, order: newOrder, position: CGPoint(x: self.parent.screenSize.width/2, y: self.parent.screenSize.height/3))
                                self.parent.layerImages.append(newLayerImage)
                            }
                        }
                    }
                }
            }
        }
    }
}
