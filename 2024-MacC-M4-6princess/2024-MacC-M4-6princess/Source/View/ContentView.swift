//
//  ContentView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI

struct ContentView: View {
    
//    @State private var inputImage: UIImage?
//    @StateObject var vm: DFFrameModifyViewModel = DFFrameModifyViewModel()
    @StateObject var imageModel: ImageListModel = ImageListModel()
    
    var body: some View {
        
        CameraView()
            .environmentObject(imageModel)
//        IEDevelopView()
        //        CMView()
        //        IEProgressView()
    }
}

//#Preview {
//    ContentView()
//}
