//
//  DFFontStyle.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/21/24.
//

import SwiftUI
import UIKit
enum NewFontStyle: String, CaseIterable {
    case modern    = "Pretendard-Medium"
    case handwriting = "HakgyoansimGeurimilgiOTF-R" // 기본 핸드라이팅
    case bold      = "Pretendard-Bold"
    
    /// 로컬라이즈된 이름 반환
    var displayName: String {
        NSLocalizedString("font.\(self.key)", comment: "")
    }
    private var key: String { String(describing: self) }
    
    /// 실제 사용할 폰트 파일 이름을 언어별로 결정
    private var fontName: String {
        switch self {
        case .handwriting:
            // 현재 디바이스의 언어 코드 가져오기 (ex: "ko", "ja", "zh")
            let lang = Locale.preferredLanguages.first?.prefix(2) ?? "ko"
            switch lang {
            case "ja":
                return "Yomogi-Regular"  // ja-handwriting.ttf 를 Info.plist UIAppFonts 에 등록
            case "zh":
                return "NotoSerifTC-VariableFont_wght"  // zh-handwriting.ttf
            default:
                return rawValue          // 그 외엔 기본값
            }
        default:
            return rawValue
        }
    }
    
    /// UIKit용 UIFont 반환
    func applyFont(size: CGFloat) -> UIFont {
        UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
    }

    /// SwiftUI용 Font 반환
    func oldApplyFont(size: CGFloat) -> Font {
        .custom(fontName, size: size)
    }
}




struct ColorPreset {
    static let colorPallete: [Color] = [
        Color.white,
        Color.black,
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

extension Font {
    public static func registerFonts(fontName: String) {
        registerFont(bundle: Bundle.main , fontName: fontName, fontExtension: ".otf") //change according to your ext.
    }
    fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
        
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }
        
        var error: Unmanaged<CFError>?
        
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}
