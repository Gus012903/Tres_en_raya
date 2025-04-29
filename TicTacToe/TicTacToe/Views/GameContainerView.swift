import SwiftUI

struct GameContainerView: View {
    @ObservedObject var auth: AuthService
    @StateObject var game = GameBoard()
    @Environment(\.dismiss) private var dismiss
    @StateObject private var firestoreService = FirestoreService.shared
    let gameID: String
    
    var body: some View {
        NavigationStack {
            VStack {
                ContentView()
                    .environmentObject(game)
                
                // Muestra el código de invitación en la parte inferior
                if firestoreService.isHost {
                    VStack {
                        Text("Código de invitación:")
                            .font(.headline)
                        Text(gameID)
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        //.contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = gameID
                                }) {
                                    Label("Copiar", systemImage: "doc.on.doc")
                                }
                        // }
                    }
                    .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Salir") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .padding(.leading, 5)

                }
                // Botón de logout
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        firestoreService.leaveGame()
                        auth.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                firestoreService.listenToGameChanges(gameID: gameID)
            }
        }
    }
}


