import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") private var logStatus: Bool = false
    @AppStorage("client_log") private var isClient: Bool = false
    @AppStorage("submit") private var isSubmit: Bool = false
    @AppStorage("admin") private var isAdmin: Bool = false

    var body: some View {
        
            if logStatus {
                if isAdmin{
                    AdminView()
                }
                else if isClient {
                    HomePageView()
                } else {
                    if isSubmit {
                        WaitConfirmation()
                    }else{
                        ServiceProviderFormView()
                    }
                    
                }
            } else {
                StartView()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

