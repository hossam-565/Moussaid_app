
import SwiftUI
import FirebaseAuth

struct AdminView: View {
    @StateObject var data = GetServicesRequest()
    @AppStorage("log_status") private var logStatus: Bool = false
    @AppStorage("admin") private var isAdmin: Bool = false

    var body: some View {
        
        
        
        
        
        
        
        
        
        
        
        
        
        Button("Annuler", action: {
            do {
                try Auth.auth().signOut()
                logStatus = false
                isAdmin = false
            } catch let signOutError as NSError {
                print("Erreur de déconnexion: \(signOutError)")
            }
        }).frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .shadow(radius: 5)
    }
}

#Preview {
    AdminView()
}
