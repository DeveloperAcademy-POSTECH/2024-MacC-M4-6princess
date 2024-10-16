//
//  IEDevelopView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/3/24.
//

import SwiftUI

struct IEDevelopView: View {
    @State private var showMagnifyGestureTestView = false
    @State private var showRatioChangeView = false
    @State private var showWidthFixView = false
    @State private var imageResizeView = false
    @State private var edit = false
    var body: some View {
        
        NavigationStack {
            VStack {
                Button(action:{
                    edit = true
                }
                ){
                    Text("test")
                }
            }
            .navigationDestination(isPresented: $edit){
                IEMainView(img: UIImage(named:"6princess")!)
            }
            
            
        }
    }
}
