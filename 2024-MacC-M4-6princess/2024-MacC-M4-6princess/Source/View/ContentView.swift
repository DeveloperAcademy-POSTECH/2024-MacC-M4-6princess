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
    @ObservedObject var layerListViewModel = LayerListViewModel()
    @ObservedObject var imageModel = ImageListModel()
//    @EnvironmentObject var imageModel: ImageListModel
//    @EnvironmentObject var layerListViewModel: LayerListViewModel
     
    var body: some View {
        MainTabView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(frameManager)
            .environmentObject(naviManager)
            .environmentObject(imageModel)
            .environmentObject(layerListViewModel)
    }
}

//#Preview {
//    ContentView()
//}
