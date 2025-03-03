//
//  MainTabView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 2/27/25.
//

import SwiftUI

//struct MainTabView: View {
//    @EnvironmentObject private var naviManager: NavigationManager
//    @EnvironmentObject private var frameManager: FrameManager
//    @Environment(\.managedObjectContext) private var viewContext
//    @State private var selectedTab = 1
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            TabView(selection: $selectedTab) {
//                HomeView()
//                    .tabItem {
//                        VStack {
//                            if selectedTab == 0 {
//                                Image("homeIconFill")
//                                    .frame(width: 24, height: 24)
//                            } else {
//                                Image("homeIcon")
//                                    .frame(width: 24, height: 24)
//
//                            }
//                            Text("홈")
//                        }
//                        .padding(.top, 13)
//
//
//                    }
//                    .tag(0)
//                    .onAppear { selectedTab = 0 }
//
//                CameraView()
//                    .environmentObject(frameManager)
//                    .environmentObject(naviManager)
//                    .tabItem {
//                        VStack{
//                            if selectedTab == 1 {
//                                Image("cameraIconFill")
//                                    .frame(width: 24, height: 24)
//                            } else {
//                                Image("cameraIcon")
//                                    .frame(width: 24, height: 24)
//                            }
//                            Text("카메라")
//                        }
//                        .padding(.top, 13)
//                    }
//                    .tag(1)
//                    .onAppear { selectedTab = 1 }
//            }
//            .tint(Color.gray01)
//            .environmentObject(frameManager)
//            .environmentObject(naviManager)
//
//            // 탭바 위쪽에 선 추가
//            Rectangle()
//                .fill(Color.gray10)
//                .frame(height: 0.5)
//                .edgesIgnoringSafeArea(.horizontal)
//                .padding(.bottom, 56) // safeArea 고려해서 76->56으로 조정
//        }
//    }
//}
//
//#Preview {
//    MainTabView()
//}

struct MainTabView: View {
    @EnvironmentObject private var naviManager: NavigationManager
    @EnvironmentObject private var frameManager: FrameManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 1
    var tabBarHeight: CGFloat = 76
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 선택된 탭에 따라 뷰 전환
            if selectedTab == 0 {
                HomeView()
                    .padding(.bottom, tabBarHeight) // 탭바 높이만큼 올리기
            } else {
                CameraView()
                    .environmentObject(frameManager)
                    .environmentObject(naviManager)
                    .padding(.bottom, tabBarHeight) // 탭바 높이만큼 올리기
            }
            
            // 커스텀 탭 바
            CustomTabBar(selectedTab: $selectedTab)
        }
        .environmentObject(frameManager)
        .environmentObject(naviManager)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                
                TabBarButton(imageName: selectedTab == 0 ? "homeIconFill" : "homeIcon",
                             title: "홈",
                             isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                Spacer()
                
                TabBarButton(imageName: selectedTab == 1 ? "cameraIconFill" : "cameraIcon",
                             title: "카메라",
                             isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                Spacer()
            }
            .padding(.top, 13)
            .background(
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 76)
                    .frame(maxWidth: .infinity)
            )
            .overlay(
                Rectangle()
                    .fill(Color.gray10)
                    .frame(height: 0.5)
                    .edgesIgnoringSafeArea(.horizontal),
                alignment: .top
                
            )
        }
        Rectangle()
            .fill(Color.gray10)
            .frame(height: 0.5)
            .edgesIgnoringSafeArea(.horizontal)
            .padding(.bottom, 56) // safeArea 고려해서 76->56으로 조정
    }
}

struct TabBarButton: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(imageName)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.gray01)
            }
        }
        
    }
}
