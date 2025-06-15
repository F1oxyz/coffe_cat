import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProductDetailsScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    let drink: Drink
    @State private var selectedSize = "Mediano"
    @State private var quantity = 1
    @State private var deliveryAddress = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isOrdered = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let image = drink.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipped()
                        } else {
                            Color.gray
                                .frame(height: 300)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text(drink.name)
                                .font(.title)
                                .foregroundColor(AppColors.darkGray)
                            
                            Text(drink.description)
                                .foregroundColor(AppColors.darkGray)
                            
                            Text("$\(String(format: "%.2f", drink.price))")
                                .font(.title2)
                                .foregroundColor(AppColors.darkBrown)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tamaño")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                Picker("Tamaño", selection: $selectedSize) {
                                    ForEach(drink.sizes, id: \.self) { size in
                                        Text(size).tag(size)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cantidad")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                HStack {
                                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(AppColors.darkBrown)
                                    }
                                    
                                    Text("\(quantity)")
                                        .frame(minWidth: 40)
                                    
                                    Button(action: { quantity += 1 }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(AppColors.darkBrown)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Dirección de entrega")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                TextEditor(text: $deliveryAddress)
                                    .frame(height: 100)
                                    .padding(4)
                                    .background(Color.white)
                                    .cornerRadius(5)
                            }
                            
                            if let error = errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            
                            Button(action: placeOrder) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Ordenar")
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.darkBrown)
                            .cornerRadius(10)
                            .disabled(isLoading || isOrdered)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Detalles del Producto")
            .navigationBarItems(
                leading: Button("Regresar") {
                    navigationManager.navigateTo(.menu)
                }
            )
            .onChange(of: isOrdered) { newValue in
                if newValue {
                    navigationManager.navigateTo(.thankYou)
                }
            }
        }
    }
    
    private func placeOrder() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Debe iniciar sesión para realizar un pedido"
            return
        }
        
        guard !deliveryAddress.isEmpty else {
            errorMessage = "Por favor ingrese una dirección de entrega"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let order = [
            "userId": userId,
            "drinkId": drink.id,
            "drinkName": drink.name,
            "size": selectedSize,
            "quantity": quantity,
            "totalPrice": drink.price * Double(quantity),
            "deliveryAddress": deliveryAddress,
            "status": "pending",
            "createdAt": Timestamp()
        ] as [String: Any]
        
        let db = Firestore.firestore()
        db.collection("orders").addDocument(data: order) { error in
            isLoading = false
            
            if let error = error {
                errorMessage = "Error al realizar el pedido: \(error.localizedDescription)"
            } else {
                isOrdered = true
            }
        }
    }
}

#Preview {
    ProductDetailsScreen(
        drink: Drink(
            id: "1",
            name: "Café Latte",
            price: 4.99,
            description: "Espresso con leche cremosa",
            imageFilename: "null",
            sizes: ["Pequeño", "Mediano", "Grande"]
        )
    )
    .environmentObject(NavigationManager())
} 
