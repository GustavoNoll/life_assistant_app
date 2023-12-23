//
//  SignAppleId.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//
import AuthenticationServices

class SignInWithAppleDelegates: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var onSignInCallback: ((Bool) -> Void)?

    init(onSignIn: @escaping (Bool) -> Void) {
        self.onSignInCallback = onSignIn
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            onSignInCallback?(false)
            return
        }

        // Aqui você pode acessar informações do usuário, como appleIDCredential.user, email, etc.
        // Lógica de login com Apple ID

        onSignInCallback?(true)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onSignInCallback?(false)
    }
}
