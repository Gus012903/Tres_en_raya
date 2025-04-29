import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var auth: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    private let horizontalPadding: CGFloat = 25     // Padding lateral general
    private let verticalPadding: CGFloat = 12       // Padding vertical entre secciones
    private let fieldPadding: CGFloat = 15          // Padding interno de los campos
    private let titleBottomPadding: CGFloat = 25    // Espacio bajo el título
    private let buttonVerticalPadding: CGFloat = 16 // Altura del botón
    
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
            // Imagen de fondo
            Image("Background")
                .resizable()
                .scaledToFill()
                .opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            //ScrollView {
                VStack(spacing: 25) {
                    // Título
                    Text("Registro")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, titleBottomPadding)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 2)
                        .padding(.top, verticalPadding)
                    
                    // Formulario
                    Group {
                        TextField("Email", text: $email)
                            .textFieldStyle(.plain)
                            .padding(fieldPadding)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        SecureField("Contraseña (mín. 6 caracteres)", text: $password)
                            .textFieldStyle(.plain)
                            .padding(fieldPadding)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        SecureField("Confirmar Contraseña", text: $confirmPassword)
                            .textFieldStyle(.plain)
                            .padding(fieldPadding)
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
                    .padding(.horizontal, horizontalPadding)
                    
                    
                    if !passwordError.isEmpty {
                        Text(passwordError)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, horizontalPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if auth.isLoading {
                        ProgressView()
                            .padding(verticalPadding)
                    } else if !auth.errorMessage.isEmpty {
                        Text(auth.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, horizontalPadding)
                    }
                    
                    Button(action: register) {
                        Text("Registrarse")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, buttonVerticalPadding)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(!isFormValid || auth.isLoading)
                    .padding(.top, verticalPadding)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, verticalPadding)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, -100)
            }
        // }
        .navigationTitle("Crear Cuenta")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .padding(.leading, 5)
            }
        }
        .onAppear {
            auth.clearErrorMessage()
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
