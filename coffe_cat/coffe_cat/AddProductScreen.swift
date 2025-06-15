import SwiftUI
import FirebaseFirestore
import PhotosUI

struct AddProductScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var name = ""
    @State private var price = ""
    @State private var description = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isPublished = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                            
                        
                        VStack(spacing: 25) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nombre del producto")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                TextField("", text: $name)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Precio")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                TextField("", text: $price)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Descripción")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                TextEditor(text: $description)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Imagen del producto")
                                    .font(.headline)
                                    .foregroundColor(AppColors.darkGray)
                                
                                Button(action: {
                                    isImagePickerPresented = true
                                }) {
                                    if let image = selectedImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 200)
                                            .clipped()
                                            .cornerRadius(10)
                                    } else {
                                        VStack {
                                            Image(systemName: "photo.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(AppColors.darkBrown)
                                            Text("Seleccionar imagen")
                                                .foregroundColor(AppColors.darkBrown)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            
                            if let error = errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: publishProduct) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Publicar Producto")
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.darkBrown)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .disabled(isLoading || isPublished)
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
                                Image(systemName: "chevron.left")
                                Text("Regresar")
                            }
                            .foregroundColor(AppColors.darkBrown)
                        }
                        .padding(.top)
                    }
                    .padding(.vertical, 30)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onChange(of: isPublished) { newValue in
                if newValue {
                    navigationManager.navigateTo(.menu)
                }
            }
        }
    }
    
    private func publishProduct() {
        guard !name.isEmpty && !price.isEmpty && !description.isEmpty else {
            errorMessage = "Por favor complete todos los campos"
            return
        }
        
        guard let priceDouble = Double(price) else {
            errorMessage = "Por favor ingrese un precio válido"
            return
        }
        
        guard let image = selectedImage else {
            errorMessage = "Por favor seleccione una imagen"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        ImageStorageService.shared.saveImage(image) { result in
            switch result {
            case .success(let filename):
                let drink = Drink(
                    id: UUID().uuidString,
                    name: name,
                    price: priceDouble,
                    description: description,
                    imageFilename: filename,
                    sizes: ["Pequeño", "Mediano", "Grande"]
                )
                
                let db = Firestore.firestore()
                db.collection("drinks").document(drink.id).setData(drink.toDictionary()) { error in
                    DispatchQueue.main.async {
                        isLoading = false
                        
                        if let error = error {
                            errorMessage = "Error al publicar el producto: \(error.localizedDescription)"
                            // Delete the saved image if Firestore save fails
                            ImageStorageService.shared.deleteImage(filename: filename)
                        } else {
                            isPublished = true
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "Error al guardar la imagen: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
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
                        self.parent.selectedImage = image as? UIImage
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
