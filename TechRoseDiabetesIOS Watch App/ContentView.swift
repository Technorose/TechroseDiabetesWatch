//
//  ContentView.swift
//  TechRoseDiabetesIOS Watch App
//
//  Created by Zülfücan Karakuş on 17.02.2024.
//

import SwiftUI

struct ApiResponse: Decodable {
    var nutritions: [Nutrition]
}

struct Nutrition: Identifiable, Decodable {
    var id: Int
    var name: String
    var serving_size: Double
    var calorie: Double
    var sugar: Double
    var carbo_hydrate: Double
    var image: String
    var nutrition_type: NutritionType
}

struct NutritionType: Decodable {
    var nutrition_type_name: String
    var image: String
    var id: Int
}

class NutritionListViewModel: ObservableObject {
    @Published var nutritions: [Nutrition] = []
    @Published var searchText = ""
    @StateObject private var userData = UserData()

    func fetchNutritions() async {
            guard let url = URL(string: "https://techrosediabetesapi.somee.com/NutritionsList") else { return }
            var request = URLRequest(url: url)
            request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmdWxsX25hbWUiOiJNZWhtZXQgU29sYWsiLCJlbWFpbCI6ImtuZXRpY2MwQGdtYWlsLmNvbSIsImV4cCI6MTcxNjE0ODkxNCwiaXNzIjoiKmF6dXJld2Vic2l0ZXMubmV0IiwiYXVkIjoiKmF6dXJld2Vic2l0ZXMubmV0In0.ULRFXX6H7jelUFZf7CVomXzR6QEcgFxXzjrJlm0p_pQ", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Error: Invalid response or status code.")
                    return
                }
                
                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                DispatchQueue.main.async {
                    self.nutritions = decodedResponse.nutritions
                }
            } catch {
                print("Error fetching nutrition data: \(error.localizedDescription)")
            }
        }
    
    func totalCarbonhydrate(of nutritions: [Nutrition]) -> Int {
        Int(nutritions.reduce(0) { $0 + $1.carbo_hydrate })
        }
    
}


struct ContentView: View {
    @StateObject private var viewModel = NutritionListViewModel()
    @State private var selectedNutritions: [Nutrition] = []
    @State private var showProfileView = false
    @StateObject private var userData = UserData()

