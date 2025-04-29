import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {
    @Published var user: User?
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var userName: String = ""

    private var authStateListener: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            self?.user = user
            if let user = user {
                self?.fetchUserName(uid: user.uid)
            } else {
                self?.userName = ""
            }
        }
    }
    
    private func fetchUserName(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            guard let self = self else { return }
            
            if let name = snapshot?.data()?["name"] as? String {
                self.userName = name
            } else {
                if let email = self.user?.email {
                    self.createUserDocument(uid: uid, email: email)
                }
            }
        }
    }
    
    private func createUserDocument(uid: String, email: String) {
        let userData: [String: Any] = [
            "name": email.components(separatedBy: "@").first ?? "Usuario",
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(uid).setData(userData) { _ in
            self.userName = userData["name"] as? String ?? "Usuario"
        }
    }
    
    func clearErrorMessage() {
        errorMessage = ""
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Llene los campos"
            completion(false)
            return
        }
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            self?.isLoading = false
            
            if error != nil {
                self?.errorMessage = "Correo o contraseña incorrectos"
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func register(email: String, password: String, name: String? = nil, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            guard let uid = authResult?.user.uid else {
                self?.errorMessage = "Error al registrar usuario"
                completion(false)
                return
            }
            
            let userData: [String: Any] = [
                "name": name ?? email.components(separatedBy: "@").first ?? "Usuario",
                "email": email,
                "createdAt": Timestamp(date: Date())
            ]
            
            self?.db.collection("users").document(uid).setData(userData) { _ in
                self?.userName = userData["name"] as? String ?? "Usuario"
                completion(true)
            }
        }
    }
    
    func updateUserName(_ newName: String, completion: @escaping (Bool) -> Void) {
        guard let uid = user?.uid else {
            errorMessage = "Usuario no autenticado"
            completion(false)
            return
        }
        
        db.collection("users").document(uid).updateData(["name": newName]) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
            } else {
                self?.userName = newName
                completion(true)
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            errorMessage = ""
            userName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
