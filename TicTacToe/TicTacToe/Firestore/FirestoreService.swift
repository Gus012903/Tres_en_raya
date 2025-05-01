import FirebaseFirestore
import Combine

class FirestoreService: ObservableObject {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    @Published var currentGameID: String?
    @Published var opponentName: String?
    @Published var isHost = false
    @Published var currentGameState = GameState()
    
    private var listener: ListenerRegistration?
    
    private init() {}
    
    func createGame(userID: String, completion: @escaping (String?) -> Void) {
        let gameRef = db.collection("games").document()
        let gameID = gameRef.documentID
        
        let gameData: [String: Any] = [
            "host": userID,
            "guest": "",
            "currentPlayer": "X",
            "board": Array(repeating: "", count: 9),
            "winner": "",
            "created": Timestamp(date: Date())
        ]
        
        gameRef.setData(gameData) { [weak self] _ in
            guard let self = self else { return }
            self.currentGameID = gameID
            self.isHost = true
            self.listenToGameChanges(gameID: gameID)
            completion(gameID)
        }
    }
    
    func joinGame(gameID: String, userID: String, completion: @escaping (Bool) -> Void) {
        let gameRef = db.collection("games").document(gameID)
        
        gameRef.getDocument { [weak self] snapshot, _ in
            guard let self = self else { return }
            guard let snapshot = snapshot, snapshot.exists else {
                completion(false)
                return
            }
            
            let data = snapshot.data()
            let host = data?["host"] as? String ?? ""
            let guest = data?["guest"] as? String ?? ""
            
            if guest.isEmpty && host != userID {
                gameRef.updateData(["guest": userID]) { error in
                    if error == nil {
                        self.currentGameID = gameID
                        self.isHost = false
                        self.listenToGameChanges(gameID: gameID)
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    func listenToGameChanges(gameID: String) {
        listener = db.collection("games").document(gameID)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let snapshot = snapshot, snapshot.exists else { return }
                
                let data = snapshot.data()
                let board = data?["board"] as? [String] ?? []
                let currentPlayer = data?["currentPlayer"] as? String ?? "X"
                let winner = data?["winner"] as? String ?? ""
                
                DispatchQueue.main.async {
                    self?.currentGameState.update(board: board,
                                                  currentPlayer: currentPlayer,
                                                  winner: winner)
                }
            }
    }
    
    func makeMove(index: Int, player: Player, gameID: String, completion: ((Bool) -> Void)? = nil) {
        let gameRef = db.collection("games").document(gameID)
        
        let updateData: [String: Any] = [
            "board.\(index)": player.rawValue,
            "currentPlayer": player == .x ? "O" : "X"
        ]
        
        gameRef.updateData(updateData) { error in
            completion?(error == nil)
        }
    }
    
    func leaveGame() {
        listener?.remove()
        listener = nil
        currentGameID = nil
        opponentName = nil
        isHost = false
        currentGameState = GameState()
    }
}
