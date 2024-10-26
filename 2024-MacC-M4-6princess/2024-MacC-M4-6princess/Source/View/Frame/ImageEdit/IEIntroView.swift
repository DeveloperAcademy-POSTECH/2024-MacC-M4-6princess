//
//  IEIntroView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/16/24.
//

import SwiftUI

struct IEIntroView: View {
    var bg: UIImage
    var idol: UIImage
    var splash = UIImage(named: "imageEditSplash")!
    @State var isMain = false
    
    var body: some View {
        VStack {
            ZStack{
                IEMainView(bg: bg, idol: idol)
//                Image(uiImage: bg)
//                    .resizable()
                    
                if !isMain{
                    Group{
                        Color.black.opacity(0.7)
                        Image(uiImage: splash)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                isMain = true
                            }
                    }
                    .ignoresSafeArea(.all)
                }
            }
        }
        
    }
    
}
