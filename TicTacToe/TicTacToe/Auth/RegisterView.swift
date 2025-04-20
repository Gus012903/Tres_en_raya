import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var auth: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPasswordError = false
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        email.contains("@") && email.contains(".") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    private var passwordError: String {
        if password.count > 0 && password.count < 6 {
            return "La contraseña debe tener al menos 6 caracteres"
        } else if !confirmPassword.isEmpty && password != confirmPassword {
            return "Las contraseñas no coinciden"
        }
        return ""
    }
    
    var body: some View {
        ZStack {
            // 1. Imagen de fondo
            Image("Background") // Asegúrate que coincida con el nombre en Assets
                .resizable()
                .scaledToFill()
                .opacity(0.1) // Ajusta la opacidad según necesites
                .edgesIgnoringSafeArea(.all)
            
            // 2. Contenido principal
            VStack(spacing: 16) {
                Text("Registro")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                    .foregroundColor(.white) // Texto claro para contrastar
                    .shadow(color: .black, radius: 2, x: 0, y: 2) // Sombra para legibilidad
                
                // Campos de formulario con fondo semitransparente
                Group {
                    TextField("Email", text: $email)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    SecureField("Contraseña (mín. 6 caracteres)", text: $password)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    SecureField("Confirmar Contraseña", text: $confirmPassword)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                
                if !passwordError.isEmpty {
                    Text(passwordError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if auth.isLoading {
                    ProgressView()
                        .padding()
                } else if !auth.errorMessage.isEmpty {
                    Text(auth.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: register) {
                    Text("Registrarse")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .foregroundColor(.white)
                }
                .background(isFormValid ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(!isFormValid || auth.isLoading)
                .padding(.top)
            }
            .padding(.horizontal, 30)
        }
        .navigationTitle("Crear Cuenta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
            }
        }
    }
    
    private func register() {
        guard isFormValid else { return }
        
        auth.register(email: email, password: password) { success in
            if success {
                dismiss()
            }
        }
    }
}
