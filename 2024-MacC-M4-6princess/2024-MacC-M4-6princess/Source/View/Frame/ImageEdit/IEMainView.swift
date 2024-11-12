//
//  IEMainView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/15/24.
//
import SwiftUI
import Photos

// 이미지 편집 메인 화면
struct IEMainView: View {
    var bg:UIImage
    var idol:UIImage
    @StateObject var viewModel: IEViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @GestureState var pinchState = 1.0 // 핀치 제스쳐를 위한 State 변수
    
    var body: some View {
        ZStack{
            ZStack{
                //                 캔버스 뷰를 vetical center 정렬
                VStack{
                    Spacer()
                    // 후보정 레이어 편집 뷰
                    canvasView
                    //                        .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
                    Spacer()
                }
                //                canvasView
                //                    .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
                VStack{
                    Color.white
                        .frame(width:viewModel.frameBGSize.width,height:(UIScreen.main.bounds.height-viewModel.frameBGSize.height)/2+11)
                    Spacer()
                    Color.white
                        .frame(width:viewModel.frameBGSize.width,height:(UIScreen.main.bounds.height-viewModel.frameBGSize.height)/2)
                }
                .ignoresSafeArea(.all)
            }
            
            VStack{
                topBar()
                Spacer()
            }
            VStack{
                Spacer()
                // 편집 옵션 버튼들
                VStack{
                    Spacer()
                    RawImageButton()
                    if let idx = viewModel.selectedIndex {
                        ColorSlider(idx)
                    }
                }
                if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
                    bottomBarIphone()
                }
                else{
                    bottomBarIpad()
                }
            }
            /// 원본 보기 클릭시 1초간 "원본" 표시가 남
            if viewModel.showRawAlert{
                Image("rawImageAlert")
                    .frame(width: UIScreen.main.bounds.width/2,height: UIScreen.main.bounds.height/4)
            }
        }
        .onAppear{
            viewModel.bgImg = bg
            viewModel.idolImg = idol
        }
        // 상단 툴바
        .navigationBarBackButtonHidden()
    }
    
}

