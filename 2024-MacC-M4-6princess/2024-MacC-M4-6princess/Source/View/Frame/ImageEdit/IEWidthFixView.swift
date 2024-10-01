//
//  IEWidthFixView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/1/24.
//

import SwiftUI

struct IEWidthFixView: View {
    var body: some View {
        Image("포실핑")
            .resizable() // 이미지 크기를 조정할 수 있도록 함
            .scaledToFit() // 이미지 비율을 유지하며 프레임에 맞춤
            .frame(maxWidth: .infinity) // 가로를 화면에 꽉 채움
    }
}

#Preview {
    IEWidthFixView()
}
