import FirebaseAuth

class EmailAuthHandler {
    static func reauthenticateWithPassword(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "No user found", code: 0, userInfo: nil)))
            return
        }

        let email = user.email ?? ""
        let password = "userPassword" // 사용자로부터 비밀번호를 입력받아야 함
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
