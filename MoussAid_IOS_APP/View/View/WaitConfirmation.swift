

import SwiftUI
import FirebaseAuth

struct WaitConfirmation: View {
    @AppStorage("log_status") private var logStatus: Bool = false
    @State private var showingProviderForm = false
    @AppStorage("submit") private var isSubmit: Bool = false

    var body: some View {
        ZStack {
                Image("waitbackgrd")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .offset(x: -50, y: 0)
                    .scaleEffect(1)
            VStack {

                        Text("Votre demande est encore         de traitement...")
                             .font(.title3)
                             .fontWeight(.semibold)
                             .foregroundColor(.white)
                             .multilineTextAlignment(.center)
                             .padding()
                
                        
                        Text("Lorsqu'il est confirmé, il sera ajouté dans les services de l'application.")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()

                        Button(action: {
                            do {
                                try Auth.auth().signOut()
                                logStatus = false
                            } catch let signOutError as NSError {
                                print("Erreur de déconnexion: \(signOutError)")
                            }                                
                        })
                        {
                            Text("Annuler la demande")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .frame(width: 180, height: 40)
                                .cornerRadius(95)
                        }
                
                
                         Button(action: {
                                   // Action pour annuler la demande et retourner au formulaire
                                   showingProviderForm = true
                                   isSubmit = false
                               }) {
                                   Text("Refaire un demande")
                                       .foregroundColor(.white)
                                       .padding()
                                       .background(LinearGradient(gradient: Gradient(colors: [Color.brown, Color.blue]), startPoint: .leading, endPoint: .trailing))
                                       .frame(width: 180, height: 40)
                                       .cornerRadius(45)
                               }
                               
                               // Si vous utilisez `NavigationLink`, ajoutez-le ici et liez-le à `showingProviderForm`
                               NavigationLink(destination: ServiceProviderFormView(), isActive: $showingProviderForm) { EmptyView() }
                    }
                    .frame(width: 320, height: 320)
                    .background(Color.black.opacity(0.6)) // Vous pouvez ajuster l'opacité ici
                    .cornerRadius(150) // La moitié de la largeur et la hauteur pour rendre le cercle parfait
                    .shadow(radius: 10)
                    .offset(x: -4, y: -40)

                }
        }
}
#Preview {
    WaitConfirmation()
}
