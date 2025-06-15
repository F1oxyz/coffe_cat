import SwiftUI
//esta pantalla es de carga, la que aparece antes de renderizar toda la app
struct LoadingScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack {
            //obtiene los colores de el archivo Colors
            AppColors.background
                .ignoresSafeArea()
            
            VStack {
                /*
                 Se puede poner un imagen para la pantalla de inicio
                 se mantiene comentado para proxima edicion
                 
                Image("poner_direccion_De_img_aqui")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                 */
                
                Text("Coffee Cat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.darkGray)
            }
        }
        .onAppear {
            //que tiempo va a pasar para la proxima pantalla (en este caso 5s )
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                //se dirige a la pantalla de bienvenida
                navigationManager.navigateTo(.welcome)
            }
        }
    }
}

//como se previsualiza en xcode
#Preview {
    LoadingScreen()
        .environmentObject(NavigationManager())
} 
