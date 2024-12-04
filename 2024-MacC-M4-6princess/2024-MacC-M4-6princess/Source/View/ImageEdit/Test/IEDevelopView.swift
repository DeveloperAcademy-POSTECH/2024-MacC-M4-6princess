//
//  IEDevelopView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/3/24.
//

import SwiftUI

struct IEDevelopView: View {
    
    var body: some View {
        
//        LayerLongPressView()
            
        
            HStack(spacing: 16) {
                
                Button(action: {
//                    showQRSheet = true
                }) {
                    RoundedRectangle(cornerRadius: 10) // RoundedRectangle을 사용
                        .stroke(Color.pointPink, lineWidth: 1) // 테두리 추가
                        .background(
                            RoundedRectangle(cornerRadius: 10) // 동일한 모서리 반경의 배경
                                .foregroundColor(.white)
                        )
                        .frame(height: 60) // 높이 설정
                        .overlay(
                            Text("QR 보기")
                                .foregroundColor(.pointPink)
                                .font(.system(size: 18, weight: .bold))
                        )
//                        .padding(.horizontal) // 좌우 여백
                }



                // 카메라로 이동 버튼
                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
                }) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 60)
                        .background(Color.pointPink)
                        .cornerRadius(10)
                        .overlay(
                            Text("카메라로 이동")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                        )
                }
//                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)

        
    }
}

#Preview {
    IEDevelopView()
}
