import FirebaseAuth
import FirebaseStorage
import SwiftUI
import FirebaseFirestore


class ServiceProviderViewModel: NSObject, ObservableObject {
    // Publiez vos variables pour qu'elles soient observables par la vue.
    @Published var serviceProvider = ServiceProviderModel(
        // Initialisez avec des valeurs par défaut ou vides.
        id: Auth.auth().currentUser?.uid ?? "unknown",
        name: "", surname: "", email: "", phoneNumber: "",whatsappNumber: "",socialLinks: ["instagram": "", "facebook": ""],
        cityOfWork: "", jobDescription: "", capableTasks: [""],
        serviceCategory: .general,
        location: nil
    )
    @Published var alertItem: AlertItem?
    @Published var latitude: String = ""
    @Published var longitude: String = ""
  
    private let db = Firestore.firestore()

    override init() {
        super.init()
    }
    
    func updateLocation() {
            if let latitude = Double(latitude), let longitude = Double(longitude) {
                // Créez un nouveau GeoPoint avec les valeurs de latitude et longitude.
                let geoPointLocation = GeoPoint(latitude: latitude, longitude: longitude)
                // Mettez à jour la propriété 'location' de votre modèle de fournisseur de services.
                self.serviceProvider.location = geoPointLocation
            } else {
                // Gérez l'erreur si la conversion échoue (par exemple, si l'utilisateur a entré des valeurs non valides).
                print("Erreur: Les valeurs de localisation ne sont pas valides.")
            }
    }
    
    func showAlert(title: String, message: String) {
            alertItem = AlertItem(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        }
    func submitServiceProvider() {
        // Convertir les propriétés de serviceProvider en dictionnaire pour Firestore.
        do {
            try db.collection("serviceProviders").document(serviceProvider.id).setData(from: serviceProvider)
        } catch let error {
            print("Erreur lors de la sauvegarde des données du fournisseur de services : \(error)")
        }
    }
}
extension ServiceProviderViewModel {
    struct AlertItem: Identifiable {
        var id = UUID()
        var title: Text
        var message: Text
        var dismissButton: Alert.Button
    }
}
