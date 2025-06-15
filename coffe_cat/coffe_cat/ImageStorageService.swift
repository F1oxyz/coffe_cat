import SwiftUI
import Foundation
import UIKit

class ImageStorageService {
    static let shared = ImageStorageService()
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let imagesDirectory: URL
    
    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imagesDirectory = documentsDirectory.appendingPathComponent("Images")
        
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }
    
    func saveImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageStorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen a JPEG"])))
            return
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
            completion(.success(filename))
        } catch {
            completion(.failure(error))
        }
    }
    
    func loadImage(filename: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        guard let imageData = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: imageData)
    }
    
    func deleteImage(filename: String) {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try? fileManager.removeItem(at: fileURL)
    }
} 