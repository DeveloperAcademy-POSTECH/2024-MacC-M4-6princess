//
//  HomeView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 2/27/25.
//

import SwiftUI
import FirebaseAnalytics

struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    @EnvironmentObject var layerListViewModel: LayerListViewModel
    @StateObject private var viewModel = HomeViewModel(context: PersistenceController.shared.container.viewContext)
    
    
    @State private var isFullScreenPresented = false
    var imageCache: [UUID: Data] = [:]
    var imageDataArray: [(id: UUID, data: Data, isLoaded: Bool)] = []
    
    var body: some View {
        VStack {
            HStack {
                Image("appLogo")
                    .frame(width: 100, height: 20)
//                    .padding(.top, 18)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            
            Image("homeViewBanner")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            //                Button {
            //                    // 프레임 만들기 페이지로 이동
            //                    isFullScreenPresented = true
            //                } label: {
            //                    HStack(alignment: .center) {
            //                        Text("프레임만들기")
            //                            .padding(.vertical, 20)
            //                            .foregroundStyle(Color.pointPink)
            //                            .font(.system(size: 16, weight: .semibold))
            //                    }
            //                    .frame(height: 60, alignment: .center)
            //                    .frame(maxWidth: .infinity)
            //                    .background(Color.pointPinkBG)
            //                    .cornerRadius(8)
            //                }
            //                .padding(.top, 20)
            //                .padding(.bottom, 37)
            //                .padding(.horizontal, 20)
            
            Button {
                //                    PhotosPickerView()
                naviManager.push(screen: Screen.photoPicker)
                
            } label: {
                HStack(alignment: .center) {
                    Text("프레임만들기")
                        .padding(.vertical, 20)
                        .foregroundStyle(Color.pointPink)
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(height: 60, alignment: .center)
                .frame(maxWidth: .infinity)
                .background(Color.pointPinkBG)
                .cornerRadius(8)
            }
            .padding(.top, 20)
            .padding(.bottom, 37)
            .padding(.horizontal, 20)
            
            VStack {
                HStack {
                    Text("내가 만든 프레임")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.gray01)
                    Spacer()
                    Button {
                        naviManager.push(screen: Screen.manageFrame)
                    } label: {
                        HStack(spacing: 0) {
                            Text("전체보기")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.gray01)
                            Image("chevronRight")
                            // 이미지 확인해서 테두리 여백 확인하기
                                .resizable()
                                .frame(width: 18, height: 18)
                        }
                    }
                    
                }
                .padding(.horizontal, 20)
                
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8), // 열 간격
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ],
                    spacing: 8 // 행 간격
                ) {
                    ForEach(viewModel.imageDataArray.reversed().prefix(6), id: \.id) { imageInfo in
                        HomeGridView(imageInfo: imageInfo,
                                     viewModel: viewModel)
                        .id(imageInfo.id)
                        .onTapGesture {
                            frameManager.selectedFrameIdForDetail = imageInfo.id // 선택한 이미지 ID 저장
                            print("이미지 아이디를 frameManager에 저장했어요")
                            naviManager.push(screen: Screen.detailFrame) // MFDetailView로 이동
                            print("디테일뷰를 푸시했어요")
                        }
                    }
                }
                .padding([.horizontal, .bottom], 20)
            }
            
            Spacer()
        }
        //            .fullScreenCover(isPresented: $isFullScreenPresented) {
        //                PhotosPickerView() // 풀스크린으로 표시할 뷰
        //            }
        .onAppear {
            viewModel.loadImages()
        }
//        .fullScreenCover(isPresented: $viewModel.isShowMFDetailView) {
//            if let selectedFrameId = frameManager.selectedFrame {
//                MFDetailView(viewModel: MFDetailViewModel(context: viewContext, selectedId: selectedFrameId))
//                    .environmentObject(frameManager)
//                    .environmentObject(imageModel)
//                    .environmentObject(naviManager)
//            }
//        }
    }
    
}

struct HomeGridView: View {
    let imageInfo: (id: UUID, data: Data, isLoaded: Bool)
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var frameManager: FrameManager
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = UIImage(data: self.viewModel.loadImageIfNeeded(for: imageInfo.id) ?? Data()) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 106, height: 138)
                    .cornerRadius(8)
                    .clipped()
            }
        }
//        .onTapGesture {
//            frameManager.selectedFrame = imageInfo.id
//            viewModel.isShowMFDetailView = true
//        }
    }
}
