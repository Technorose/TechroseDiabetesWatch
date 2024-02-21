# TechRoseDiabetesIOS Watch App

This project is designed to help individuals with diabetes manage their nutrition intake by tracking the nutritional values of different foods. It's a SwiftUI application for iOS and watchOS that allows users to search for foods, view their nutritional information, and calculate their total carbohydrate intake.

## Features

- Fetch nutrition data from a remote API.
- Search functionality to filter through the nutrition list.
- Select and track multiple nutrition items.
- Calculate the total carbohydrate of selected items.
- Profile view to input and save user's personal and diabetes-related information.
- CalculateView to provide insulin dosage recommendations based on user input and selected nutrition items.

## Models

### ApiResponse
A model to decode the JSON response from the API, containing an array of `Nutrition` objects.

### Nutrition
Represents nutrition information, including id, name, serving size, calorie, sugar, carbohydrate, image, and nutrition type.

### NutritionType
Defines the type of nutrition, including a name, image, and id.

## ViewModel

### NutritionListViewModel
Manages the fetching of nutrition data from the API, searching, and calculation of total carbohydrates.

## Views

### ContentView
The main view that displays the list of nutritions, search bar, selected nutrition items, and navigation to the profile view.

### ProfileView
Allows users to input their diabetes type, blood sugar level, weight, and total daily dose of insulin. This data is then used in the CalculateView to provide personalized insulin dosage recommendations.

### CalculateView
Calculates and displays insulin dosage recommendations based on the user's profile information and selected nutrition items.

## How to Run

1. Clone the repository.
2. Open the project in Xcode.
3. Make sure you have a valid developer account set up in Xcode to run on an iOS device or simulator.
4. Build and run the application.

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5

## Author

TechRose Team
