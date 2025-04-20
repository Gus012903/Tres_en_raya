import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private let notificationIdentifier = "com.yourapp.tictactoe"
    
    private init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Permiso para notificaciones concedido")
            } else if let error = error {
                print("Error al pedir permiso: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleGameReminder(after seconds: TimeInterval) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "¡Vuelve al juego!"
        content.body = "Llevas mucho tiempo sin jugar al Tres en Raya"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error al programar notificación: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelPendingNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
}

