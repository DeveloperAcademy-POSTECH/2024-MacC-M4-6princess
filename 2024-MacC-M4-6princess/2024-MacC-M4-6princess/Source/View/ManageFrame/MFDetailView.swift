//
//  MVDetailView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 3/13/25.
//

import SwiftUI
import CoreData

struct MFDetailView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    @EnvironmentObject var naviManager: NavigationManager
    @ObservedObject private var viewModel: MFDetailViewModel = MFDetailViewModel()
    
    var topBar : some View {
        ZStack{
            HStack(alignment: .center){
                Button {
                    naviManager.pop()
                    frameManager.selectedFrameIdForDetail = nil
                } label: {
                    Image("chevronLeft")
                        .resizable()
                        .frame(width: 37, height: 40)
                        .padding(.leading, 10)
                }
                Spacer()
            }
//            .frame(height: 60)
            
            HStack(alignment: .center) {
                Text("\(viewModel.indexOfSelectedImage() ?? 0) / \(viewModel.totalImageCount())")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray01)
            }
//            .frame(height: 60)
            
        }
    }
    
    var bottomBar : some View {
        VStack {
            HStack(spacing: 56) {
                VStack {
                    Button {
                        //카메라뷰로 이동
                        frameManager.selectedFrame = viewModel.selectedImageId
                        if let imageData = viewModel.loadOriginalImageData(),
                               let uiImage = UIImage(data: imageData) {
                                frameManager.resultImage = uiImage
                            }
                        naviManager.pop()
                        //카메라뷰로 갈 때 frameManager.resultImage에 탭한 UIImage 넘겨주어야함
                    } label: {
                        Image("ToolIconCamera")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    Text("사진촬영")
                        .font(.caption)
                        .foregroundStyle(.gray01)
                }
                VStack {
                    Button {
//                        frameManager.selectedFrame = viewModel.selectedImageId
                        frameManager.updateFrame = viewModel.selectedImageId
                        print("업데이트할 프레임 \(frameManager.updateFrame)")
                        loadSelectedFrame {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                naviManager.push(screen: Screen.modifyFrame)
                            }
                        }
                    } label: {
                        Image("ToolIconModify")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    Text("수정")
                        .font(.caption)
                        .foregroundStyle(.gray01)
                }
                VStack {
                    Button {
                        //삭제 함수
                        viewModel.isDeleteAlertDetail = true
                    } label: {
                        Image("ToolIconDelete")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    Text("삭제")
                        .font(.caption)
                        .foregroundStyle(.gray01)
                }
            }
            .frame(height: 102)
//            .padding(.top, 20)
        }
    }
    
    //    var bodyContentView: some View {
    //        if let selectedId = viewModel.selectedImageIds.first,
    //           let data = viewModel.loadOriginalImageData(for: selectedId),
    //           let uiImage = UIImage(data: data) {
    //            Image(uiImage: uiImage)
    //                .resizable()
    //                .aspectRatio(contentMode: .fit)
    //                .foregroundStyle(.white)
    //        } else {
    //            Image(systemName: "heart")
    //                .resizable()
    //                .aspectRatio(contentMode: .fit)
    //                .foregroundStyle(.white)
    //        }
    //    }
    var bodyContentView: some View {
            if let data = viewModel.loadOriginalImageData(), let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
            } else {
                Image(systemName: "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
            }
        }
    
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                topBar
                    .frame(width: geo.size.width, height: 80)
                bodyContentView
                bottomBar
            }
        }
//        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .alert("이 프레임을 삭제할까요?", isPresented: $viewModel.isDeleteAlertDetail) {
            Button {
                viewModel.deleteSelectedImage()
                {
//                    dismiss()
                }
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
        .onAppear {
            viewModel.configure(context: viewContext, selectedId: frameManager.selectedFrameIdForDetail)
        }
    }
}

extension MFDetailView {
    func loadSelectedFrame(completionHandler: @escaping () -> Void) {
        
        imageModel.imageList.removeAll()
        
        guard let frameId = frameManager.updateFrame else {
            frameManager.resultImage = nil
            return
        }
        
        let fetchRequest: NSFetchRequest<StoreImages> = StoreImages.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", frameId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            
            if let storedImage = results.first {
                
                getSubjects(storeImage: storedImage)
                
            } else {
                frameManager.resultImage = nil
            }
        } catch {
            print("Error fetching frame: \(error)")
            frameManager.resultImage = nil
        }
        completionHandler()
    }
    
    func getSubjects(storeImage: StoreImages) {
        
        let entity: StoreImages = storeImage
        
        if let subjects = entity.subjects?.allObjects as? [Subject] {
            
            for subject in subjects {
                
                let newImage = SubjectImage()
                
                if let image = subject.subImage, let originImage = subject.originalImage, let mask = subject.maskImage{
                    newImage.image = UIImage(data: image)
                    newImage.originalImage = UIImage(data: originImage)
                    newImage.maskImage = UIImage(data: mask)
                    
                } else if let text = subject.text, let originText = subject.originalText {
                    newImage.text = UIImage(data: text)
                    newImage.textStyle = TextStyle(attributedString: NSAttributedString(string: ""), txt: originText, font: .modern, color: ColorPreset.colorPallete[0], alignment: .center)
                } else if let sticker = subject.sticker {
                    newImage.sticker = UIImage(data: sticker)
                }
                
                newImage.scale = subject.scale
                newImage.angle = Angle.degrees(subject.angle)
                newImage.offset = CGSize(width: subject.x, height: subject.y)
                newImage.isTapped = false
                if subject == subjects.last {
                    newImage.isTapped = true
                }
                
                if newImage.image != nil {
                    print("이미지 있음!!")
                }
                
                imageModel.imageList.append(newImage)
            }
        }
        
    }
}
