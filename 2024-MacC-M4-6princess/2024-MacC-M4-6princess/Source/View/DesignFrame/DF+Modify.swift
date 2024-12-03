//
//  DF+Modify.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 12/1/24.
//

import SwiftUI
import Foundation
import CoreData

extension DFModifyView{
    func combinedGesture(subject: SubjectImage) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !isLongPressed{
                    viewModel.dragGestureTask(subject: subject, changed: value.translation)
                }
            }
            .onEnded { value in
                if !isLongPressed {
                    viewModel.accumulatedOffSet = .zero
                    viewModel.modelListControl(subject: subject)
                    subject.isTapped = true
                    imageModel.imageList.append(subject)
                    imageModel.imageList.removeLast()
                }
                
            }
            .simultaneously(with: RotateGesture()
                .onChanged { value in
                    if !isLongPressed && subject.isTapped  {
                        if viewModel.current == .zero {
                            viewModel.current = subject.getAngle()
                        }
                        viewModel.angle = value.rotation + viewModel.current
                        subject.setAngle(angle: viewModel.angle)
                    }
                }
                .onEnded { value in
                    if !isLongPressed{
                        viewModel.current = .zero
                    }
                }
            )
            .simultaneously(with: MagnifyGesture()
                .onChanged { value in
                    if !isLongPressed && subject.isTapped {
                        viewModel.setScaleVolume(value.magnification, subject: subject)
                    }
                }
                .onEnded { value in
                    if !isLongPressed{
                        viewModel.setScaleValue(minimum: 0.2, maximum: 10, subject: subject)
                    }
                }
            )
    }
    var toolBarButtons: some View {
        HStack {
            Button {
                viewModel.isAlert.toggle()
            } label: {
                HStack {
                    Image(systemName: "chevron.backward")
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray01)
                    
                    Text("프레임 선택")
                        .fontWeight(.regular)
                        .foregroundStyle(.gray01)
                }
            }
            .alert("프레임 편집을 종료하시겠습니까?", isPresented: $viewModel.isAlert) {
                Button {
                    viewModel.isAlert.toggle()
                } label: {
                    Text("취소")
                }
                
                Button {
                    imageModel.imageList.removeAll()
                    naviManager.popToRoot()
                } label: {
                    Text("나가기")
                }
                
            } message: {
                Text("종료 시 편집된 내용은 저장되지 않습니다.")
            }
            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
            
            Spacer(minLength: UIScreen.main.bounds.width / 20)
            
            Spacer()
                .frame(width: 150)
            Button {
                
                
                
                if let image = frameManager.resultImage {
                    
                    imageModel.imageList.forEach {
                        $0.isTapped = false
                    }
                    
                    viewModel.saveStateText = "저장 중입니다..."
                    viewModel.isPushedSaveBtn = true
                    
                    if let _  = frameManager.selectedFrame {
                        viewModel.updateImage(view: imageView, frameManager: frameManager, viewContext: managedContext) {
                            
                            viewModel.btnOpacity = 0
                            viewModel.showCamera = true
                            imageModel.imageList.removeAll()
                            frameManager.resultImage = viewModel.frameImage
                            frameManager.selectedFrame = nil
                        }
                    } else {
                        
                        viewModel.saveImage(view: imageView, inputImage: image, context: managedContext) {
                            
                            viewModel.btnOpacity = 0
                            viewModel.showCamera = true
                            imageModel.imageList.removeAll()
                            frameManager.resultImage = viewModel.frameImage
                        }
                    }
                    
                    
                } else {
                    viewModel.saveStateText = "저장할 이미지가 없습니다."
                    Task {
                        viewModel.btnOpacity = 1
                        try await Task.sleep(for: .seconds(1))
                        viewModel.btnOpacity = 0
                    }
                }
                
            } label: {
                Text("저장")
                    .fontWeight(.semibold)
                    .foregroundStyle(isFirstLaunching ? .gray01 : .pointPink)
                    .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
            }
            .padding(.leading, 1)
            .disabled(viewModel.isPushedSaveBtn)
            
        }
    }
}
