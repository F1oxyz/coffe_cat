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
                
                ScrollView {
                    VStack(spacing: 30) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.darkBrown)
                            .padding()
                            
                        
                        VStack(spacing: 25) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Correo electrónico")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                TextField("", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contraseña")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                SecureField("", text: $password)
                                    .textContentType(.newPassword)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirmar contraseña")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                SecureField("", text: $confirmPassword)
                                    .textContentType(.newPassword)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            if let error = errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: register) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    HStack {
                                        Image(systemName: "person.badge.plus.fill")
                                        Text("Registrarse")
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.darkBrown)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .disabled(isLoading)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        Button(action: {
                            navigationManager.navigateTo(.welcome)
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Regresar")
                            }
                            .foregroundColor(AppColors.darkBrown)
                        }
                        .padding(.top)
                    }
                    .padding(.vertical, 30)
                }
            }
            .navigationBarHidden(true)
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
                errorMessage = "Error al registrarse: \(error.localizedDescription)"
            } else {
                navigationManager.navigateTo(.menu)
            }
        }
    }
}

#Preview {
    RegisterScreen()
        .environmentObject(NavigationManager())
} 
