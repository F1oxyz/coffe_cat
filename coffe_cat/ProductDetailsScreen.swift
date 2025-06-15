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
                    VStack(spacing: 25) {
                        if let image = drink.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipped()
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        } else {
                            Color.gray
                                .frame(height: 300)
                                .cornerRadius(20)
                                .overlay(
                                    Image(systemName: "cup.and.saucer.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(drink.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.darkGray)
                                
                                Text(drink.description)
                                    .foregroundColor(AppColors.darkGray)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("$\(String(format: "%.2f", drink.price))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.darkBrown)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tamaño")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                Picker("Tamaño", selection: $selectedSize) {
                                    ForEach(drink.sizes, id: \.self) { size in
                                        Text(size).tag(size)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Cantidad")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                HStack {
                                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(AppColors.darkBrown)
                                    }
                                    
                                    Text("\(quantity)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .frame(minWidth: 40)
                                        .foregroundColor(AppColors.darkGray)
                                    
                                    Button(action: { quantity += 1 }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(AppColors.darkBrown)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Dirección de entrega")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                TextEditor(text: $deliveryAddress)
                                    .frame(height: 100)
                                    .padding(8)
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
                            
                            Button(action: placeOrder) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    HStack {
                                        Image(systemName: "bag.fill")
                                        Text("Ordenar")
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.darkBrown)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .disabled(isLoading || isOrdered)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Detalles del Producto")
            .navigationBarItems(
                leading: Button(action: {
                    navigationManager.navigateTo(.menu)
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Regresar")
                    }
                    .foregroundColor(AppColors.darkBrown)
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
