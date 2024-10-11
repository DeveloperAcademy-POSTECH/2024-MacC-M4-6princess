//
//  IEColorView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/10/24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct IEColorView: View {
    @State private var brightness: Float = 0.0
    @State private var saturation: Float = 1.0
    @State private var contrast: Float = 1.0
    
    let context = CIContext()
    let filter = CIFilter.colorControls()
    let originalImage = UIImage(named: "Felix")!
    
    var body: some View {
        VStack {
            if let outputImage = applyColorAdjustments() {
                Image(uiImage: outputImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            
            // 밝기 슬라이더
            VStack {
                Text("Brightness: \(brightness, specifier: "%.2f")")
                Slider(value: $brightness, in: -1...1)
                    .padding()
            }
            
            // 채도 슬라이더
            VStack {
                Text("Saturation: \(saturation, specifier: "%.2f")")
                Slider(value: $saturation, in: 0...2)
                    .padding()
            }
            
            // 대비 슬라이더
            VStack {
                Text("Contrast: \(contrast, specifier: "%.2f")")
                Slider(value: $contrast, in: 0.5...2)
                    .padding()
            }
        }
        .padding()
    }
    
    // 이미지에 색상 조정을 적용하는 함수
    func applyColorAdjustments() -> UIImage? {
        guard let ciImage = CIImage(image: originalImage) else { return nil }
        
        filter.inputImage = ciImage
        filter.brightness = brightness
        filter.saturation = saturation
        filter.contrast = contrast
        
        guard let outputCIImage = filter.outputImage,
              let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}


#Preview {
    IEColorView()
}
