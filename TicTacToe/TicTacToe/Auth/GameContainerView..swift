import SwiftUI

struct GameContainerView: View {
    @ObservedObject var auth: AuthService
    @StateObject var game = GameBoard()
    
    var body: some View {
        NavigationStack {
            ContentView()
                .environmentObject(game)
                .toolbar {
                    // 1. Título alineado a la izquierda
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("TicTacToe")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.leading, 8)
                    }
                    
                    // 2. Botón de logout a la derecha
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            auth.logout()
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}


