import SwiftUI
import FirebaseAuth

struct LoginScreen: View {
    //se crean e inicializan variables
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Image(systemName: "cup.and.saucer.fill")
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
                                    .textContentType(.password)
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
                            
                            Button(action: login) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    HStack {
                                        Image(systemName: "arrow.right.circle.fill")
                                        Text("Iniciar Sesión")
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
    
    //se crea la funcion login()
    private func login() {
        //devuelve error si no hay datos en los campos
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Por favor complete todos los campos"
            return
        }
        
        //inicializamos variables
        isLoading = true
        errorMessage = nil
        
        //autenticamos con el metodo auth() de firebase (la base de datos de google)
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                /*
                 *  Aqui detecta si tiene un error, este se devuelve
                 *  en inglés ya que no especificamos cada uno para
                 *  evitar más lineas de código.
                 */
                errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
            } else {
                navigationManager.navigateTo(.menu)
            }
        }
    }
}

//se crea la maqueta para la previsualizacion en xcode
#Preview {
    LoginScreen()
        .environmentObject(NavigationManager())
} 
