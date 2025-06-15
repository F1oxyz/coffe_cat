import SwiftUI
import Foundation

class ImageStorageService {
    static let shared = ImageStorageService()
    private let fileManager = FileManager.default
    
    private init() {}
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var imagesDirectory: URL {
        documentsDirectory.appendingPathComponent("ProductImages")
    }
    
    func saveImage(_ image: UIImage) throws -> String {
        // Create images directory if it doesn't exist
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
        
        // Generate unique filename
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        // Convert image to data and save
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageStorageService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        try imageData.write(to: fileURL)
        return filename
    }
    
    func loadImage(filename: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        guard let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func deleteImage(filename: String) throws {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try fileManager.removeItem(at: fileURL)
    }
} 