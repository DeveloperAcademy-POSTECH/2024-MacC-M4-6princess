//
//  IOSNSView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 2/12/25.
//

import SwiftUI

struct IOSNSView: View {
    var body: some View {
        //여기에 들어가는 시트는 인스타,트위터 텍스트로 되어있는 버튼 각각
        HStack(spacing: 20) {
            Button("insta") {
                
            }
            .buttonStyle(.bordered)
            Button("X") {
                
            }
            .buttonStyle(.borderless)
        }
    }
}

#Preview {
    IOSNSView()
}
