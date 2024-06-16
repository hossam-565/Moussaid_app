import Firebase
import FirebaseAuth

class EmailSignUpViewModel: ObservableObject {
    
    // Cette fonction enregistre un nouvel utilisateur avec un email et un mot de passe
    func signUpUser(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Une erreur s'est produite pendant l'inscription
                completion(false, error)
            } else {
                // L'utilisateur est inscrit avec succès
                completion(true, nil)
            }
            
        }
    }
}
