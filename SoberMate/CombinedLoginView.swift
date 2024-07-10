import SwiftUI
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

struct CombinedLoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showEmailLogin = false

    var body: some View {
        VStack {
            if authViewModel.isSignedIn {
                ContentView()
                    .environmentObject(authViewModel)
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("SoberMate")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 60)
                    
                    Spacer()
                    
                    SignInWithAppleButton(.signIn, onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    }, onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            authViewModel.handleAuthorization(authResults)
                        case .failure(let error):
                            print("Authorization failed: \(error.localizedDescription)")
                        }
                    })
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        authViewModel.signInWithGoogle()
                    }) {
                        HStack {
                            Image("googleLogo") // 구글 로고를 사용하는 경우 해당 이미지 추가
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Sign In with Google")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(height: 50) // 버튼 높이 맞추기
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)

                    Button(action: {
                        showEmailLogin.toggle()
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .resizable()
                                .frame(width: 24, height: 18)
                            Text("Sign In with Email")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(height: 50) // 버튼 높이 맞추기
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .sheet(isPresented: $showEmailLogin) {
                        EmailLoginView(isSignedIn: $authViewModel.isSignedIn)
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .environmentObject(authViewModel)
    }
}
