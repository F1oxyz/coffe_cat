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
                
                VStack(spacing: 25) {
                    //con VStack organiza los campos en vertical
                    //y con 25 de espacio entre campos
                    
                    
                    TextField("Correo electrónico", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        
                    
                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.password)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Iniciar Sesión")
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
            .navigationTitle("Iniciar Sesión")
            .navigationBarItems(
                leading: Button("Regresar") {
                    navigationManager.navigateTo(.welcome)
                }
            )
        }
    }
    
    //se crea la funcion login()
    private func login() {
        //devuelve error si no hay datos en los campos
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Por favor rellene todos los campos"
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
                errorMessage = error.localizedDescription
            } else {
                navigationManager.handleSuccessfulLogin()
            }
        }
    }
}

//se crea la maqueta para la previsualizacion en xcode
#Preview {
    LoginScreen()
        .environmentObject(NavigationManager())
} 
