import FirebaseAuth
import AuthenticationServices

class AppleAuthHandler: NSObject {
    static func startSignInWithAppleFlow(viewModel: AuthViewModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = viewModel
        authorizationController.presentationContextProvider = viewModel
        authorizationController.performRequests()

        viewModel.reauthenticationCompletion = completion
    }

    static func authorizationController(viewModel: AuthViewModel, controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                viewModel.reauthenticationCompletion?(.failure(NSError(domain: "Apple ID Token error", code: 0, userInfo: nil)))
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nil)
            Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
                if let error = error {
                    viewModel.reauthenticationCompletion?(.failure(error))
                } else {
                    viewModel.reauthenticationCompletion?(.success(()))
                }
            }
        }
    }

    static func authorizationController(viewModel: AuthViewModel, controller: ASAuthorizationController, didCompleteWithError error: Error) {
        viewModel.reauthenticationCompletion?(.failure(error))
    }
}
