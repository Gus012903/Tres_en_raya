import SwiftUI

enum Player: String {
    case x = "X"
    case o = "O"
    case none
    
    var color: Color {
        switch self {
        case .x: return .blue
        case .o: return .red
        case .none: return .clear
        }
    }
    
    mutating func toggle() {
        self = self == .x ? .o : .x
    }
}
