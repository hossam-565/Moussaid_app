
import SwiftUI

struct StartView: View {
    // État qui détermine quelle vue de connexion afficher
    @State private var navigationTag: String? = nil
    @AppStorage("client_log") private var isClient: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .offset(x: -57, y: 0)
                    .scaleEffect(1)

                VStack {
                    Spacer()
                    // Bouton pour la connexion du client
                    Button("Client") {
                        setClient(true)
                    }.buttonDesign
                    
                    // Bouton pour la connexion du prestataire de service
                    Button("Prestataire de service") {
                        setClient(false)
                    }.buttonDesign
                    
                    Spacer()
                }
                // Links invisibles pour la navigation
                NavigationLink(destination: LoginView(), tag: "Client", selection: $navigationTag) {
                    EmptyView()
                }
                NavigationLink(destination: LoginView(), tag: "Prestataire", selection: $navigationTag) {
                    EmptyView()
                }
            }
        }
    }

    // Fonction pour régler le statut client
    private func setClient(_ isClientStatus: Bool) {
        isClient = isClientStatus
        navigationTag = isClientStatus ? "Client" : "Prestataire"
    }
}

// Design des boutons réutilisable
extension Button {
    var buttonDesign: some View {
        self
            .font(.custom("VotreFonteChic", size: 18))
            .foregroundColor(.white)
            .frame(width: 280, height: 50)
            .background(Color.black.opacity(0.6))
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 2)
    }
}

// Définitions des vues de connexion dans des fichiers séparés :
// ClientLoginView.swift et PrestataireLoginView.swift

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}

