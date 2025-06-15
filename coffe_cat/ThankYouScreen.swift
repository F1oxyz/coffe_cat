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
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    
                    Text("¡Gracias por tu pedido!")
                        .font(.title)
                        .foregroundColor(AppColors.darkGray)
                    
                    Text("Tu pedido ha sido recibido y está siendo procesado.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.darkGray)
                    
                    Text("Pago contra entrega")
                        .font(.headline)
                        .foregroundColor(AppColors.darkBrown)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    
                    Button(action: {
                        navigationManager.navigateTo(.menu)
                    }) {
                        Text("Regresar al Menú")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.darkBrown)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ThankYouScreen()
        .environmentObject(NavigationManager())
} 