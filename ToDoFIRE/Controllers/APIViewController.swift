//
//  APIViewController.swift
//  ToDoFIRE
//
//  Created by Zhanibek Bakyt on 02.06.2025.
//

import UIKit

class APIViewController: UIViewController {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        temperatureLabel.text = ""
        descriptionLabel.text = ""
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = .gray
        
        showLoading(true)
        fetchWeather()
    }
    
    func fetchWeather() {
        let latitude = 43.2389
        let longitude = 76.8897
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.showLoading(false)
                self.showError("Некорректный URL")
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.showLoading(false)
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.showError("Ошибка загрузки: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.showError("Нет данных от сервера")
                }
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let current = weatherResponse.current_weather
                
                guard current.temperature != 0 else {
                    DispatchQueue.main.async {
                        self?.showError("Нет данных о погоде")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.temperatureLabel.text = "\(current.temperature)°C"
                    self?.descriptionLabel.text = "Ветер: \(current.windspeed) км/ч"
                }
                
            } catch {
                DispatchQueue.main.async {
                    self?.showError("Ошибка обработки данных")
                }
            }
        }.resume()
    }
    
    func showLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            if loading {
                self.activityIndicator.startAnimating()
                self.temperatureLabel.isHidden = true
                self.descriptionLabel.isHidden = true
            } else {
                self.activityIndicator.stopAnimating()
                self.temperatureLabel.isHidden = false
                self.descriptionLabel.isHidden = false
            }
        }
    }
    
    func showError(_ message: String) {
        temperatureLabel.text = "Ошибка"
        descriptionLabel.text = message
    }
}
