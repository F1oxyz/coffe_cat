//
//  ContentView.swift
//  coffe_cat
//
//  Created by Daniel Arango on 13/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        Group {
            switch navigationManager.currentScreen {
            case .loading:
                LoadingScreen()
                    .environmentObject(navigationManager)
            case .welcome:
                WelcomeScreen()
                    .environmentObject(navigationManager)
            case .login:
                LoginScreen()
                    .environmentObject(navigationManager)
            case .register:
                RegisterScreen()
                    .environmentObject(navigationManager)
            case .menu:
                MenuScreen()
                    .environmentObject(navigationManager)
            case .productDetails(let drink):
                ProductDetailsScreen(drink: drink)
                    .environmentObject(navigationManager)
            case .addProduct:
                AddProductScreen()
                    .environmentObject(navigationManager)
            case .thankYou:
                ThankYouScreen()
                    .environmentObject(navigationManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
