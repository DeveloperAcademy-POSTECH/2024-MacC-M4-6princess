//
//  ContentView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var layerListViewModel = LayerListViewModel()
    @ObservedObject var imageModel = ImageListModel()
     
    var body: some View {
        
        CameraView().environmentObject(imageModel)
//        SnsTestView()
//        IEDevelopView().environmentObject(layerListViewModel)
        
        //        CMView()
        //        IEProgressView()
    }
}

//#Preview {
//    ContentView()
//}
