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
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    @EnvironmentObject var layerListViewModel: LayerListViewModel
    @StateObject var viewModel: MFViewModel
    
    init() {
            _viewModel = StateObject(wrappedValue: MFViewModel(context: PersistenceController.shared.container.viewContext))
        }
    
    var body: some View {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    SheetTitleView(viewModel: viewModel)
                        .environmentObject(frameManager)
                        .environmentObject(naviManager)
                        .environmentObject(layerListViewModel)
                    ScrollView {
                        FrameGridItem(viewModel: viewModel)
                            .environmentObject(frameManager)
                            .environmentObject(naviManager)
                            .environmentObject(layerListViewModel)
                    }
                    
                }
                if viewModel.isEditing {
                    HStack(spacing: 10) {
                        Button {
                            viewModel.isDeleteAlert = true
                        } label: {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.pointPink)
                                    .frame(height: 60)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 20)
                                    
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .inset(by: 1)
//                                            .stroke(.pointPink, lineWidth: 2)
//                                    )
                                Text("프레임 삭제")
                                    .font(.system(size: 17))
                                    .foregroundColor(.white)
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
            .fullScreenCover(isPresented: $viewModel.isShowMFDetailView) {
                MFDetailView()
                    .environmentObject(frameManager)
            }
        .onAppear{
            Analytics.logEvent("A2_프레임관리", parameters: nil)
        }
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
                Text("프레임 관리")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(.gray01)
            }
            .frame(height: 80)
            
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
//                        viewModel.isEditing.toggle()
                        if viewModel.isEditing {
                            viewModel.isEditing = false
                        } else {
                            viewModel.isEditing = true
                        }
                    } label: {
                        Text(viewModel.isEditing ? "취소" : "편집")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(.gray01)
                            .padding(.trailing, 20)
                    }
                }
            }
            .frame(height: 80)
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
            ForEach(viewModel.imageDataArray.reversed(), id: \.id) { imageInfo in
                GridItemView(imageInfo: imageInfo, isSelected: viewModel.selectedImageIds.contains(imageInfo.id), viewModel: viewModel)
                    .environmentObject(frameManager)
                    .environmentObject(naviManager)
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
    @EnvironmentObject var naviManager: NavigationManager
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
//            frameManager.toggleSelection(for: imageInfo.id, in: viewModel)
            frameManager.selectedFrameIdForDetail = imageInfo.id
            if !viewModel.isEditing {
                viewModel.selectedImageIds = [imageInfo.id]
                viewModel.isShowMFDetailView = true
//                naviManager.push(screen: Screen.manageDetailFrame)
                Analytics.logEvent("A2_프레임선택", parameters: nil)
            } else {
                viewModel.selectedImageIds.insert(imageInfo.id)
            }
        }
//        .onTapGesture {
//            if !viewModel.isEditing {
//                //MFDetailView로 이동
//                MFView().toggleSelection(for: imageInfo.id)
//                viewModel.isShowMFDetailView = true
//                naviManager.push(screen: Screen.manageDetailFrame)
//                Analytics.logEvent("A2_프레임선택", parameters: nil)
////                dismiss()
//            }else {
//                MFView().toggleSelection(for: imageInfo.id)
//            }
//        }
        
    }
}

