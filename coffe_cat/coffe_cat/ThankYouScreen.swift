import SwiftUI

struct ThankYouScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(AppColors.darkBrown)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                    
                    VStack(spacing: 15) {
                        Text("¡Gracias por tu pedido!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.darkGray)
                            .multilineTextAlignment(.center)
                        
                        Text("Tu pedido ha sido recibido y está siendo procesado.")
                            .font(.body)
                            .foregroundColor(AppColors.darkGray)
                            .multilineTextAlignment(.center)
                        
                        Text("Pago contra entrega")
                            .font(.headline)
                            .foregroundColor(AppColors.darkBrown)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    Button(action: {
                        navigationManager.navigateTo(.menu)
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Regresar al Menú")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.darkBrown)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ThankYouScreen()
        .environmentObject(NavigationManager())
} 