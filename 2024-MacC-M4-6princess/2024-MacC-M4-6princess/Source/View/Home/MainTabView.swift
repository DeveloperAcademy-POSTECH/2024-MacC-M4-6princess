//
//  MainTabView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 2/27/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var naviManager: NavigationManager
    @EnvironmentObject private var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    @EnvironmentObject var layerListViewModel: LayerListViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 1
    var tabBarHeight: CGFloat = 76
    
    var body: some View {
        NavigationStack(path: $naviManager.route) {
            ZStack(alignment: .bottom) {
                // 선택된 탭에 따라 뷰 전환
                Group {
                    if selectedTab == 0 {
                        HomeView()
                    } else {
                        CameraView()
                    }
                }
                .padding(.bottom, tabBarHeight)
                .environmentObject(naviManager)
                .environmentObject(frameManager)
                .environmentObject(imageModel)
                .environmentObject(layerListViewModel)
                
                CustomTabBar(selectedTab: $selectedTab)
            }
            .navigationDestination(for: Screen.self) { screen in
                FeatureView(type: screen)
            }
        }
        
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        
        VStack {
            HStack {
                
                TabBarButton(imageName: selectedTab == 0 ? "homeIconFill" : "homeIcon",
                             title: "홈",
                             isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                             .padding(.leading, 80)
                
                Spacer()
                
                TabBarButton(imageName: selectedTab == 1 ? "cameraIconFill" : "cameraIcon",
                             title: "카메라",
                             isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                             .padding(.trailing, 80)
                
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
