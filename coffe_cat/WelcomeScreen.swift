import SwiftUI

struct WelcomeScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Bienvenido/a")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.darkGray)
                
                VStack(spacing: 15) {
                    Button(action: {
                        navigationManager.navigateTo(.login)
                    }) {
                        Text("Iniciar Sesión")
                            .font(.headline)
                            .foregroundColor(AppColors.darkGray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.buttonBackground)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        navigationManager.navigateTo(.register)
                    }) {
                        Text("Registrarse")
                            .font(.headline)
                            .foregroundColor(AppColors.darkGray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.buttonBackground)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    WelcomeScreen()
        .environmentObject(NavigationManager())
} 
