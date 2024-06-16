import FirebaseFirestoreSwift
import FirebaseFirestore

struct ServiceProviderModel:Codable,Identifiable {
    var id: String
    var name: String
    var surname: String
    var email: String
    var phoneNumber: String
    var whatsappNumber: String?
    var socialLinks: [String: String]?
    var cityOfWork: String
    var jobDescription: String
    var capableTasks: [String]
    var serviceCategory: ServiceCategory
    var profilePictureURL: String?
    var location: GeoPoint? // Utilisation de FIRGeoPoint pour la localisation

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case surname
        case email
        case phoneNumber
        case whatsappNumber
        case socialLinks
        case cityOfWork
        case jobDescription
        case capableTasks
        case serviceCategory
        case profilePictureURL
        case location
    }


}

enum ServiceCategory: String, Codable, CaseIterable, Identifiable {
    case medical = "Santé"
    case home = "Services à domicile"
    case transport = "Transport"
    case mechanic = "Réparation"
    case food = "Alimentation"
    case general = "Autres services"
    
    var id: String { self.rawValue }
}
