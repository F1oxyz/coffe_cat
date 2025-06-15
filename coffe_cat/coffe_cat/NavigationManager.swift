import SwiftUI

class NavigationManager: ObservableObject {
    @Published var currentScreen: Screen = .loading
    @Published var isAuthenticated = false
    
    //aqui se maneja la navegacion de la aplicación
    enum Screen {
        case loading
        case welcome
        case login
        case register
        case menu
        case productDetails(Drink)
        case addProduct
        case thankYou
    }
    
    func navigateTo(_ screen: Screen) {
        withAnimation {
            currentScreen = screen
        }
    }
    
    func handleSuccessfulLogin() {
        isAuthenticated = true
        navigateTo(.menu)
    }
    
    func handleSuccessfulRegistration() {
        isAuthenticated = true
        navigateTo(.menu)
    }
    
    func handleLogout() {
        isAuthenticated = false
        navigateTo(.welcome)
    }
} 
