import SwiftUI

struct TextWithColoredSubstring: View {
    var originalText: String
    var coloredSubstring: String
    
    var body: some View {
        if let coloredRange = originalText.range(of: coloredSubstring) {
            let beforeRange = originalText[..<coloredRange.lowerBound]
            let coloredText = originalText[coloredRange]
            let afterRange = originalText[coloredRange.upperBound...]
            
            return Text(beforeRange)
                .foregroundColor(.white)
                + Text(coloredText)
                .foregroundColor(.pointPink)
                + Text(afterRange)
                    .foregroundColor(.white)
        } else {
            return Text(originalText)
                .foregroundColor(.white)
        }
    }
}
