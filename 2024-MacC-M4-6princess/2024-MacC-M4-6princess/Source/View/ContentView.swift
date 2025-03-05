//
//  ContentView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var frameManager: FrameManager
    @ObservedObject var layerListViewModel = LayerListViewModel()
    @ObservedObject var imageModel = ImageListModel()
     
    var body: some View {
        MainTabView()
            .environmentObject(frameManager)
//        CameraView()
//            .environmentObject(imageModel)
            
    }
}

//#Preview {
//    ContentView()
//}
