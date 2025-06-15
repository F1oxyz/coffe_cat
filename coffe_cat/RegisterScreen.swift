import SwiftUI
import FirebaseAuth

struct RegisterScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    
                    TextField("Correo electrónico", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                    
                    SecureField("Confirmar contraseña", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Button(action: register) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Registrarse")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.darkBrown)
                    .cornerRadius(10)
                    .disabled(isLoading)
                }
                .padding()
            }
            .navigationTitle("Registrarse")
            .navigationBarItems(
                leading: Button("Regresar") {
                    navigationManager.navigateTo(.welcome)
                }
            )
        }
    }
    
    private func register() {
        guard !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            errorMessage = "Por favor complete todos los campos"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                navigationManager.handleSuccessfulRegistration()
            }
        }
    }
}

#Preview {
    RegisterScreen()
        .environmentObject(NavigationManager())
} 
