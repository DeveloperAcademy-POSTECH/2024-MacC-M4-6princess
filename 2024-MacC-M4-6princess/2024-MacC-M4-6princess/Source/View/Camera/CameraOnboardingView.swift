//
//  CameraOnboardingView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/14/24.
//

import SwiftUI

struct CameraOnboardingView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack {
            ZStack {
                Text("최애와 사진을 찍기 위해\n프레임 선택하기")
                    .font(.system(size: 17))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                VStack(alignment: .leading){
                    Spacer()
                    
                    HStack {
                        VStack {
                            Image("handPointer")
                                .resizable()
                                .frame(width: 114, height: 114)
                                .padding(.bottom, 20)
                                
                            
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .cornerRadius(5)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.pointPink)
                                    
                                    Image("frameLoadWhite")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                                .padding(.bottom, 4)
                                .padding(.leading, -8)
                                
                                Text("불러오기")
                                    .font(.system(size: 13))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 35)
                                    .padding(.leading, -8)
                                
                            }
                            .onTapGesture {
                                viewModel.firstTime = true
                            }
                        }
                        .padding(.leading, -10)
                        Spacer()
                    }
                }
            }
            
            
        }.ignoresSafeArea(.all)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .background(.black)
            .opacity(0.8)
            
    }
}

