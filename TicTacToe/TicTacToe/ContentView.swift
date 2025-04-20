import SwiftUI

struct ContentView: View {
    @StateObject private var gameBoard = GameBoard()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tic Tac Toe")
                .font(.largeTitle)
                .bold()
                                
            
            statusText
            
            gameBoardView
                .padding()
            
            resetButton
                .padding(.bottom)
        }
        .padding(.top,-90)
    }
    
    private var statusText: some View {
        Group {
            if let winner = gameBoard.winner {
                if winner == .none {
                    Text("¡Empate!")
                        .font(.title)
                        .foregroundColor(.orange)
                } else {
                    Text("¡\(winner.rawValue) ha ganado!")
                        .font(.title)
                        .foregroundColor(winner.color)
                }
            } else {
                Text("Turno de: \(gameBoard.currentPlayer.rawValue)")
                    .font(.title)
                    .foregroundColor(gameBoard.currentPlayer.color)
            }
        }
    }
    
    private var gameBoardView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
            ForEach(0..<9, id: \.self) { index in
                CellView(player: gameBoard.cells[index],
                        isWinning: gameBoard.winningPositions?.contains(index) ?? false)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .onTapGesture {
                        gameBoard.makeMove(at: index)
                    }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
    
    private var resetButton: some View {
        Button(action: {
            withAnimation {
                gameBoard.reset()
            }
        }) {
            Text("Reiniciar Juego")
                .font(.title2)
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct CellView: View {
    let player: Player
    let isWinning: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
            
            if player != .none {
                Text(player.rawValue)
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(player.color)
                    .scaleEffect(isWinning ? 1.1 : 1.0)
                    .animation(isWinning ? .spring(response: 0.5, dampingFraction: 0.5) : .default, value: isWinning)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isWinning ? Color.yellow.opacity(0.3) : Color.clear)
        )
        .animation(.easeInOut, value: isWinning)
    }
}

#Preview {
    ContentView()
}
