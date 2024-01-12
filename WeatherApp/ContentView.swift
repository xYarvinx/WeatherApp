import SwiftUI

struct WeatherData {
    let temperature: Double
    let weatherDescription: String
    let windSpeed: Double
    let windDirection: String
    let humidity: Int
}

import Foundation

struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Double
}

class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    let apiKey = "ba2e7e143b3467279d060010595cd481"
    func fetchWeatherData(for city: String) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Ошибка при получении данных о погоде: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let decodedResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data) {
                let weather = decodedResponse.weather.first?.description ?? "Unknown"
                let temperature = decodedResponse.main.temp
                let windSpeed = decodedResponse.wind.speed
                let windDirection = decodedResponse.wind.deg
                let humidity = decodedResponse.main.humidity
                
                let weatherData = WeatherData(temperature: temperature, weatherDescription: weather, windSpeed: windSpeed, windDirection: "\(windDirection)°", humidity: humidity)
                
                DispatchQueue.main.async {
                    self.weatherData = weatherData
                }
            } else {
                print("Не удалось обработать данные о погоде")
            }
        }
        
        task.resume()
    }
}


struct ContentView: View {
    @StateObject var viewModel = WeatherViewModel()
    @State var city: String = ""
    
    var body: some View {
        VStack {
            TextField("Введите название города", text: $city, onCommit: {
                viewModel.fetchWeatherData(for: city)
            })
            .padding()
            .font(.title)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let weatherData = viewModel.weatherData {
                VStack(spacing: 10) {
                    Text("Погода в городе \(city)")
                        .font(.largeTitle)
                    Text("Температура: \(weatherData.temperature, specifier: "%.1f")°C")
                    Text("Погода: \(weatherData.weatherDescription)")
                    Text("Скорость ветра: \(weatherData.windSpeed) м/с")
                    Text("Направление ветра: \(weatherData.windDirection)")
                    Text("Влажность: \(weatherData.humidity)%")
                    Spacer()
                }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.white.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(20)
                .padding()
                .foregroundColor(.black)
            } else {
                Text("Загрузка данных о погоде...")
                    .font(.title)
                    .onAppear {
                        viewModel.fetchWeatherData(for: "Москва")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
