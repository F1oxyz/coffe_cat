import SwiftUI

struct Drink: Identifiable {
    let id: String
    let name: String
    let price: Double
    let description: String
    let imageFilename: String
    let sizes: [String]
    
    var image: UIImage? {
        ImageStorageService.shared.loadImage(filename: imageFilename)
    }
 
    

    static func fromDictionary(_ dict: [String: Any], id: String) -> Drink? {
        guard let name = dict["name"] as? String,
              let price = dict["price"] as? Double,
              let description = dict["description"] as? String,
              let imageFilename = dict["imageFilename"] as? String,
              let sizes = dict["sizes"] as? [String] else {
            return nil
        }
        
        return Drink(
            id: id,
            name: name,
            price: price,
            description: description,
            imageFilename: imageFilename,
            sizes: sizes
        )
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "price": price,
            "description": description,
            "imageFilename": imageFilename,
            "sizes": sizes
        ]
    }
} 
