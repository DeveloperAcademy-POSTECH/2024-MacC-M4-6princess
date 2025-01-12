import SwiftUI

enum Mode {
    case draw
    case eraser
    
    init?(rawValue: Int) {
        switch rawValue {
            case 0: self = .draw
            case 1: self = .eraser
            default: return nil
        }
    }
}

struct Line {
    var color: Color
    var points: [CGPoint]
    var mode: Mode
    var lineWidth: Double = 10.0
}
