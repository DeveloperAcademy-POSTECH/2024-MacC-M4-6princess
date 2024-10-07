//
//  ImageResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/4/24.
//
import SwiftUI

struct ImageResizeView: View {
    @State private var imageScale: CGFloat = 1.0
    @State private var startScale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero
    @State private var startOffset: CGSize = .zero
    @State private var isSelected: Bool = false
    @State private var rotationAngle: Angle = .zero
    @State private var showingSavedAlert: Bool = false
    
    let backgroundImage: UIImage = UIImage(named: "6공주들")!
    let idolImage: UIImage = UIImage(named: "필릭스디즈니누끼")!
    
    var imageAspectRatio: CGFloat {
        return idolImage.size.width / idolImage.size.height
    }
    
    let baseWidth: CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        TapGesture()
                            .onEnded {
                                isSelected = false
                            }
                    )
                
                Image(uiImage: idolImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: baseWidth * imageScale, height: (baseWidth / imageAspectRatio) * imageScale)
                    .rotationEffect(rotationAngle)
                    .overlay(
                        Rectangle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                            .frame(width: (baseWidth * imageScale) + 6, height: ((baseWidth / imageAspectRatio) * imageScale) + 6)
                    )
                    .gesture(
                        TapGesture()
                            .onEnded {
                                isSelected = true
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if isSelected {
                                    imageScale = max(0.5, min(5, startScale + (value - 1) / 10))
                                }
                            }
                            .onEnded { _ in
                                startScale = imageScale
                            }
                    )
                    .gesture(
                        RotationGesture()
                            .onChanged { angle in
                                if isSelected {
                                    rotationAngle = angle
                                }
                            }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if isSelected {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        dragOffset = CGSize(
                                            width: startOffset.width + value.translation.width,
                                            height: startOffset.height + value.translation.height
                                        )
                                    }
                                }
                            }
                            .onEnded { _ in
                                startOffset = dragOffset
                            }
                    )
                    .scaleEffect(imageScale)
                    .offset(dragOffset)
                
                VStack {
                    Spacer()
                    Button(action: {
                        saveImage(geometry: geometry)
                    }) {
                        Text("Save Image")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.white)
        }
        .alert(isPresented: $showingSavedAlert) {
            Alert(title: Text("Success"), message: Text("Image saved successfully!"), dismissButton: .default(Text("OK")))
        }
    }
    
    func saveImage(geometry: GeometryProxy) {
        let renderer = ImageRenderer(content:
            ZStack {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                Image(uiImage: idolImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: baseWidth * imageScale, height: (baseWidth / imageAspectRatio) * imageScale)
                    .rotationEffect(rotationAngle)
                    .scaleEffect(imageScale)
                    .offset(dragOffset)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.white)
        )
        
        if let uiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            showingSavedAlert = true
        }
    }
}
