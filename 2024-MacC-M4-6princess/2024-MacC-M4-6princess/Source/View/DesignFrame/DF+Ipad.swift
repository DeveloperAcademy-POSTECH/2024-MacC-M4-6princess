//
//  DF+Ipad.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/28/24.
//

import SwiftUI

extension DFModifyView{
    var modifyIpad: some View{
        VStack {
            ZStack {
                Image("checkBox")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
                
                imageView
                    .onAppear {
                        if let list = imageModel.imageList.last {
                            if let _ = list.image {
                                viewModel.modelListControl(subject: imageModel.imageList[imageModel.imageList.count-1])
                            }
                        }
                    }
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .opacity(viewModel.btnOpacity)
                    .frame(width: 175, height: 38)
                    .overlay(Text("\(viewModel.saveStateText)").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
                if let selected = viewModel.selectedSubject,selected.isTapped{
                    newLayerIndicator
                }
            }
            .gesture(viewModel.backgroundGesture())
            .onTapGesture {
                viewModel.isTappedImage = false
                imageModel.imageList.forEach {
                    $0.isTapped = viewModel.isTappedImage
                }
            }
            .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
            DFImageDecoView(viewModel: viewModel)
            Spacer()
        }
        //        VStack {
        //            ZStack {
        //                Image("checkBox")
        //                    .resizable()
        //                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
        //                
        //                imageView
        //                
        //                RoundedRectangle(cornerRadius: 30)
        //                    .fill(Color.white)
        //                    .opacity(viewModel.btnOpacity)
        //                    .frame(width: 175, height: 38)
        //                    .overlay(Text("\(viewModel.saveStateText)").foregroundStyle(.black).font(.footnote).opacity(viewModel.btnOpacity))
        //                
        //            }
        //            .onTapGesture {
        //                
        //                imageModel.imageList.forEach {
        //                    $0.isTapped = false
        //                }
        //            }
        //            .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
        //            DFImageDecoView(viewModel: viewModel)
        //            Spacer()
        //        }
    }
}
