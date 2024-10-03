//
//  IEMagnifyGestureView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/1/24.
//
import SwiftUI
//코드 이해가 아직 부족함,,,
struct IEMagnifyGestureTestView: View {
    @State private var scale = 1.0 // 전체 보기를 위한 초기 비율을 1.0으로 설정
    @State private var magnificationValue = 1.0 // 수동 확대/축소를 위한 상태 변수
    @GestureState private var magnification = 1.0 // 핀치 제스쳐를 위한 State 변수
    
    var magnificationGesture: some Gesture {
        MagnifyGesture()
            .updating($magnification) { value, gestureState, transaction in
                gestureState = value.magnification
            }
            .onEnded { value in
                self.scale *= value.magnification // 확대 제스처가 끝났을 때 스케일을 곱함
            }
    }
    
    var body: some View {
        ZStack {
            IERatioChangeTestView() // 이미지 대신 사용자 정의 뷰를 사용
                .scaleEffect(scale * magnification * magnificationValue) // 제스처와 수동 확대/축소를 결합
                .gesture(magnificationGesture)
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 뷰가 전체 화면을 차지하도록 설정
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            magnificationValue += 0.2 // 수동 확대를 위한 값 조정
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                        }
                        
                        Button(action: {
                            magnificationValue = max(0.5, magnificationValue * 0.8) // 최소 한계로 확대/축소 조정
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                Text("scale: \(String(format: "%.1f", magnificationValue))") // 현재 스케일 표시
            }
        }
    }
}
