//
//  ContentView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI

struct ContentView: View {
    let persistenceController = PersistenceController.shared
    @StateObject var frameManager = FrameManager()
    @StateObject var naviManager = NavigationManager()
//    @ObservedObject var layerListViewModel = LayerListViewModel()
    @ObservedObject var imageModel = ImageListModel()
//    @EnvironmentObject var imageModel: ImageListModel
//    @EnvironmentObject var layerListViewModel: LayerListViewModel
     
    var body: some View {
        MainTabView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(frameManager)
            .environmentObject(naviManager)
            .environmentObject(imageModel)
//            .environmentObject(layerListViewModel)
    }
}
//import SwiftUI
//
//struct ContentView: View {
//    @State var open = false
//    var body: some View {
//        ZStack{
//            VStack{
//                Spacer()
//                Text("이것은 테스트")
//                Button(action:{open.toggle()}){
//                    Text("버튼")
//                }
//                Spacer()
//            }
//            .background(Color.blue)
//            if open{
//                TextMainView()
//            }
//        }
//       
//    }
//}
//import SwiftUI
//
//struct TextMainView: View {
//    @State private var text = ""
//    @State private var isFocused = false
//    var body: some View {
//        ZStack {
//            Color.clear
//                .ignoresSafeArea()
//
//            VStack {
//                Spacer()
//
//                TextTestView(text: $text, isFocused: isFocused)
//                    .frame(height: 150)
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(10)
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        
//                        ForEach(NewFontStyle.allCases, id: \.self) { fontStyle in
//                            Text(fontStyle.displayName) // 한글 이름 표시
//                                .font(fontStyle.oldApplyFont(size: 18)) // 매칭된 영문 폰트 적용
//                                .padding(.horizontal,15)
//                                .padding(.vertical,6)
//                                .foregroundColor(.black)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .fill(Color.clear) // 선택 여부에 따라 배경색 설정
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .stroke(Color.black, lineWidth: 1) // 흰색 테두리
//                                        )
//                                )
//                                .onTapGesture {
////                                    viewModel.selectedFont = fontStyle
//                                }
//                        }
//                    }
//                    .padding(.horizontal,5)
//                }
//                .frame(width: 335)
//                .ignoresSafeArea(.keyboard, edges: .bottom)
//                Spacer()
//            }
//        }
//        // 키보드가 올라와도 레이아웃이 밀리지 않도록 설정
//        .ignoresSafeArea(.keyboard)
//        .onAppear {
//                   isFocused = true // 자동으로 키보드 열기
//               }
//               .onDisappear {
//                   isFocused = false // 뷰 사라질 때 키보드 닫기
//               }
//    }
//}
