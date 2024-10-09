//
//  ImageResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/4/24.
//
import SwiftUI

struct IEImageResizeView: View {
    var felix = "Felix"
    var princess = "6princess"
    var backgroundImage = UIImage(named: "6princess")!
    var idolImage = UIImage(named: "Felix")!
    var body: some View {
        IETestResizeView(backgroundImage: backgroundImage, idolImage: idolImage)
    }
    
    

}

