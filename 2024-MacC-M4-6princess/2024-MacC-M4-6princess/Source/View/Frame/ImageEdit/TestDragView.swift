//
//  TestDragView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/14/24.
//
import SwiftUI

struct TestDragView: View {
    @StateObject private var viewModel = TestDragViewModel()
    @GestureState private var startLocation: CGPoint? = nil
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.updateLocation(with: value.translation, startLocation: startLocation)
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? viewModel.location
            }
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: viewModel.idolImg)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: viewModel.idolWidth, height: viewModel.idolWidth * viewModel.idolRatio)
                .position(viewModel.location)
                .gesture(simpleDrag)
            
            VStack{
                Spacer()
                // 현재 좌표를 화면에 표시하는 텍스트
                Text("이미지 좌표: (\(Int(viewModel.location.x)), \(Int(viewModel.location.y)))")
                    
                    
            }
        }
    }
}