    var body: some View {
        NavigationView {
            ZStack{
                Color("Color").edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    TextField("Ara...", text: $viewModel.searchText)
                        .padding()
                        .background(Color("Color"))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    ForEach(viewModel.nutritions.filter { viewModel.searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(viewModel.searchText) }) { nutrition in
                        Button(action: {
                            if selectedNutritions.contains(where: { $0.id == nutrition.id }) {
                                selectedNutritions.removeAll { $0.id == nutrition.id }
                            } else {
                                selectedNutritions.append(nutrition)
                            }
                        }) {
                            HStack {
                                Text(nutrition.name)
                                    .padding()
                                Spacer()
                                if selectedNutritions.contains(where: { $0.id == nutrition.id }) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        self.showProfileView = true
                        userData.selectedNutritionCarbonhydrate = Double(viewModel.totalCarbonhydrate(of: selectedNutritions))
                    }) {
                        Text("Show Profile")
                            .foregroundColor(Color("Color"))
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .fontWeight(.bold)
                    }
                    .sheet(isPresented: $showProfileView) {
                        ProfileView(selectedNutritions: $selectedNutritions).environmentObject(userData)
                    }
                    .padding()

                    if !selectedNutritions.isEmpty {
                        VStack {
                            Text("Seçilenler:")
                            ForEach(selectedNutritions) { nutrition in
                                Text(nutrition.name)
                            }
                            Text("Toplam Karbonhidrat: \(viewModel.totalCarbonhydrate(of: selectedNutritions))")
                                                        .padding()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding()
                    }
                }
                .onAppear {
                    Task {
                            await viewModel.fetchNutritions()
                        }
                }
            }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ProfileView: View {
    @State private var weight: String = ""
        @State private var diabetesType: String = "Type 1"
        @State private var totalDailyDose: String = ""
        @State private var bloodSuggar: String = ""
    @EnvironmentObject var userData: UserData
    @Binding var selectedNutritions:[Nutrition]

        let diabetesTypes = ["Type 1", "Type 2"]
        @State private var navigateToContentView = false

        var body: some View {
            NavigationView {
                Form {
                    
                    Section(header: Text("Diabetes Information")) {
                        Picker("Diabetes Type", selection: $diabetesType) {
                            ForEach(diabetesTypes, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    
                    Section(header: Text("Blood Sugar")) {
                        TextField("Blood Sugar Value", text: $bloodSuggar)
                    }
                    
                    Section(header: Text("Personal Information")) {
                        TextField("Weight (kg)", text: $weight)
                            .disabled(!totalDailyDose.isEmpty)
                    }

                    Section(header: Text("Total Daily Dose")) {
                        TextField("Total Daily Dose (units)", text: $totalDailyDose)
                            .disabled(!weight.isEmpty)
                    }

                    Section {
                        Button("Save and Calculate") {
                            saveData()
                            navigateToContentView = true
                            selectedNutritions = []
                        }
                    }
                    .background(NavigationLink(destination: CalculateView(userData: userData).environmentObject(userData)) {
                        
                    })
                }
            }
        }
        
        private func saveData() {
            userData.bloodSugar = "250"
            userData.weight = "87"
            userData.diabetesType = diabetesType
            userData.totalDailyDose = "60"
        }

}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(selectedNutritions: .constant([])).environmentObject(UserData())
    }
}

class UserData: ObservableObject {
    @Published var bloodSugar: String = ""
    @Published var weight: String = ""
    @Published var diabetesType: String = ""
    @Published var totalDailyDose: String = ""
    @Published var selectedNutritionCarbonhydrate: Double = 0
}

struct CalculateView: View {
    @ObservedObject var userData: UserData

        let hedefKanSekeri: Double = 100
    
        var karbonhidratMiktari: Double {
            userData.selectedNutritionCarbonhydrate
        }

    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                Text("Diyabet Tipi:")
                Text("\(userData.diabetesType)")
                    .padding(.bottom)
                
                Text("Kan Şekeri Değeri:")
                Text("\(userData.bloodSugar)")
                    .padding(.bottom)
                
                Text("Ağırlık:")
                Text("\(userData.weight) kg")
                    .padding(.bottom)
                
                Text("Toplam Günlük Doz:")
                Text("\(userData.totalDailyDose) ünit")
                    .padding(.bottom)
                
                Text("Toplam Kalori Değeri:")
                Text("\(userData.selectedNutritionCarbonhydrate, specifier: "%.1f") kalori")
                    .padding(.bottom)
                
                let gunlukToplamInsulinDozu = Double(userData.totalDailyDose) ?? 0
                let mevcutKanSekeri = Double(userData.bloodSugar) ?? 0
                
                let insulinDuyarlilikFaktoru = hesaplaInsulinDuyarlilikFaktoru(gunlukToplamInsulinDozu: gunlukToplamInsulinDozu, diyabetTipi: userData.diabetesType)
                let karbonhidratInsulinOrani = hesaplaKarbonhidratInsulinOrani(gunlukToplamInsulinDozu: gunlukToplamInsulinDozu)
                let duzeltmeDozu = hesaplaDuzeltmeDozu(mevcutKanSekeri: mevcutKanSekeri, hedefKanSekeri: hedefKanSekeri, insulinDuyarlilikFaktoru: insulinDuyarlilikFaktoru)
                let ogunIcinGerekliInsulin = hesaplaOgunIcinGerekliInsulin(karbonhidratMiktari: karbonhidratMiktari, karbonhidratInsulinOrani: karbonhidratInsulinOrani)
                
                Text("İnsülin Duyarlılık Faktörü:")
                Text("\(insulinDuyarlilikFaktoru, specifier: "%.2f")")
                    .padding(.bottom)
            
                Text("Karbonhidrat İnsülin Oranı:")
                Text("\(karbonhidratInsulinOrani, specifier: "%.2f")")
                    .padding(.bottom)
                
                Text("Öğün İçin Gerekli İnsülin Dozu:")
                Text("\(ceil(ogunIcinGerekliInsulin), specifier: "%.0f") ünite")
                    .padding(.bottom)
                
                Text("Kan Şekeri Düzenleme Dozu:")
                Text("\(duzeltmeDozu, specifier: "%.0f") ünite")
                    .padding(.bottom)
            }
        }
            .padding()
        }

        // MARK: - Hesaplama Fonksiyonları

        func hesaplaInsulinDuyarlilikFaktoru(gunlukToplamInsulinDozu: Double, diyabetTipi: String) -> Double {
            if diyabetTipi == "Type 1" {
                return 1800 / Double(gunlukToplamInsulinDozu)
            } else {
                return 1500 / Double(gunlukToplamInsulinDozu)
            }
        }

        func hesaplaKarbonhidratInsulinOrani(gunlukToplamInsulinDozu: Double) -> Double {
            return 500 / Double(gunlukToplamInsulinDozu)
        }

        func hesaplaDuzeltmeDozu(mevcutKanSekeri: Double, hedefKanSekeri: Double, insulinDuyarlilikFaktoru: Double) -> Double {
            return (Double(mevcutKanSekeri) - Double(hedefKanSekeri)) / Double(insulinDuyarlilikFaktoru)
        }

        func hesaplaOgunIcinGerekliInsulin(karbonhidratMiktari: Double, karbonhidratInsulinOrani: Double) -> Double {
            return Double(karbonhidratMiktari) / Double(karbonhidratInsulinOrani)
        }
}

struct CalculateView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUserData = UserData()
        CalculateView(userData: sampleUserData)
    }
}
