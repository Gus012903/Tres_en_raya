import Foundation
import FirebaseFirestore
import Combine

class GameBoard: ObservableObject {
    @Published var cells: [Player]
    @Published var currentPlayer: Player
    @Published var winner: Player?
    @Published var winningPositions: [Int]?
    @Published var isMyTurn: Bool = false
    
    private var lastMoveTime: Date?
    private var cancellables = Set<AnyCancellable>()
    private var gameID: String?
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        cells = Array(repeating: .none, count: 9)
        currentPlayer = .x
        
        FirestoreService.shared.$currentGameID
            .sink { [weak self] gameID in
                self?.gameID = gameID
                if let gameID = gameID {
                    self?.setupGameListener(gameID: gameID)
                } else {
                    self?.listener?.remove()
                    self?.reset()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupGameListener(gameID: String) {
        listener?.remove()
        
        listener = db.collection("games").document(gameID)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self,
                      let snapshot = snapshot,
                      snapshot.exists else { return }
                
                self.updateGameState(from: snapshot.data())
            }
    }
    
    private func updateGameState(from data: [String: Any]?) {
        guard let data = data else { return }
        
        if let boardData = data["board"] as? [String] {
            cells = boardData.map { Player(rawValue: $0) ?? .none }
        }
        
        if let currentPlayerData = data["currentPlayer"] as? String {
            currentPlayer = Player(rawValue: currentPlayerData) ?? .x
        }
        
        if let winnerData = data["winner"] as? String {
            winner = Player(rawValue: winnerData)
        } else {
            winner = nil
        }
        
        if let winningPositionsData = data["winningPositions"] as? [Int] {
            winningPositions = winningPositionsData
        } else {
            winningPositions = nil
        }
        
        updateTurnStatus()
        checkGameEndConditions()
    }
    
    private func updateTurnStatus() {
        guard gameID != nil else {
            isMyTurn = false
            return
        }
        
        let isHost = FirestoreService.shared.isHost
        isMyTurn = (isHost && currentPlayer == .x) || (!isHost && currentPlayer == .o)
    }
    
    func makeMove(at index: Int) {
        guard cells[index] == .none, winner == nil, isMyTurn else { return }
        guard let gameID = gameID else { return }
        
        cells[index] = currentPlayer
        lastMoveTime = Date()
        NotificationManager.shared.cancelPendingNotification()
        
        var board = cells.map { $0.rawValue }
        board[index] = currentPlayer.rawValue
        
        let nextPlayer = currentPlayer == .x ? Player.o : Player.x
        var updateData: [String: Any] = [
            "board": board,
            "currentPlayer": nextPlayer.rawValue
        ]
        
        if checkWinCondition() {
            winner = currentPlayer
            updateData["winner"] = currentPlayer.rawValue
            updateData["winningPositions"] = winningPositions
        } else if checkDraw() {
            winner = nil
            updateData["winner"] = Player.none.rawValue
        }
        
        db.collection("games").document(gameID).updateData(updateData)
    }
    
    private func checkGameEndConditions() {
        if winner == nil {
            if checkWinCondition() {
                winner = currentPlayer == .x ? .o : .x
            } else if checkDraw() {
                winner = nil
            }
        }
    }
    
    private func checkWinCondition() -> Bool {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
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
        return !cells.contains(.none) && winner == nil
    }
    
    func reset() {
        guard let gameID = gameID else {
            cells = Array(repeating: .none, count: 9)
            currentPlayer = .x
            winner = nil
            winningPositions = nil
            lastMoveTime = nil
            NotificationManager.shared.cancelPendingNotification()
            return
        }
        
        let resetData: [String: Any] = [
            "board": Array(repeating: "", count: 9),
            "currentPlayer": "X",
            "winner": "",
            "winningPositions": []
        ]
        
        db.collection("games").document(gameID).updateData(resetData)
    }
    
    func scheduleReminderNotification() {
        NotificationManager.shared.scheduleGameReminder(after: 60)
    }
    
    deinit {
        listener?.remove()
    }
}
