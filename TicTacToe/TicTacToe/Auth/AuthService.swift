import FirebaseAuth

class AuthService: ObservableObject {
    @Published var user: User?
    @Published var errorMessage = ""
    @Published var isLoading = false 
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            self?.user = user
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
