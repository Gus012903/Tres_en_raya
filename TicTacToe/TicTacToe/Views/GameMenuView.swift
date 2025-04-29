import SwiftUI

struct GameMenuView: View {
    @ObservedObject var auth: AuthService
    @StateObject var firestoreService = FirestoreService.shared
    @State private var inviteCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    Image("Image")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("Hola, \(auth.userName)!")
                        .font(.title)
                        .bold()
                    
                    
                    Button(action: createNewGame) {
                        Text("Crear Nueva Partida")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 50)
                    
                    
                    VStack(spacing: 15) {
                        Text("Unirse a una partida existente")
                            .font(.headline)
                        
                        TextField("Código de invitación", text: $inviteCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 50)
                        
                        Button(action: joinGame) {
                            Text("Unirse a Partida")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 50)
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        auth.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .navigationDestination(isPresented: .constant(firestoreService.currentGameID != nil)) {
                if let gameID = firestoreService.currentGameID {
                    GameContainerView(auth: auth, gameID: gameID)
                }
            }
        }
    }
    
    private func createNewGame() {
        guard let userID = auth.user?.uid else { return }
        
        firestoreService.createGame(userID: userID) { gameID in
            if gameID == nil {
                alertMessage = "No se pudo crear la partida. Intenta nuevamente."
                showAlert = true
            }
        }
    }
    
    private func joinGame() {
        guard !inviteCode.isEmpty else {
            alertMessage = "Ingresa un código de invitación"
            showAlert = true
            return
        }
        
        guard let userID = auth.user?.uid else { return }
        
        firestoreService.joinGame(gameID: inviteCode, userID: userID) { success in
            if !success {
                alertMessage = "No se pudo unir a la partida. Verifica el código."
                showAlert = true
            }
        }
    }
}
