import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TicTacToeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var auth = AuthService()
    @StateObject var gameBoard = GameBoard()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if auth.user != nil && !auth.isLoading{
                    GameMenuView(auth: auth)
                }else {
                    LoginView(auth: auth)
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard auth.user != nil else { return }
            
            switch newPhase {
            case .background, .inactive:
                gameBoard.scheduleReminderNotification()
            case .active:
                NotificationManager.shared.cancelPendingNotification()
            default:
                break
            }
        }
    }
}
