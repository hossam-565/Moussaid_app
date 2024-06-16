import Foundation
import Firebase
import FirebaseFirestore

class GetServicesRequest: ObservableObject{
    
    @Published var serviceProviders = [ServiceProviderModel]()
    
    func getData(){
         
        let db = Firestore.firestore()

        
        
        
    }

    
    
    
}
