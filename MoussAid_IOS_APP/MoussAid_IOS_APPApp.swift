
import SwiftUI
import GoogleSignIn
import Firebase

@main
struct MoussAid_appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //    init(){
    //        FirebaseApp.configure()
    //    }
    var body: some Scene {
        WindowGroup {
           ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        // Check if `user` exists; otherwise, do something with `error`
                    }
                }
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            return true
        }
        
        // The method should call the handleURL method of the GIDSignIn instance, which will properly handle
        // the URL that your application receives at the end of the authentication process.
        @available(iOS 9.0, *)
        // it asks the delegate to open the resource specified by the url.
        func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            return GIDSignIn.sharedInstance.handle(url)
        }
    }
}
