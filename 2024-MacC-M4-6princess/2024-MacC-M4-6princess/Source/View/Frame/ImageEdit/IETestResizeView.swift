//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//
//TODO: 세부작업,뷰모델 작업,색감조정 함수 넣고, 제인이랑 뷰연결 -> 이미지 저장
//TODO: 위치 저장
//TODO: 언두,리두
import SwiftUI

struct IETestResizeView: View {
    @ObservedObject var viewModel:IEViewModel
    
    @Binding var backgroundImg: UIImage
    @Binding var idolImg: UIImage
    
    
    var imageAspectRatio: CGFloat {
        return idolImg.size.width / idolImg.size.height
    }
    
    let baseWidth: CGFloat = 100
    
    var body: some View {
        ZStack {
            Image(uiImage: backgroundImg)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    TapGesture()
                        .onEnded {
                            viewModel.isSelected = false
                        }
                )
            if let outputImage = viewModel.applyColorAdjustments(originalImage: idolImg) {
                Image(uiImage: outputImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: baseWidth * viewModel.imageScale,
                           height: (baseWidth / imageAspectRatio) * viewModel.imageScale)
                    .rotationEffect(viewModel.rotationAngle)
                    .overlay(
                        Rectangle()
                            .stroke(viewModel.isSelected ? Color.blue : Color.clear, lineWidth: 1)
                            .frame(width: (baseWidth * viewModel.imageScale) + 6,
                                   height: ((baseWidth / imageAspectRatio) * viewModel.imageScale) + 6)
                            .rotationEffect(viewModel.rotationAngle)
                    )
                    .gesture(
                        TapGesture()
                            .onEnded {
                                viewModel.toggleSelection()
                            }
                    )
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    if viewModel.isSelected {
                                        viewModel.updateImageScale(with: value)
                                    }
                                }
                                .onEnded { _ in
                                    viewModel.endScaling()
                                },
                            RotationGesture()
                                .onChanged { angle in
                                    if viewModel.isSelected {
                                        viewModel.updateRotationAngle(with: angle)
                                    }
                                }
                        )
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if viewModel.isSelected {
                                    
                                    viewModel.updateDragOffset(with: value.translation)
    //                                print(value)
                                    
                                }
                            }
                            .onEnded { _ in
                                viewModel.endDragging()
                            }
                    )
                    .scaleEffect(viewModel.imageScale)
                    .offset(viewModel.dragOffset)
            }
//            Image(uiImage: idolImg)
                
        }
        .onAppear{
            guard let backgroundCGImage = backgroundImg.cgImage,
                  let idolCGImage = idolImg.cgImage else {
                fatalError("이미지 로드 실패")
            }
            backgroundImg = UIImage(cgImage: backgroundCGImage, scale: 1.0, orientation: .up)
            idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
            
        }
    }
}
