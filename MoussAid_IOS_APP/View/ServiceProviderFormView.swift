import SwiftUI
import FirebaseAuth
import FirebaseStorage
import MapKit

struct ServiceProviderFormView: View {
    @AppStorage("log_status") private var logStatus: Bool = false
    @StateObject var viewModel = ServiceProviderViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var navigateToConfirmation = false
    @State private var showAlert1 = false
    @AppStorage("submit") private var isSubmit: Bool = false
    @State private var alertMessage1 = ""
    var isFormValid: Bool {
            !(viewModel.serviceProvider.name.isEmpty ||
              viewModel.serviceProvider.surname.isEmpty ||
              viewModel.serviceProvider.email.isEmpty ||
              viewModel.serviceProvider.phoneNumber.isEmpty ||
              viewModel.serviceProvider.cityOfWork.isEmpty ||
              viewModel.serviceProvider.jobDescription.isEmpty ||
              viewModel.serviceProvider.capableTasks.isEmpty ||
              viewModel.serviceProvider.location == nil || // Assurez-vous que la localisation a été définie
              viewModel.serviceProvider.serviceCategory.rawValue.isEmpty) // Assurez-vous qu'une catégorie de service a été sélectionnée
        }
    var body: some View {
        
        NavigationStack{
            Form {
                Section(header: Text("Informations Personnelles")) {
                    TextField("Nom", text: $viewModel.serviceProvider.name)
                    TextField("Prénom", text: $viewModel.serviceProvider.surname)
                    TextField("Email", text: $viewModel.serviceProvider.email)
                    TextField("Numéro de Téléphone", text: $viewModel.serviceProvider.phoneNumber)
                    TextField("Numéro WhatsApp", text: Binding(
                        get: { viewModel.serviceProvider.whatsappNumber ?? "" },
                        set: { viewModel.serviceProvider.whatsappNumber = $0 }
                    ))

                }
                Section(header: Text("Détails du Service")) {
                    Picker("Catégorie de Service", selection: $viewModel.serviceProvider.serviceCategory) {
                        ForEach(ServiceCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    TextField("Ville de Travail", text: $viewModel.serviceProvider.cityOfWork)
                    if viewModel.serviceProvider.jobDescription.isEmpty {
                        Text("Description de l'Emploi...")
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                            .padding(.top, 8)
                    }
                    
                    TextEditor(text: $viewModel.serviceProvider.jobDescription)
                        .frame(minHeight: 100, maxHeight: .infinity)
                        .border(Color.gray, width: 1)
                    Section(header: Text("Tâches Capables")) {
                        ForEach($viewModel.serviceProvider.capableTasks.indices, id: \.self) { index in
                            HStack {
                                TextField("Tâche \(index + 1)", text: $viewModel.serviceProvider.capableTasks[index])
                                Spacer()
                                Button(action: {
                                    // Supprime la tâche spécifique à cet index
                                    viewModel.serviceProvider.capableTasks.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Button(action: addTask) { // Ici aussi
                            Label("Ajouter Tâche", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                Section(header: Text(" Photo du Profil ")) {
                    Button("1- Télécharger une photo de profil") {
                        self.showingImagePicker = true
                    }.font(.custom("VotreFonteChic", size: 14))
                        .foregroundColor(.white)
                        .frame(width: 240, height: 40)
                        .background(Color.blue.opacity(0.6))
                        .cornerRadius(25)
                        .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 0, y: 2)
                    if let image = inputImage {
                        Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200) // Remplacer par la taille souhaitée
                                .clipShape(Circle()) // Pour rendre l'image circulaire
                                .overlay(Circle().stroke(Color.black, lineWidth: 2)) // Ajoute une bordure blanche
                                .shadow(radius: 5) // Ajoute une ombre douce autour de l'image
                    }
                    
                    Button("2- Uploader la Photo") {
                        if inputImage != nil {
                            uploadProfilePicture()
                        }
                    }.font(.custom("VotreFonteChic", size: 14))
                        .foregroundColor(.white)
                        .frame(width: 170, height: 40)
                        .background(Color.brown.opacity(0.6))
                        .cornerRadius(25)
                        .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 0, y: 2)
            
                    
                }
                
                Section(header: Text("Localisation")) {
                    Text("Vous pouvez entrer la latitude et la longitude en utilisant une application de carte sur votre iPhone. Récupérez ces paramètres et entrez-les ci-dessous.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()
                    TextField("Latitude", text: $viewModel.latitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $viewModel.longitude)
                        .keyboardType(.decimalPad)
                    
                    Button("Enregistrer la localisation") {
                        viewModel.updateLocation()
                    }   .font(.custom("VotreFonteChic", size: 14))
                        .foregroundColor(.white)
                        .frame(width: 170, height: 40)
                        .background(Color.brown.opacity(0.6))
                        .cornerRadius(25)
                        .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 0, y: 2)
                }
                
                Button("Annuler", action: {
                    do {
                        try Auth.auth().signOut()
                        logStatus = false
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
                
                
                Button("Soumettre") {
                    if isFormValid {
                        viewModel.submitServiceProvider()
                        navigateToConfirmation = true
                        isSubmit = true

                    } else {
                                      alertMessage1 = "Veuillez remplir tous les champs obligatoires."
                                      showAlert1 = true
                    }
                }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        isFormValid ?
                            AnyView(LinearGradient(gradient: Gradient(colors: [Color.brown, Color.black]), startPoint: .leading, endPoint: .trailing))
                            :
                            AnyView(Color.gray)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .shadow(radius: 5)
                    .disabled(!isFormValid)
                    .alert(isPresented: $showAlert1) {
                                    Alert(title: Text("Information"), message: Text(alertMessage1), dismissButton: .default(Text("OK")))
                                }

                NavigationLink(
                                 destination: WaitConfirmation(),
                                 isActive: $navigateToConfirmation,
                                 label: { EmptyView() }
                             )
            }
            .background(Color.black)
            .foregroundColor(.brown)
            .navigationTitle("Demande De Registre")
            .sheet(isPresented: $showingImagePicker, onDismiss: nil) {
                ImagePicker(image: self.$inputImage)
            }
           
        }.navigationBarBackButtonHidden(true)


    }
    
    
    func addTask() {
           viewModel.serviceProvider.capableTasks.append("") // Ajoute un nouvel élément vide à la liste
       }
       

    func uploadProfilePicture() {

        let storageRef = Storage.storage().reference()
        let imageData = inputImage!.jpegData(compressionQuality: 0.8)
        let uid = Auth.auth().currentUser?.uid
              
        guard imageData != nil else{
            viewModel.showAlert(title: "Upload Failed", message: "Could not convert image to data.")
                       return
        }
        let profilePicRef = storageRef.child("profilePictures/\(String(describing: uid)).jpg")

        _ = profilePicRef.putData(imageData!, metadata: nil) { metadata, error in
            guard metadata != nil && error == nil else {
                // Handle error
                viewModel.showAlert(title: "Upload Failed", message: error?.localizedDescription ?? "Error occurred during upload.")
                return
            }
            
        }
    }
    
    
}
    
#Preview {
    ServiceProviderFormView()
}
