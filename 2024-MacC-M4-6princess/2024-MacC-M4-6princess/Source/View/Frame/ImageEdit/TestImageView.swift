//
//  TestImageView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/17/24.
//

import SwiftUI

struct TestImageView: View {
    var bg:UIImage
    var idol:UIImage
    var body: some View {
        VStack {
            // 배경 이미지
            
                Image(uiImage: bg)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            
            // 아이돌 이미지
            Image(uiImage: idol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:100)
               
            
        }
    }
}

