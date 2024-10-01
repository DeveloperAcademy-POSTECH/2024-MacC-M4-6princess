//
//  IEMagnifyGestureView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/1/24.
//
import SwiftUI

struct IEMagnifyGestureTestView: View {
    @GestureState private var magnifyByGesture = 1.0 //Gesture와 연결하는 특수한 @State 변수
    @State private var magnifyBy = 1.0 // 확대/축소 상태를 관리
    
    var magnification: some Gesture {
        MagnificationGesture()
            .updating($magnifyByGesture) { value, gestureState, transaction in
                // value:드래그 동작에 대한 정보
                // gestureState:State 변수
                // transaction:Animation과 관련 타입
                gestureState = value
            }
            .onChanged { value in
                magnifyBy = value // 제스처로 확대/축소할 때 상태 업데이트
            }
    }
    
    var body: some View {
        ZStack {
            Image("포실핑")
                .resizable() // 이미지 크기를 조정할 수 있도록 함
                .scaledToFit() // 이미지 비율을 유지하며 프레임에 맞춤 -> frame 크기를 지정하기 전에 와야함
                .frame(width: 200) // 너비만 지정, 높이는 자동으로 맞춤
                .scaleEffect(magnifyBy) // 확대/축소 상태 반영
                .gesture(magnification) // 제스처 추가

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            magnifyBy += 0.1 // 확대
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                        }
                        
                        Button(action: {
                            magnifyBy = max(0.5, magnifyBy - 0.1) // 축소 (최소 0.5배)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                Text("scale: \(String(format: "%.1f", magnifyBy))")

            }
        }
    }
}

