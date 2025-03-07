//
//  MFView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/13/24.
//

import SwiftUI
import PhotosUI
import CoreData
import FirebaseAnalytics

struct MFView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var viewModel: MFViewModel
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    
    var body: some View {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    SheetTitleView(viewModel: viewModel)
                    ScrollView {
                        FrameGridItem(viewModel: viewModel)
                    }
                    
                }
                if viewModel.isEditing {
                    HStack(spacing: 10) {
                        Button {
                            viewModel.imageDataArray.forEach {
                                if $0.id == viewModel.selectedImageIds.first {
                                    viewModel.selectFrame(id: $0.id)
                                    Task {
                                        loadSelectedFrame() {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                naviManager.push(screen: Screen.modifyFrame)
                                            })
                                        }
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 164, height: 60)
                                    .background(viewModel.selectedImageIds.count > 1 ? .gray03 : .pointPink)
                                    .cornerRadius(10)
                                Text("수정하기")
                                    .font(.system(size: 17))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(viewModel.selectedImageIds.count > 1)
                        Button {
                            
                            viewModel.isDeleteAlert = true
                        } label: {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.white)
                                    .frame(width: 164, height: 60)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .inset(by: 1)
                                            .stroke(.pointPink, lineWidth: 2)
                                    )
                                Text("삭제하기")
                                    .font(.system(size: 17))
                                    .foregroundColor(.pointPink)
                                    .fontWeight(.bold)
                            }
                        }
                        
                    }
                    .background {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: UIScreen.main.bounds.width, height: 130)
                            .background(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: .white.opacity(0), location: 0.00),
                                        Gradient.Stop(color: .white, location: 0.30),
                                        Gradient.Stop(color: .white, location: 1.00),
                                    ],
                                    startPoint: UnitPoint(x: 0.5, y: 0),
                                    endPoint: UnitPoint(x: 0.5, y: 1)
                                )
                            )
                    }
                }
            }
            .onAppear {
                viewModel.loadImages()
            }
            .alert("\(viewModel.selectedImageIds.count)개의 프레임을 삭제할까요?", isPresented: $viewModel.isDeleteAlert) {
                Button {
                    viewModel.deleteSelectedImages()
                } label: {
                    Text("삭제")
                        .font(.system(size: 17))
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
                
                Button("취소", role: .cancel) { }
            } message: {
                Text("프레임을 삭제하면 다시 되돌릴 수 없습니다.")
            }
        .onAppear{
            Analytics.logEvent("A2_프레임관리", parameters: nil)
        }
        
//        .fullScreenCover(isPresented: $viewModel.isShowPhotosPicker) {
//            PhotosPickerView()
//        }
        .navigationBarHidden(true)
    }
        
}


// MARK: - 프레임관리 상단바 커스텀

struct SheetTitleView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MFViewModel
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Spacer()
                Text("프레임 관리")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(.gray01)
                Spacer()
            }
            HStack(alignment: .center) {
                Button {
                    dismiss()
                } label: {
                    Image("chevronLeft")
                        .resizable()
                        .frame(width: 37, height: 40)
                        .padding(.leading, 10)
                }
                Spacer()
                if !viewModel.imageDataArray.isEmpty {
                    Button {
                        viewModel.isEditing.toggle()
                    } label: {
                        Text(viewModel.isEditing ? "취소" : "편집")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(.gray01)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10.49618)
                    }
                }
            }
            .padding(.vertical, 20)
        }
        
    }
}


// MARK: - 그리드 분리
struct FrameGridItem: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: MFViewModel
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
//            Button {
//                naviManager.push(screen: Screen.photoPicker)
//                Analytics.logEvent("A2_새로운프레임만들기", parameters: nil)
//            } label: {
//                ZStack {
//                    VStack(alignment: .center, spacing: 4) {
//                        Image("newFrameCreateLogo")
//                            .resizable()
//                            .frame(width: 80, height: 92)
//                            .padding(.top, 20)
//                            .padding(.bottom, 3)
//                        Text("최애 프레임\n만들기")
//                            .font(.system(size: 13, weight: .bold))
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.white)
//                        Spacer()
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(minHeight: 163)
//                    .background(.pointPink)
//                    
//                    if viewModel.isEditing {
//                        Rectangle()
//                            .frame(maxWidth: .infinity)
//                            .frame(minHeight: 163)
//                            .background(.black)
//                            .opacity(0.7)
//                    }
//                }
//            }
//            .disabled(viewModel.isEditing)
            
            ForEach(viewModel.imageDataArray.reversed(), id: \.id) { imageInfo in
                GridItemView(imageInfo: imageInfo, isSelected: viewModel.selectedImageIds.contains(imageInfo.id), viewModel: viewModel)
                    .id(imageInfo.id)
            }
        }
    }
    
}

// MARK: - 그리드 각각 분리

struct GridItemView: View {
    let imageInfo: (id: UUID, data: Data, isLoaded: Bool)
    let isSelected: Bool
    @ObservedObject var viewModel: MFViewModel
    @EnvironmentObject var frameManager: FrameManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = UIImage(data: viewModel.loadImageIfNeeded(for: imageInfo.id) ?? Data()) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width / 3,
                           height: (UIScreen.main.bounds.width / 3) * (4 / 3))
                    .clipped()
            }
            
            if viewModel.isEditing {
                Image(isSelected ? "frameCheckIcon" : "")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.gray03))
                    .padding(.trailing, 10)
                    .padding(.top, 10)
            }
        }
        .onTapGesture {
//            if !viewModel.isEditing {
//                viewModel.toggleSelection(for: imageInfo.id)
//                Analytics.logEvent("A2_프레임선택", parameters: nil)
//                dismiss()
//            }else {
                viewModel.toggleSelection(for: imageInfo.id)
//            }
        }
    }
}

