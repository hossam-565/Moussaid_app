import SwiftUI
import AuthenticationServices
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift


struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var isShowingSignUp: Bool = false // Ajouté pour contrôler l'affichage de la vue d'inscription
    @AppStorage("log_status") private var logStatus: Bool = false
    @AppStorage("admin") private var isAdmin: Bool = false
    @StateObject var google = GoogleLoginViewModel()
    let nightBlueStart = Color(red: 0.10, green: 0.2, blue: 0.53)

    var body: some View {
        NavigationStack{
            ZStack {
                LinearGradient(gradient: Gradient(colors: [nightBlueStart,Color.brown]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Text("CONNEXION À VOTRE COMPTE")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                    
                    CustomTextField(placeholder: "Email", text: $email, imageName: "envelope")
                    CustomSecureField(placeholder: "Mot de passe", text: $password, imageName: "lock")
                    
                    HStack {
                        Button(action: {
                            self.rememberMe.toggle()
                        }) {
                            HStack {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .foregroundColor(rememberMe ? Color.black : Color.white)
                                Text("Se souvenir de moi")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Mot de passe oublié ?", action: {
                            // Action pour mot de passe oublié
                        })
                        .foregroundColor(Color.black)
                    }
                    .padding([.top, .bottom], 10)
                    
                    Button("CONNEXION") {
                        // Action de connexion
                        login()
                        
                    }
                    .buttonStyle(CustomButtonStyle())
                    
                    Text("Ou")
                        .foregroundColor(.white)
                        .padding()
                    
                    HStack(spacing: 20) {
                        //                        SocialMediaButton(imageName: "google", text: "GOOGLE")
                        //                        SocialMediaButton(imageName: "apple", text: "APPLE")
                        SignInWithAppleButton { request in
                            
                        } onCompletion: { result in
                        }
                        .signInWithAppleButtonStyle(.black) // You can choose .black, .white, .whiteOutline
                        .frame(width: 200, height: 50) // Set the frame as you wish
                        .cornerRadius(8)
                        
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
                    
                    HStack {
                        Text("Vous n'avez pas de compte ?")
                            .foregroundColor(.white)
                        Button("S'inscrire", action: {
                            isShowingSignUp = true // Modifier l'état pour afficher la vue d'inscription
                            
                        })
                        .foregroundColor(Color.black)
                        .background(NavigationLink(destination: SignUpView(), isActive: $isShowingSignUp) { EmptyView() })
                        .foregroundColor(Color.blue)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
              }
            }.navigationDestination(isPresented: $isAdmin) {
                AdminView()}


    }
   

    func login() {
           // Commencez le processus de connexion avec l'email et le mot de passe
           Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
               if let error = error {
                   // Ici, vous gérez les erreurs, par exemple en affichant une alerte
                   print(error.localizedDescription)
               } else if email == "hodec10942@rartg.com" && password == "admin1234567890" {
                   // L'utilisateur est l'admin, naviguer vers AdminView
                   isAdmin = true
                   logStatus = true
               } else {
                   // La connexion a réussi
                   isAdmin = false
                   logStatus = true
                   print("Utilisateur connecté avec succès")
               }
           }
       }
    
   
}
// ... Votre code précédent

struct CustomTextField: View {
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
struct CustomSecureField: View {
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
}// ... Le reste de votre code reste inchangé


struct SocialMediaButton: View {
    var imageName: String
    var text: String

    var body: some View {
        Button(action: {
            // Action pour la connexion avec Google ou Apple
        }) {
            HStack {
                Image(imageName) // Assurez-vous que l'icône est bien nommée dans vos assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(text)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color.secondary.opacity(0.5))
            .cornerRadius(20)
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.brown]), startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct LoginView_Previews1: PreviewProvider {
    static var previews: some View {
       LoginView()
    }
}
