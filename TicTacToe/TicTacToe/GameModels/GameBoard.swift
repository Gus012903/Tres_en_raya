import Foundation

class GameBoard: ObservableObject {
    @Published var cells: [Player]
    @Published var currentPlayer: Player
    @Published var winner: Player?
    @Published var winningPositions: [Int]?
    
    private var lastMoveTime: Date?
    
    init() {
        cells = Array(repeating: .none, count: 9)
        currentPlayer = .x
    }
    
    func makeMove(at index: Int) {
        guard cells[index] == .none, winner == nil else { return }
        
        cells[index] = currentPlayer
        
        lastMoveTime = Date()
        NotificationManager.shared.cancelPendingNotification()
        
        if checkWinCondition() {
            winner = currentPlayer
            return
        }
        
        if checkDraw() {
            winner = Player.none
            return
        }
        
        currentPlayer.toggle()
    }
    
    func scheduleReminderNotification() {
            NotificationManager.shared.scheduleGameReminder(after: 60)
        }
    
    private func checkWinCondition() -> Bool {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // filas
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // columnas
            [0, 4, 8], [2, 4, 6]             // diagonales
        ]
        
        for pattern in winPatterns {
            if cells[pattern[0]] != .none &&
               cells[pattern[0]] == cells[pattern[1]] &&
               cells[pattern[1]] == cells[pattern[2]] {
                winningPositions = pattern
                return true
            }
        }
        
        return false
    }
    
    private func checkDraw() -> Bool {
        return !cells.contains(Player.none)
    }
    
    func reset() {
        cells = Array(repeating: .none, count: 9)
        currentPlayer = .x
        winner = nil
        winningPositions = nil
        lastMoveTime = nil
        NotificationManager.shared.cancelPendingNotification()
    }
}
