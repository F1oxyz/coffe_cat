import SwiftUI
import FirebaseFirestore
import PhotosUI

struct AddProductScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var name = ""
    @State private var price = ""
    @State private var description = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isPublished = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Text(selectedImage == nil ? "Seleccionar Imagen" : "Cambiar Imagen")
                                .foregroundColor(AppColors.darkBrown)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        
                        TextField("Nombre", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        TextField("Precio", text: $price)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .padding(.horizontal)
                        
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(5)
                            .padding(.horizontal)
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        Button(action: publishProduct) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Publicar Producto")
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.darkBrown)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .disabled(isLoading || isPublished)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Agregar Producto")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    navigationManager.navigateTo(.menu)
                }
            )
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onChange(of: isPublished) { newValue in
                if newValue {
                    navigationManager.navigateTo(.menu)
                }
            }
        }
    }
    
    private func publishProduct() {
        guard !name.isEmpty else {
            errorMessage = "Por favor ingrese un nombre"
            return
        }
        
        guard let priceValue = Double(price), priceValue > 0 else {
            errorMessage = "Por favor ingrese un precio válido"
            return
        }
        
        guard !description.isEmpty else {
            errorMessage = "Por favor ingrese una descripción"
            return
        }
        
        guard let image = selectedImage else {
            errorMessage = "Por favor seleccione una imagen"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Save image locally
            let imageFilename = try ImageStorageService.shared.saveImage(image)
            let drink = Drink(
                id: UUID().uuidString,
                name: name,
                price: priceValue,
                description: description,
                imageFilename: imageFilename,
                sizes: ["Pequeño", "Mediano", "Grande"]
            )
            
            // Save to Firestore
            let db = Firestore.firestore()
            try db.collection("drinks").document(drink.id).setData(drink.toDictionary()) { error in
                isLoading = false
                
                if let error = error {
                    errorMessage = "Error al publicar el producto: \(error.localizedDescription)"
                    // Delete the saved image if Firestore save fails
                    try? ImageStorageService.shared.deleteImage(filename: imageFilename)
                } else {
                    isPublished = true
                }
            }
        } catch {
            isLoading = false
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    AddProductScreen()
        .environmentObject(NavigationManager())
} 
