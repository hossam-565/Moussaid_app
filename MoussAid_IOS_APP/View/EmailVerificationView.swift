import SwiftUI
import FirebaseAuth

struct EmailVerificationView: View {
    @Binding var isShowingVerificationView: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isVerified = false
    @AppStorage("log_status") private var logStatus: Bool = false
    let nightBlueStart = Color(red: 0.10, green: 0.2, blue: 0.53)
    var body: some View {
        NavigationStack {
            VStack {
                LinearGradient(gradient: Gradient(colors: [nightBlueStart,Color.brown]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                Text("Vérification de l'email")
                    .font(.title)
                Text("Un email de vérification a été envoyé à votre adresse. Veuillez le vérifier.")
                Button("Renvoyer l'email") {
                    sendVerificationEmailAgain()
                }
                .padding()
                Button("Vérifier l'email") {
                    checkVerificationStatus()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $isVerified) {
                HomePageView()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func sendVerificationEmailAgain() {
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { error in
                alertMessage = error?.localizedDescription ?? "Erreur inconnue lors de l'envoi de l'email."
                showAlert = true
            }
        }
    }

    private func checkVerificationStatus() {
        Auth.auth().currentUser?.reload { error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else if Auth.auth().currentUser?.isEmailVerified ?? false {
                isShowingVerificationView = false
                isVerified = true  // Trigger navigation to home page
                logStatus = true
            } else {
                alertMessage = "Veuillez vérifier votre email."
                showAlert = true
            }
        }
    }
}

