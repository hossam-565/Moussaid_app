import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import FirebaseStorage

class GetServicesRequest: ObservableObject {
    @Published var serviceProviders: [ServiceProviderModel] = []

    init() {
        let db = Firestore.firestore()
        db.collection("serviceProviders").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else {
                print("No snapshot data was returned")
                return
            }
            
            DispatchQueue.main.async {
                self?.serviceProviders = snapshot.documents.compactMap { document in
                    let geoPoint = document.get("location") as? GeoPoint
                    // Maintenant, 'location' est disponible ici
                    return ServiceProviderModel(
                        id: document.documentID,
                        name: document.get("name") as? String ?? "",
                        surname: document.get("surname") as? String ?? "",
                        email: document.get("email") as? String ?? "",
                        phoneNumber: document.get("phoneNumber") as? String ?? "",
                        whatsappNumber: document.get("whatsappNumber") as? String ?? "",
                        socialLinks: document.get("socialLinks") as? [String: String] ?? [:],
                        cityOfWork: document.get("cityOfWork") as? String ?? "",
                        jobDescription: document.get("jobDescription") as? String ?? "",
                        capableTasks: document.get("capableTasks") as? [String] ?? [],
                        serviceCategory: ServiceCategory(rawValue: document.get("serviceCategory") as? String ?? "") ?? .general,
                        profilePictureURL: document.get("profilePictureURL") as? String ?? "",
                        location: geoPoint
                    )
                }
                
            }
        }
    }
    

    func getProfilePictureURL(forUserID userID: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference()
        let profilePicRef = storageRef.child("profilePictures/\(userID).jpg")

        profilePicRef.downloadURL { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }
    }
}
