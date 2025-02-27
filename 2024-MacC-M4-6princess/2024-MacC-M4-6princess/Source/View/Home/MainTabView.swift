//
//  MainTabView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 2/27/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var naviManager = NavigationManager()
    @StateObject private var frameManager = FrameManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    if selectedTab == 0 {
                        Image("homeIconFill")
                    } else {
                        Image("homeIcon")
                    }
                    Text("홈")
                }
                .tag(0)
                .onAppear { selectedTab = 0 }
            
            CameraView()
                .environmentObject(frameManager)
                .environmentObject(naviManager)
                .tabItem {
                    if selectedTab == 1 {
                        Image("cameraIconFill")
                    } else {
                        Image("cameraIcon")
                    }
                    Text("카메라")
                }
                .tag(1)
                .onAppear { selectedTab = 1 }
        }

        .environmentObject(frameManager)
        .environmentObject(naviManager)
        
        
    }
}

#Preview {
    MainTabView()
}
