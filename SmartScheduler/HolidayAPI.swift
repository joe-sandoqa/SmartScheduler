//
//  HolidayAPI.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa on 4/15/25.
//
import Foundation
struct Holiday: Decodable {
    let date: String
    let localName: String
    let name: String
    let countryCode: String
    let fixed: Bool
    let global: Bool
}
class HolidayAPIManager {
    static let shared = HolidayAPIManager()
    func fetchHolidays(for year: Int = Calendar.current.component(.year, from: Date()), countryCode: String = "US", completion: @escaping ([Holiday]) -> Void) {
        guard let url = URL(string: "https://date.nager.at/api/v3/PublicHolidays/\(year)/\(countryCode)") else {
            print("Error: Cannot create URL")
            return}
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error: \(error)")
                return}
            guard let data = data else {return }
            do{
                let holidays = try JSONDecoder().decode([Holiday].self, from: data)
                DispatchQueue.main.async {
                    completion(holidays)}
            }catch{
            print("Error: \(error)")
        }
        }.resume()}}
