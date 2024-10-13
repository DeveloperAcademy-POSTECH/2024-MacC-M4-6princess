//
//  CameraTakepicCountView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/7/24.
//

import SwiftUI

//sprint2에 사용합니다
struct CameraTakepicCountView: View {
    @Binding var takePicCount: Int
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Button {
                self.takePicCount = 1
                print("지금부터 1컷의 사진이 연속으로 촬영됩니다.")
            } label: {
                Text("1번 촬영")
            }
            Button {
                self.takePicCount = 2
                print("지금부터 2컷의 사진이 연속으로 촬영됩니다.")
            } label: {
                Text("2번 촬영")
            }
            Button {
                self.takePicCount = 4
                print("지금부터 4컷의 사진이 연속으로 촬영됩니다.")
            } label: {
                Text("4번 촬영")
            }
            Button {
                self.takePicCount = 8
                print("지금부터 8컷의 사진이 연속으로 촬영됩니다.")
            } label: {
                Text("8번 촬영")
            }
        }
    }
}

#Preview {
    CameraTakepicCountView(takePicCount: .constant(1))
}
