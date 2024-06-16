import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct AdminView: View {
//    @StateObject var data = GetServicesRequest()
    @AppStorage("log_status") private var logStatus: Bool = false
    @AppStorage("admin") private var isAdmin: Bool = false
    let nightBlueStart = Color(red: 0.10, green: 0.2, blue: 0.53)
    @ObservedObject var viewModel = GetServicesRequest()
        @State private var profileImageURLs: [String: URL] = [:] // Dictionnaire pour stocker les URLs des images de profil

    var body: some View {
        VStack{
            Image("logow")
                .resizable()
                .frame(width:90,height: 90)
        }
            
            NavigationView {
                
                List(viewModel.serviceProviders) { serviceProvider in
                    HStack {
                        // Image de profil
                        if let profileURL = profileImageURLs[serviceProvider.id] {
                            // URL déjà récupérée, affichez l'image
                            AsyncImage(url: profileURL) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        } else {
                            // URL pas encore récupérée, affichez une image par défaut et lancez le téléchargement
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .onAppear {
                                    fetchProfilePictureURL(for: serviceProvider.id) { result in
                                        switch result {
                                        case .success(let url):
                                            profileImageURLs[serviceProvider.id] = url
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(serviceProvider.name)
                            Text(serviceProvider.email)
                        }
                    }
                }
                .navigationBarTitle("Users")
                
                
                
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
    
    
    func fetchProfilePictureURL(for uid: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference(withPath: "profilePictures/\(String(describing: uid)).jpg")
        
        storageRef.downloadURL { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }
    }
}

#Preview {
    AdminView()
}
