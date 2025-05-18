//
//  DF+Text.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/22/24.
//

import Foundation
import SwiftUI

extension DFTextView{
    
    var swipeAlignmentGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                // 스와이프 감지
                if value.translation.width < 0 { // 왼쪽 스와이프
                    withAnimation {
                        viewModel.textAlignment = viewModel.computeNextAlignment(for: viewModel.textAlignment, direction: .left)
                    }
                } else if value.translation.width > 0 { // 오른쪽 스와이프
                    withAnimation {
                        viewModel.textAlignment = viewModel.computeNextAlignment(for: viewModel.textAlignment, direction: .right)
                    }
                }
            }
    }
    var newFontSelector: some View {
        // 폰트 선택 ScrollView
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                
                ForEach(NewFontStyle.allCases, id: \.self) { fontStyle in
                    Text(fontStyle.displayName) // 한글 이름 표시
                        .font(fontStyle.oldApplyFont(size: 18)) // 매칭된 영문 폰트 적용
                        .padding(.horizontal,15)
                        .padding(.vertical,6)
                        .foregroundColor(viewModel.selectedFont == fontStyle ? .black :.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.selectedFont == fontStyle ? Color.white : Color.clear) // 선택 여부에 따라 배경색 설정
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1) // 흰색 테두리
                                )
                        )
                        .onTapGesture {
                            viewModel.selectedFont = fontStyle
                        }
                }
            }
            .padding(.horizontal,5)
        }
        .frame(maxWidth:.infinity)
    }
    var colorSelector: some View {
        // fontColor 선택
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<viewModel.colorChip.count, id: \.self) { colorIndex in
                    Circle()
                        .frame(width: viewModel.colorNum == colorIndex ? 40 : 30)
                        .foregroundColor(viewModel.colorChip[colorIndex])
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1) // 흰색 테두리와 두께 설정
                        )
                        .onTapGesture {
                            viewModel.selectedColor = viewModel.colorChip[colorIndex]
                            withAnimation(.easeInOut(duration: 0.36)) {
                                viewModel.colorNum = colorIndex
                            }
                        }
                }
            }
            .padding(5)
        }
        .frame(width: 335)
    }
    
    var textTabBar: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let itemWidth = totalWidth / 3 - 10
            
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(Color.white)
                    .cornerRadius(10)
                    .opacity(0.5)
                
                HStack(spacing: 0) {
                    Text("Aa")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(width: itemWidth, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.tab == 0 ? Color.white : Color.clear)
                        )
                        .onTapGesture {
                            viewModel.tab = 0
                        }
                    
                    Image("df.colorChip")
                        .resizable()
                        .scaledToFit()
                        .padding(3)
                        .frame(width: itemWidth, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.tab == 1 ? Color.white : Color.clear)
                        )
                        .onTapGesture {
                            viewModel.tab = 1
                        }
                    
                    Image(viewModel.imageForAlignment(viewModel.textAlignment))
                        .resizable()
                        .scaledToFit()
                        .frame(width: itemWidth, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.tab == 2 ? Color.white : Color.clear)
                        )
                        .onTapGesture {
                            viewModel.tab = 2
                            viewModel.toggleTextAlignment()
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 40)
    }
    
    func imageToCoredata() {
        let newImage = SubjectImage()
        if let image = viewModel.renderedImage {
            newImage.text = image
            newImage.originalImage = image
            if let att = viewModel.attributedTxt{
                newImage.textStyle = TextStyle(attributedString: att, txt: viewModel.txt, font: viewModel.selectedFont, color: viewModel.selectedColor, alignment: viewModel.textAlignment)
            }
            else{
                
            }
            ///새로 추가한 이미지를 제외하고 모든 이미지의 선택을 해제합니다.
            imageModel.imageList.forEach {
                if $0.isTapped {
                    $0.isTapped = false
                }
            }
            imageModel.imageList.append(newImage)
            modiViewModel.selectedSubject = imageModel.imageList.last
            modiViewModel.selectedIndex = imageModel.imageList.indices.last
            modiViewModel.modelListControl(subject: imageModel.imageList[imageModel.imageList.count-1])
        } else {
            //TODO: 에러 처리 해야함
            print("Image not found")
        }
    }
}
extension DFTextModifyView{
    
