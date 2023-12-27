import FirebaseAuth
import SwiftUI


class AppViewModel: ObservableObject {
    let auth = Auth.auth()
    @Published var signedIn = false
    @Published var userUid: String?
    
    var isSignedIn : Bool {
        return auth.currentUser != nil
    }
    
    var getUserId : String? {
        return auth.currentUser?.uid
    }
    func signIn(email: String, password: String){
        auth.signIn(withEmail: email,
                    password: password) { result, error in
            guard let user = result?.user, error == nil else {
                print("Error signing in:", error?.localizedDescription ?? "")
                return
            }
            // succesself.userUid = self.auth.currentUser?.uid
            DispatchQueue.main.async {
                self.signedIn = true
            }
        }
        
    }
    func signUp(email: String, password: String){
        auth.createUser(withEmail: email, password: password) { result, error in
            guard let user = result?.user, error == nil else {
                print("Error signing in:", error?.localizedDescription ?? "")
                return
            }
            // succesself.userUid = self.auth.currentUser?.uid
            DispatchQueue.main.async {
                self.signedIn = true
            }
        }

    }
    func signOut() {
        try? auth.signOut()
        DispatchQueue.main.async {
            self.signedIn = false
        }
    }
}
struct LoginView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationView{
            if viewModel.isSignedIn {
                BaseView(userViewModel: viewModel)
                    .environmentObject(viewModel)
            }
            else {
                SignInView()
            }
        }.onAppear {
            viewModel.userUid = viewModel.getUserId
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}

struct SignInView : View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        VStack {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)

            Text("Bem-vindo ao App")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            TextField("Email Address",text: $email)
                .padding().background(Color(.white)).overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
            SecureField("Password", text: $password)
                .padding().background(Color(.white)).overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )


            Button (action: {
                guard !email.isEmpty, !password.isEmpty else {
                    return
                }
                viewModel.signIn(email: email, password: password)
            }, label: {
                Text("Sign In")
                    .frame(width: 200, height: 50)
                    .background(Color(.blue))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            })
            .frame(height: 50)
            .padding()
            
            NavigationLink("Create ACCOUNT", destination: SignUpView())

            // Adicione outros elementos de login (por exemplo, e-mail/senha) aqui

            Spacer()
        }
        .preferredColorScheme(ColorScheme.light)
        .padding()
    }
    
}

struct SignUpView : View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        VStack {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)

            Text("Bem-vindo ao App")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            TextField("Email Address",text: $email)
                .padding().background(Color(.white)).overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
            SecureField("Password", text: $password)
                .padding().background(Color(.white)).overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )


            Button (action: {
                guard !email.isEmpty, !password.isEmpty else {
                    return
                }
                viewModel.signUp(email: email, password: password)
            }, label: {
                Text("Create account")
                    .frame(width: 200, height: 50)
                    .background(Color(.blue))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            })
            
            .frame(height: 50)
            .padding()

            // Adicione outros elementos de login (por exemplo, e-mail/senha) aqui

            Spacer()
        }
        .preferredColorScheme(ColorScheme.light)
        .padding()
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AppViewModel()
        LoginView()
            .environmentObject(viewModel)
    }
}
