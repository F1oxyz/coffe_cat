import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MenuScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var drinks: [Drink] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.darkGray))
                        .scaleEffect(1.5)
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Reintentar") {
                            loadDrinks()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(AppColors.darkBrown)
                        .cornerRadius(15)
                    }
                } else if drinks.isEmpty {
                    VStack(spacing: 25) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.darkBrown)
                        
                        Text("No hay productos disponibles")
                            .font(.title2)
                            .foregroundColor(AppColors.darkGray)
                        
                        Button(action: {
                            navigationManager.navigateTo(.addProduct)
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Agregar Producto")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(AppColors.darkBrown)
                            .cornerRadius(15)
                        }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ], spacing: 20) {
                            ForEach(drinks) { drink in
                                DrinkCard(drink: drink) {
                                    navigationManager.navigateTo(.productDetails(drink))
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Menú")
            .navigationBarItems(
                leading: Button(action: {
                    do {
                        try Auth.auth().signOut()
                        navigationManager.handleLogout()
                    } catch {
                        errorMessage = "Error al cerrar sesión: \(error.localizedDescription)"
                    }
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Cerrar Sesión")
                    }
                    .foregroundColor(AppColors.darkBrown)
                },
                trailing: Button(action: {
                    navigationManager.navigateTo(.addProduct)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.darkBrown)
                }
            )
        }
        .onAppear(perform: loadDrinks)
    }
    
    private func loadDrinks() {
        isLoading = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        db.collection("drinks").getDocuments { snapshot, error in
            isLoading = false
            
            if let error = error {
                errorMessage = "Error al cargar los productos: \(error.localizedDescription)"
                return
            }
            
            drinks = snapshot?.documents.compactMap { document in
                Drink.fromDictionary(document.data(), id: document.documentID)
            } ?? []
        }
    }
}

struct DrinkCard: View {
    let drink: Drink
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                if let image = drink.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Color.gray
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(drink.name)
                        .font(.headline)
                        .foregroundColor(AppColors.darkGray)
                        .lineLimit(1)
                    
                    HStack {
                        Text("$\(String(format: "%.2f", drink.price))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.darkBrown)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right.circle.fill")
                            .foregroundColor(AppColors.darkBrown)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 15)
            }
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    MenuScreen()
        .environmentObject(NavigationManager())
} 