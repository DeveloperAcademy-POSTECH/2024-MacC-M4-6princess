//
//  CameraFrameSelectView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/13/24.
//

import SwiftUI
import PhotosUI
import CoreData

struct CameraFrameSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: CameraViewModel
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.order, ascending: true)],
        animation: .default
    ) private var storedImages: FetchedResults<StoreImages>
    @State var imageDataArray: [(id: UUID, data: Data)] = []
    @State private var isShowPhotosPicker: Bool = false
    @State private var isEditing: Bool = false
    @State private var selectedImageIds: Set<UUID> = []
    @Binding var frameImage: UIImage?
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    SheetTitleView(isEditing: $isEditing, imageDataArray: $imageDataArray)
                    
                    //                    if !imageDataArray.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                            NavigationLink {
                                PhotosPickerView()
                            } label: {
                                VStack(alignment: .center, spacing: 4) {
                                    Spacer()
                                    Image("plusIcon")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                    Text("새로운\n프레임 만들기")
                                        .font(.system(size: 13))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 200)
                                .background(Color(red: 0.83, green: 0.83, blue: 0.83))
                            }
                            .onTapGesture {
//                                viewModel.isFullScreenPop.toggle()
                                viewModel.isShowMFView.toggle()
                                dismiss()
                            }
                            .disabled(isEditing)
                            
                            ForEach(imageDataArray.reversed(), id: \.id) { imageInfo in
                                ZStack(alignment: .topTrailing) {
                                    Button {
                                        if isEditing {
                                            toggleSelection(for: imageInfo.id)
                                        } else {
                                            viewModel.selectedFrame = imageInfo.id
                                            viewModel.isFrameLoading = true
                                            dismiss()
                                        }
                                    } label: {
                                        if let uiImage = UIImage(data: imageInfo.data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * (598 / 375))
                                                .clipped()
                                        }
                                    }
                                    .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * (598 / 375))
                                    
                                    if isEditing {
                                        Image(selectedImageIds.contains(imageInfo.id) ? "frameCheckIcon" : "")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .background(Circle().fill(Color.gray03))
                                            .padding(.trailing, 10)
                                            .padding(.top, 10)
                                    }
                                }
                            }
                        }
                    }
                    
                }
                if isEditing {
                    HStack(spacing: 10) {
                        Button {
                            //프레임 수정 뷰로 향하도록 수정
                        } label: {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 164, height: 60)
                                    .background(selectedImageIds.count > 1 ? .gray03 : .pointPink)
                                    .cornerRadius(10)
                                Text("수정하기")
                                    .font(.system(size: 17))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        Button {
                            deleteSelectedImages()
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
        }
        .onChange(of: storedImages.count) {
            // CoreData에 변화가 있을 때만 이미지 로드
            loadImages()
        }
        .onAppear {
            // 처음 한 번만 로드
            if imageDataArray.isEmpty {
                loadImages()
            }
        }
        .fullScreenCover(isPresented: $isShowPhotosPicker) {
            PhotosPickerView().onAppear {
                viewModel.isShowMFView.toggle()
//                viewModel.isFullScreenPop.toggle()
            }
        }
    }
    
    private func loadImages() {
        imageDataArray = storedImages.compactMap { storeImage -> (id: UUID, data: Data)? in
            guard let imageData = storeImage.image,
                  let id = storeImage.uuid,
                  let uiImage = UIImage(data: imageData),
                  let downsampledImage = downsampleImage(uiImage, to: CGSize(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * (598 / 375))) else {
                return nil
            }
            return (id: id, data: downsampledImage.jpegData(compressionQuality: 0.5) ?? imageData)
        }
    }
    
    private func downsampleImage(_ image: UIImage, to pointSize: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let data = image.jpegData(compressionQuality: 1.0),
              let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * UIScreen.main.scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    private func toggleSelection(for id: UUID) {
        if selectedImageIds.contains(id) {
            selectedImageIds.remove(id)
        } else {
            selectedImageIds.insert(id)
        }
    }
    
    private func deleteSelectedImages() {
        viewContext.performAndWait {
            for id in selectedImageIds {
                if let imageToDelete = storedImages.first(where: { $0.uuid == id }) {
                    viewContext.delete(imageToDelete)
                }
            }
            try? viewContext.save()
        }
        loadImages()
        selectedImageIds.removeAll()
        isEditing = false
    }
}

struct SheetTitleView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isEditing: Bool
    @Binding var imageDataArray: [(id: UUID, data: Data)]
    
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Spacer()
                Text("프레임")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                Spacer()
            }
            HStack(alignment: .center) {
                Button {
                    dismiss()
                } label: {
                    Image("xIcon")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 8)
                }
                Spacer()
                if !imageDataArray.isEmpty {
                    Button {
                        isEditing.toggle()
                    } label: {
                        Text(isEditing ? "취소" : "편집")
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


