import SwiftUI
import AuthenticationServices
import FirebaseAuth
import CryptoKit
import GoogleSignIn


struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showHomePage = false
    @State private var showAlert1 = false
    @State private var showAlert2 = false
    @State private var showAlert = false
    @State private var isPasswordValid: Bool = false
    @State private var isEmailValid: Bool = false
    @AppStorage("log_status") private var logStatus: Bool = false
    @StateObject var authViewModel = EmailSignUpViewModel()
    @State private var isShowingVerificationView = false
    @State private var alertMessage: String = ""
    @State private var errorMessage: String = ""
    @State private var isUserEmailVerified: Bool = false
    @State private var nonce: String?
    @StateObject var loginModel: AuthenticationViewModel = .init()
    @StateObject var google = GoogleLoginViewModel()
    let nightBlueStart = Color(red: 0.10, green: 0.2, blue: 0.53)

    var body: some View {
        
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [nightBlueStart,Color.brown]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
//                    Spacer().frame(height: 150)
                    Text("S'INSCRIRE")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    CustomTextField(placeholder: "Email", text: $email, imageName: "envelope")
                        .onChange(of: email) { oldValue,newValue in
                            isEmailValid = isEmailFormatValid(email: newValue)
                        }
                    
                    CustomSecureField(placeholder: "Mot de passe", text: $password, imageName: "lock")
                        .onChange(of: password) {oldValue, newValue in
                            isPasswordValid = isPasswordStrong(password: newValue)
                        }
                    
                    CustomSecureField(placeholder: "Confirmer le mot de passe", text: $confirmPassword, imageName: "lock")
                    
                    Button(action: {
                        // Logique de vérification de la correspondance des mots de passe
                        if password == confirmPassword {
                            //                            showHomePage = true
                            authViewModel.signUpUser(email: email, password: password) { success, error in
                                if success {
                                    // L'inscription a réussi, procéder à la suite
//                                    showHomePage = true
                                    sendVerificationEmail()
                                } else {
                                    // Afficher une erreur
                                    print(error?.localizedDescription ?? "Erreur inconnue")
                                }
                            }
                            
                        } else {
                            showAlert1 = true
                        }
                        
                    })
                    {
                        Text("S'INSCRIRE")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                 
                    .disabled(!isEmailValid || !isPasswordValid)
                    .alert(isPresented: $showAlert1) {
                        Alert(
                            title: Text("Erreur"),
                            message: Text("Les mots de passe ne correspondent pas."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Erreur"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    .navigationDestination(isPresented: $isShowingVerificationView) {
                                   EmailVerificationView(isShowingVerificationView: $isShowingVerificationView)
                    }
                    
                    Text("Ou")
                        .foregroundColor(.white)
                        .padding()
                    
                    HStack(spacing: 20) {
//                        SignInWithAppleButton(.signIn) { request in
//                            let nonce = randomNonceString()
//                            self.nonce = nonce
//                          // Your Preferences
//                          request.requestedScopes = [.email, .fullName]
//                            request.nonce = sha256(nonce)
//                        } onCompletion: { result in
//                          switch result {
//                            case .success(let authorization):
//                              loginWithFirebase(authorization)
//                            case .failure(let error):
//                              showError(error.localizedDescription)
//                          }
//                        }
//                        .signInWithAppleButtonStyle(.black)
//                        .frame(width: 200, height: 50)
//                        .cornerRadius(8)
                        
                        SignInWithAppleButton(.signIn) { request in
                          loginModel.nonce = randomNonceString()
                          request.requestedScopes = [.email, .fullName]
                          request.nonce = sha256(loginModel.nonce)
                        } onCompletion: { result in
                          switch result {
                            case .success(let user):
                              print("success")
                              guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                                print("error with firebase")
                                return
                              }
                              loginModel.Authenticate(credential: credential)
                            case .failure(let error):
                              print(error.localizedDescription)
                          }
                        }.frame(width: 200, height: 50)
                         .cornerRadius(8)
                    }.alert(isPresented: $showAlert2) {
                        Alert(title: Text("Erreur"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }
                    Button(action: google.signInWithGoogle) {
                        HStack {
                            Image("google") // Assurez-vous d'avoir cette image dans vos assets.
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Sign in with Google")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white) // Google utilise généralement un fond noir pour son bouton de connexion.
                        .cornerRadius(10)
                    }
                    .padding()

                    Spacer()
                }
                .padding()
            }
          
            
            
        }.navigationDestination(isPresented: $logStatus) {
            HomePageView()
        }
        
        
    }
    
  
    
    private func sendVerificationEmail() {
        // Check if there's a current user
        if let currentUser = Auth.auth().currentUser {
            currentUser.sendEmailVerification { error in
                if let error = error {
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true // Make sure this triggers an alert in the view
                } else {
                    self.isShowingVerificationView = true
                }
            }
        } else {
            self.alertMessage = "Aucun utilisateur actuel n'est connecté."
            self.showAlert = true // Make sure this triggers an alert in the view
        }
    }
    
    func isPasswordStrong(password: String) -> Bool {
       let passwordRegex = "^[\\s\\S]{8,}$"
       return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
   }

    func isEmailFormatValid(email: String) -> Bool {
       let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
   }
   
    func showError(_ message: String){
        errorMessage = message
        showAlert2.toggle()        
    }
    
//
//    func loginWithFirebase(_ authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            guard let nonce else {
//                showError("Cannot process your request")
//                return
//            }
//            guard let appleIDToken = appleIDCredential.identityToken else {
//                showError("Cannot process your request")
//                return
//            }
//            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                showError("Cannot process your request")
//                return
//            }
//            // Initialize a Firebase credential, including the user's full name.
//            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
//                                                           rawNonce: nonce,
//                                                           fullName: appleIDCredential.fullName)
//            
//            // Sign in with Firebase.
//            Auth.auth().signIn(with: credential) { (authResult, error) in
//                if let error {
//                    // Error. If error.code == .MissingOrInvalidNonce, make sure
//                    // you're sending the SHA256-hashed nonce as a hex string with
//                    // your request to Apple.
//                    showError(error.localizedDescription)
//                    
//                }
//                logStatus = true
////                isLoading = false
//
//            }
//        }
//    }

//    
//     private func randomNonceString(length: Int = 32) -> String {
//      precondition(length > 0)
//      var randomBytes = [UInt8](repeating: 0, count: length)
//      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
//      if errorCode != errSecSuccess {
//        fatalError(
//          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
//        )
//      }
//
//      let charset: [Character] =
//        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//
//      let nonce = randomBytes.map { byte in
//        // Pick a random character from the set, wrapping around if needed.
//        charset[Int(byte) % charset.count]
//      }
//
//      return String(nonce)
//    }
//
//        
//    private func sha256(_ input: String) -> String {
//      let inputData = Data(input.utf8)
//      let hashedData = SHA256.hash(data: inputData)
//      let hashString = hashedData.compactMap {
//        String(format: "%02x", $0)
//      }.joined()
//
//      return hashString
//    }
//    
}



struct CustomTextField2: View {
        var placeholder: String // Utiliser une String pour le placeholder
        @Binding var text: String
        var imageName: String
        var isSecure: Bool = false
        
        var body: some View {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(.white)
                if isSecure {
                    SecureField(placeholder, text: $text) // Utilisez directement le placeholder
                        .foregroundColor(.white)
                } else {
                    TextField(placeholder, text: $text) // Utilisez directement le placeholder
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.5))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }


struct CustomSecureField2: View {
        var placeholder: String
        @Binding var text: String
        var imageName: String
        
        var body: some View {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(.white)
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.secondary.opacity(0.5))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

#Preview {
            ContentView()
}
