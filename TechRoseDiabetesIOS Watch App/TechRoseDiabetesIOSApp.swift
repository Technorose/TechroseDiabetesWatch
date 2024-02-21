//
//  TechRoseDiabetesIOSApp.swift
//  TechRoseDiabetesIOS Watch App
//
//  Created by Zülfücan Karakuş on 17.02.2024.
//

import SwiftUI

@main
struct TechRoseDiabetesIOSApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}

struct SplashView: View {
    @State var isActive: Bool = false

    var body: some View {
        VStack {
            if self.isActive {
                ContentView()
            } else {
                Image("LaunchImage") // Resmin adını buraya yazın
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .background(Color("Color")) // Arka plan rengini ayarlayın
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { // 2.5 saniye sonra geçiş yap
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}


struct TechRoseDiabetesIOS_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
