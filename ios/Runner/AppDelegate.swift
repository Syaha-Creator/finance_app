import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Request notification permissions
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound],
      completionHandler: { granted, error in
        if granted {
          print("Notification permission granted")
        } else {
          print("Notification permission denied")
        }
      }
    )
    
    // Set notification delegate
    UNUserNotificationCenter.current().delegate = self
    
    // Configure notification categories
    configureNotificationCategories()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func configureNotificationCategories() {
    // Budget notification category
    let budgetCategory = UNNotificationCategory(
      identifier: "BUDGET_CATEGORY",
      actions: [
        UNNotificationAction(
          identifier: "VIEW_BUDGET",
          title: "Lihat Budget",
          options: [.foreground]
        ),
        UNNotificationAction(
          identifier: "DISMISS",
          title: "Tutup",
          options: [.destructive]
        )
      ],
      intentIdentifiers: [],
      options: []
    )
    
    // Goal notification category
    let goalCategory = UNNotificationCategory(
      identifier: "GOAL_CATEGORY",
      actions: [
        UNNotificationAction(
          identifier: "VIEW_GOAL",
          title: "Lihat Goal",
          options: [.foreground]
        ),
        UNNotificationAction(
          identifier: "DISMISS",
          title: "Tutup",
          options: [.destructive]
        )
      ],
      intentIdentifiers: [],
      options: []
    )
    
    // Debt notification category
    let debtCategory = UNNotificationCategory(
      identifier: "DEBT_CATEGORY",
      actions: [
        UNNotificationAction(
          identifier: "VIEW_DEBT",
          title: "Lihat Utang",
          options: [.foreground]
        ),
        UNNotificationAction(
          identifier: "MARK_PAID",
          title: "Tandai Lunas",
          options: [.foreground]
        ),
        UNNotificationAction(
          identifier: "DISMISS",
          title: "Tutup",
          options: [.destructive]
        )
      ],
      intentIdentifiers: [],
      options: []
    )
    
    // Register categories
    UNUserNotificationCenter.current().setNotificationCategories([
      budgetCategory,
      goalCategory,
      debtCategory
    ])
  }
  
  // MARK: - UNUserNotificationCenterDelegate Override Methods
  
  // Handle notification when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show notification even when app is in foreground
    completionHandler([.alert, .badge, .sound])
  }
  
  // Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let identifier = response.actionIdentifier
    
    switch identifier {
    case "VIEW_BUDGET":
      // Navigate to budget page
      print("Navigate to budget page")
    case "VIEW_GOAL":
      // Navigate to goal page
      print("Navigate to goal page")
    case "VIEW_DEBT":
      // Navigate to debt page
      print("Navigate to debt page")
    case "MARK_PAID":
      // Mark debt as paid
      print("Mark debt as paid")
    default:
      break
    }
    
    completionHandler()
  }
}
