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
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        VStack {
                            if selectedTab == 0 {
                                Image("homeIconFill")
                                    .frame(width: 24, height: 24)
                            } else {
                                Image("homeIcon")
                                    .frame(width: 24, height: 24)
                                
                            }
                            Text("홈")
                        }
                        .padding(.top, 13)
                        
                        
                    }
                    .tag(0)
                    .onAppear { selectedTab = 0 }
                
                CameraView()
                    .environmentObject(frameManager)
                    .environmentObject(naviManager)
                    .tabItem {
                        VStack{
                            if selectedTab == 1 {
                                Image("cameraIconFill")
                                    .frame(width: 24, height: 24)
                            } else {
                                Image("cameraIcon")
                                    .frame(width: 24, height: 24)
                            }
                            Text("카메라")
                        }
                        .padding(.top, 13)
                    }
                    .tag(1)
                    .onAppear { selectedTab = 1 }
            }
            .tint(Color.gray01)
            .environmentObject(frameManager)
            .environmentObject(naviManager)
            
            // 탭바 위쪽에 선 추가
            Rectangle()
                .fill(Color.gray10)
                .frame(height: 0.5)
                .edgesIgnoringSafeArea(.horizontal)
                .padding(.bottom, 56) // safeArea 고려해서 76->56으로 조정
        }
    }
}

#Preview {
    MainTabView()
}
