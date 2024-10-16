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
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.order, ascending: true)],
        animation: .default)
    private var storedImages: FetchedResults<StoreImages>
    @State private var imageDataArray: [(id: UUID, data: Data)] = []
    @Binding var isFullScreenPop: Bool
    @Binding var selectedFrame: UUID?
    @State private var isShow: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 제목을 상단에 배치
                SheetTitleView()
                
                if !imageDataArray.isEmpty {
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
                                .background(Color(red: 0.83, green: 0.83, blue: 0.83))
                            }.onTapGesture {
                                isFullScreenPop.toggle()
                            }
                            ForEach(imageDataArray.reversed(), id: \.id) { imageInfo in
                                Button {
                                    selectedFrame = imageInfo.id
                                    dismiss()
                                } label: {
                                    if let uiImage = UIImage(data: imageInfo.data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: UIScreen.main.bounds.width / 3,
                                                   height: (UIScreen.main.bounds.width / 3) * (598 / 375))
                                            .clipped()
                                    } else {
                                        Color.gray
                                            .frame(width: 150, height: 150) // 크기 설정
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    Spacer()
                    NavigationLink {
                        PhotosPickerView()
                    } label: {
                        VStack(alignment: .center, spacing: 4) {
                            Image("plusIcon")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .center)
                            Text("앗! 내가 만든 프레임이 없어요!\n화면을 클릭해서 새로운 프레임을 만들어주세요!")
                                .font(.system(size: 17))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                        }
                    }.onTapGesture {
                        dismiss()
                        isFullScreenPop.toggle()
                    }
                    
                    Spacer()
                }
            }.onAppear {
                loadImages()
            }
        }
        .fullScreenCover(isPresented: $isShow) {
            PhotosPickerView()
        }
    }
    
    //프레임 불러오는 함수
    private func loadImages() {
        imageDataArray = storedImages.compactMap { storeImage in
            guard let imageData = storeImage.image, let id = storeImage.uuid else { return nil }
            return (id: id, data: imageData)
        }
    }
}

//모달 상단 타이틀 뷰
struct SheetTitleView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image("xIcon")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .padding(.leading, 8)
            }
            
            Spacer()
            Text("편집")
                .font(
                    Font.custom("SF Pro", size: 17)
                        .weight(.semibold)
                )
                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                .padding(.horizontal, 20)
                .padding(.vertical, 10.49618)
        }
        
    }
}
