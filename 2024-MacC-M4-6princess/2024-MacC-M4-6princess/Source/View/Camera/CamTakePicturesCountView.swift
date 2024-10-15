//
//  CameraTakepicCountView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/7/24.
//

import SwiftUI

//sprint2에 사용합니다
struct CameraTakePicturesCountView: View {
    @Binding var takePicCount: Int
    let takePicOptions = [1, 2, 4, 8]
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ForEach(takePicOptions, id: \.self) { count in
                Button {
                    self.takePicCount = count
                    print("지금부터 \(count)컷의 사진이 연속으로 촬영됩니다.")
                } label: {
                    Text("\(count)번 촬영")
                }
            }
        }
    }
}

#Preview {
    CameraTakePicturesCountView(takePicCount: .constant(1))
}
