import SwiftUI

struct WelcomeScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image("welcome_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding()
                    
                    VStack(spacing: 15) {
                        Text("Bienvenido a")
                            .font(.title2)
                            .foregroundColor(AppColors.darkGray)
                        
                        Text("Coffee Cat")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(AppColors.darkBrown)
                        
                        Text("Tu café favorito a un clic de distancia")
                            .font(.body)
                            .foregroundColor(AppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            navigationManager.navigateTo(.login)
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Iniciar Sesión")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.darkBrown)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        Button(action: {
                            navigationManager.navigateTo(.register)
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus.fill")
                                Text("Registrarse")
                            }
                            .foregroundColor(AppColors.darkBrown)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(AppColors.darkBrown, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    WelcomeScreen()
        .environmentObject(NavigationManager())
} 
