import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isAuthenticated = false
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

            SignInWithAppleButton {
                request in
                // Lógica de personalização da solicitação (se necessário)
            } onCompletion: { result in
                handleAppleSignIn(result: result)
            }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 50)
            .padding()

            // Adicione outros elementos de login (por exemplo, e-mail/senha) aqui

            Spacer()
        }
        .fullScreenCover(isPresented: $isAuthenticated) {
            ContentView()
        }
        .preferredColorScheme(ColorScheme.light)
        .padding()
    }

    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Aqui você pode acessar informações do usuário, como appleIDCredential.user, email, etc.
                // Lógica de login com Apple ID
                viewModel.handleSignInWithApple(appleId: appleIDCredential.user)
            } else {
                print("Erro: Não foi possível obter as credenciais da Apple.")
            }

        case .failure(let error):
            print("Erro ao autenticar com a Apple: \(error.localizedDescription)")
        }
        isAuthenticated = true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

class LoginViewModel: ObservableObject {
    func handleSignInWithApple(appleId: String) {
        
    }
}
