import Foundation

struct GameState {
    var board: [String] = Array(repeating: "", count: 9)
    var currentPlayer: String = "X"
    var winner: String = ""
    
    mutating func update(board: [String], currentPlayer: String, winner: String) {
        self.board = board
        self.currentPlayer = currentPlayer
        self.winner = winner
    }
}
