//
//  DFFontStyle.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/21/24.
//

import SwiftUI

enum FontStyle: String {
    case modern = "HelveticaNeue"
    case handwriting = "SnellRoundhand"
    case bold = "Bold" // 시스템 기본 볼드체
    
    var displayName: String {
        switch self {
            case .modern:
                return "모던체"
            case .handwriting:
                return "손글씨체"
            case .bold:
                return "볼드체"
        }
    }
}

extension FontStyle: CaseIterable {
    func swiftUIFont(size: CGFloat) -> Font {
        switch self {
        case .modern:
            return .system(size: size, weight: .regular) // 시스템 폰트
        case .handwriting:
            return .custom("Helvetica", size: size) // 헬베티카 폰트
        case .bold:
            return .system(size: size, weight: .bold) // 시스템 기본 볼드체
        }
    }
}

struct ColorPreset {
    static let colorPallete: [Color] = [
        Color.black,
        Color.white,
        Color.redStrong,
        Color.redLight,
        Color.orangeStrong,
        Color.orangeLight,
        Color.yellowStrong,
        Color.yellowLight,
        Color.yellowGreenStrong,
        Color.yellowGreenLight,
        Color.greenStrong,
        Color.greenLight,
        Color.deepGreenStrong,
        Color.deepGreenLight,
        Color.mintStrong,
        Color.mintLight,
        Color.skyBlueStrong,
        Color.skyBlueLight,
        Color.blueStrong,
        Color.blueLight,
        Color.purpleStrong,
        Color.purpleLight,
    ]
}

extension Color {
    
    // 비활성화 된 버튼 색깔
    static let inactiveBrown = Color(hex: "#EBD7BD")
    // 활성화 된 버튼, 로고 색깔
    static let activeBrown = Color(hex: "#A2845E")
    // 초록색 텍스트 색깔
    static let textGreen = Color(hex: "#26980A")
    // 갈색 텍스트 색깔
    static let textBrown = Color(hex: "#4F2E05")
    // 회색 텍스트 색깔
    static let textGray = Color(hex: "#757575")
    // 앱 배경 색깔
    static let bgColor = Color(hex: "#FFFBF6")
    // shadow 색깔
    static let shadowGray = Color(hex: "#B1B1B1").opacity(0.5)
    // delete button colro
    static let redDark = Color(hex: "#E32B21")
    
    
    /// Color Pallete
    static let black = Color(hex: "000000")
    static let white = Color(hex: "FFFFFF")
    static let redStrong = Color(hex: "E10000")
    static let redLight = Color(hex: "F68383")
    static let orangeStrong = Color(hex: "FF5C00")
    static let orangeLight = Color(hex: "FFAF82")
    static let yellowStrong = Color(hex: "FFCC00")
    static let yellowLight = Color(hex: "FFE477")
    static let yellowGreenStrong = Color(hex: "CCE600")
    static let yellowGreenLight = Color(hex: "E2F261")
    static let greenStrong = Color(hex: "66B300")
    static let greenLight = Color(hex: "A9E55A")
    static let deepGreenStrong = Color(hex: "229100")
    static let deepGreenLight = Color(hex: "ACE39A")
    static let mintStrong = Color(hex: "00CC99")
    static let mintLight = Color(hex: "98F0DA")
    static let skyBlueStrong = Color(hex: "00E0F3")
    static let skyBlueLight = Color(hex: "95EBF2")
    static let blueStrong = Color(hex: "0040B3")
    static let blueLight = Color(hex: "82AEFF")
    static let purpleStrong = Color(hex: "8200FF")
    static let purpleLight = Color(hex: "C4A3E3")
    
    
    
    
}
