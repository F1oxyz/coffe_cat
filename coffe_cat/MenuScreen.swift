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
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Reintentar") {
                            loadDrinks()
                        }
                        .foregroundColor(AppColors.darkBrown)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                } else if drinks.isEmpty {
                    VStack(spacing: 20) {
                        Text("No hay productos disponibles")
                            .font(.title2)
                            .foregroundColor(AppColors.darkGray)
                        
                        Button(action: {
                            navigationManager.navigateTo(.addProduct)
                        }) {
                            Text("Agregar Producto")
                                .foregroundColor(.white)
                                .padding()
                                .background(AppColors.darkBrown)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
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
                leading: Button("Cerrar Sesión") {
                    do {
                        try Auth.auth().signOut()
                        navigationManager.handleLogout()
                    } catch {
                        errorMessage = "Error al cerrar sesión: \(error.localizedDescription)"
                    }
                },
                trailing: Button(action: {
                    navigationManager.navigateTo(.addProduct)
                }) {
                    Image(systemName: "plus")
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
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Color.gray
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(drink.name)
                        .font(.headline)
                        .foregroundColor(AppColors.darkGray)
                        .lineLimit(1)
                    
                    Text("$\(String(format: "%.2f", drink.price))")
                        .font(.subheadline)
                        .foregroundColor(AppColors.darkBrown)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }
}

#Preview {
    MenuScreen()
        .environmentObject(NavigationManager())
} 