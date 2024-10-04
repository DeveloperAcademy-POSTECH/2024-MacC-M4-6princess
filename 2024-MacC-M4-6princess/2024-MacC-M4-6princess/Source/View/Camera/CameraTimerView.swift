//
//  CameraTimerView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/4/24.
//

import SwiftUI

struct CameraTimerView: View {
    @Binding var delayTime: Double
    var body: some View {
        HStack {
            Button {
                self.delayTime = 0
                print("0초 설정됨")
            } label: {
                Text("0초")
            }
            Button {
                self.delayTime = 3
                print("3초 설정됨")
            } label: {
                Text("3초")
            }
            Button {
                self.delayTime = 5
                print("5초 설정됨")
            } label: {
                Text("5초")
            }
            Button {
                self.delayTime = 7
                print("7초 설정됨")
            } label: {
                Text("7초")
            }
        }.background(Color.white)

    }
}

#Preview {
    CameraTimerView(delayTime: .constant(0))
}

