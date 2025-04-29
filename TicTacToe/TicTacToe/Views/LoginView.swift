import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var auth: AuthService
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    
                    // Logo
                    Image("Image")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("Tic Tac Toe")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 2)
                    
                    
                    TextField("Email", text: $email)
                        .padding(.horizontal, 15)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                   
                    SecureField("Contraseña", text: $password)
                        .padding(.horizontal, 15)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    
                    if !auth.errorMessage.isEmpty {
                        Text(auth.errorMessage)
                            .foregroundColor(.red)
                            .bold()
                    }
                    
                   
                    Button(action: {
                        auth.login(email: email, password: password) { _ in }
                    }) {
                        Text("Iniciar Sesión")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                   
                    NavigationLink(destination: RegisterView(auth: auth)) {
                        Text("Crear Cuenta")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 50)
                .padding(.top, -100)
            }
        }
    }
}

#Preview {
    LoginView(auth: AuthService())
}