    func imageToCoredata() {
        let newImage = SubjectImage()
        if let image = viewModel.renderedImage {
            newImage.text = image
            newImage.originalImage = image
            //                                newImage.rawText = style.rawText
            newImage.textStyle = modiViewModel.style
            if let uuid = frameManager.textUUID, let index = imageModel.imageList.firstIndex(where: {$0.id == uuid}){
                imageModel.imageList[index] = newImage
                modiViewModel.selectedIndex = index
                modiViewModel.selectedSubject = newImage
                modiViewModel.modelListControl(subject: imageModel.imageList[index])
            }
            else{
                /// 에러처리
                ///
            }
            ///새로 추가한 이미지를 제외하고 모든 이미지의 선택을 해제합니다.
            imageModel.imageList.forEach {
                if $0.isTapped {
                    $0.isTapped = false
                }
            }
        } else {
            //TODO: 에러 처리 해야함
            print("Image not found")
        }
    }
    var swipeAlignmentGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                // 스와이프 감지
                if value.translation.width < 0 { // 왼쪽 스와이프
                    withAnimation {
                        modiViewModel.style.alignment = viewModel.computeNextAlignment(for: modiViewModel.style.alignment, direction: .left)
                    }
                } else if value.translation.width > 0 { // 오른쪽 스와이프
                    withAnimation {
                        modiViewModel.style.alignment = viewModel.computeNextAlignment(for: modiViewModel.style.alignment, direction: .right)
                    }
                }
            }
    }
    
    var newFontSelector: some View {
        // 폰트 선택 ScrollView
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                
                ForEach(NewFontStyle.allCases, id: \.self) { fontStyle in
                    Text(fontStyle.displayName) // 한글 이름 표시
                        .font(fontStyle.oldApplyFont(size: 18)) // 매칭된 영문 폰트 적용
                        .padding(.horizontal,15)
                        .padding(.vertical,6)
                        .foregroundColor(viewModel.selectedFont == fontStyle ? .black :.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.selectedFont == fontStyle ? Color.white : Color.clear) // 선택 여부에 따라 배경색 설정
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1) // 흰색 테두리
                                )
                        )
                        .onTapGesture {
                            viewModel.selectedFont = fontStyle
                        }
                }
            }
            .padding(.horizontal,5)
        }
        .frame(maxWidth:.infinity)
    }
    var colorSelector: some View {
        // fontColor 선택
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<viewModel.colorChip.count, id: \.self) { colorIndex in
                    Circle()
                        .frame(width: viewModel.colorNum == colorIndex ? 40 : 30)
                        .foregroundColor(viewModel.colorChip[colorIndex])
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1) // 흰색 테두리와 두께 설정
                        )
                        .onTapGesture {
                            //                            style.color = viewModel.colorChip[colorIndex]
                            viewModel.selectedColor = viewModel.colorChip[colorIndex]
                            withAnimation(.easeInOut(duration: 0.36)) {
                                viewModel.colorNum = colorIndex
                            }
                        }
                }
            }
            .padding(5)
        }
        .frame(maxWidth:.infinity)
    }
    var textTabBar: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 335, height: 40)
                .background(.white)
                .cornerRadius(10)
                .opacity(0.5)
            
            HStack(spacing: 0) {
                Text("Aa")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(width: 105, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.tab == 0 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                    )
                    .onTapGesture {
                        viewModel.tab = 0
                    }
                    .frame(width: 105, height: 30)
                
                Group {
                    Image("df.colorChip")
                        .resizable()
                        .scaledToFit()
                        .padding(3)
                        .frame(width: 105, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.tab == 1 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                        )
                        .onTapGesture {
                            viewModel.tab = 1
                        }
                }
                .frame(width: 105, height: 30)
                
                Group {
                    Image(viewModel.imageForAlignment(modiViewModel.style.alignment))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 105, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.tab == 2 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                        )
                        .onTapGesture {
                            viewModel.tab = 2
                            viewModel.toggleTextAlignment() // 텍스트 정렬 변경 함수 호출
                        }
                }
                .frame(width: 105, height: 30)
                
            }
            .padding()
        }
        .frame(height: 40)
        .frame(maxWidth:.infinity)
        
    }
}
import SwiftUI

extension NSTextAlignment {
    init(_ alignment: TextAlignment) {
        switch alignment {
        case .leading:
            self = .left
        case .center:
            self = .center
        case .trailing:
            self = .right
        }
    }
}
extension UIColor {
    convenience init(color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1] // 기본값: 검정색
        self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}
