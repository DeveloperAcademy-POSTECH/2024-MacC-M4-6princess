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
    @ObservedObject var ievm:IEViewModel
    
    @Binding var bgImg: UIImage
    @Binding var idolImg: UIImage
    
    
    var imageAspectRatio: CGFloat {
        return idolImg.size.width / idolImg.size.height
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: bgImg)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    TapGesture()
                        .onEnded {
                            ievm.isSelected = false
                        }
                )
            if let outputImage = ievm.applyColorAdjustments(originalImage: idolImg) {
                Image(uiImage: outputImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: ievm.baseWidth * ievm.imageScale,
                           height: (ievm.baseWidth / imageAspectRatio) * ievm.imageScale)
                    .rotationEffect(ievm.rotationAngle)
                    .overlay(
                        Rectangle()
                            .stroke(ievm.isSelected ? Color.blue : Color.clear, lineWidth: 1)
                            .frame(width: (ievm.baseWidth * ievm.imageScale) + 6,
                                   height: ((ievm.baseWidth / imageAspectRatio) * ievm.imageScale) + 6)
                            .rotationEffect(ievm.rotationAngle)
                    )
                    .gesture(
                        TapGesture()
                            .onEnded {
                                ievm.toggleSelection()
                            }
                    )
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    if ievm.isSelected {
                                        ievm.updateImageScale(with: value)
                                    }
                                }
                                .onEnded { _ in
                                    ievm.endScaling()
                                },
                            RotationGesture()
                                .onChanged { angle in
                                    if ievm.isSelected {
                                        ievm.updateRotationAngle(with: angle)
                                    }
                                }
                        )
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if ievm.isSelected {
                                    ievm.updateDragOffset(with: value.translation)
                                    
                                }
                            }
                            .onEnded { _ in
                                ievm.endDragging()
                            }
                    )
                    .scaleEffect(ievm.imageScale)
                    .offset(ievm.dragOffset)
            }
            
        }
        .onAppear{
            guard let backgroundCGImage = bgImg.cgImage,
                  let idolCGImage = idolImg.cgImage else {
                fatalError("이미지 로드 실패")
            }
            bgImg = UIImage(cgImage: backgroundCGImage, scale: 1.0, orientation: .up)
            idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
            
        }
    }
}
