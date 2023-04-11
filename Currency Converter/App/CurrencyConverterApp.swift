//
//  Currency_ConverterApp.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/15/22.
//

import SwiftUI

@main
struct CurrencyConverterApp: App {
    @State var isSplashShown = false
    var body: some Scene {
        WindowGroup {
            CurrencyConverterView().transition(.opacity)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // Lazy load of "viewContext"
        }
    }
}
