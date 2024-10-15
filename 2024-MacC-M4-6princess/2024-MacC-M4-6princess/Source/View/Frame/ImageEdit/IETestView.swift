//
//  IETestView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/15/24.
//

import SwiftUI

struct IETestView: View {
    var img:UIImage
    var body: some View {
        VStack{
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
        }
    }
}

