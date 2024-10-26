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
    @StateObject var viewModel = IEViewModel()
    var body: some View {
        VStack {
            ZStack{
                if !viewModel.saveAnimate{
                    IEMainView(bg: bg, idol: idol, viewModel: viewModel)
                    //                Image(uiImage: bg)
                    //                    .resizable()
                    
                    if !isMain{ // 온보딩
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
                else{ // 저장시 애니매이션 뷰
                    IEProgressView(isSave: $viewModel.savePhoto)
                }
            }
        }
        
    }
    
}
