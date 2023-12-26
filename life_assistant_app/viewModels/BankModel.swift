//
//  BankModel.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 26/12/23.
//

import Foundation

struct BankRequest: Codable {
    let _id: String?
    let name: String
    let balance: Double
    var userId: String?
}

struct BankResponse: Codable {
    let _id: String
    let name: String
    let balance: Double
    let userId: String
    let __v: Int
}

struct BanksResponse: Codable {
    let status: String
    let message: String
    let banks: [BankResponse]
}

struct createBanksResponse: Codable {
    let status: String
    let message: String
    let bank: BankResponse
}

class BankModel: ObservableObject {
    @Published var userBanks: [BankResponse] = []
    var appViewModel: AppViewModel

    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }

    func fetchUserBanks() {
        guard let userUid = self.appViewModel.userUid,
              let url = URL(string: "\(NetworkConfiguration.baseURL)/finances/user_banks?userId=\(userUid)") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Erro na requisição: \(error?.localizedDescription ?? "Erro desconhecido")")
                return
            }

            do {
                if let stringData = String(data: data, encoding: .ascii) {
                    print("String data: \(stringData)")
                } else {
                    print("Failed to convert data to string using ASCII encoding.")
                }
                let banksResponse = try JSONDecoder().decode(BanksResponse.self, from: data)
                print(banksResponse)
                DispatchQueue.main.async {
                    self?.userBanks = banksResponse.banks
                }
            } catch {
                print("Erro ao decodificar JSON: \(error)")
            }
        }
        task.resume()
    }

    func createBank(bank: BankRequest, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/finances/banks") else {
            completion(false)
            return
        }
        

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var bankWithUserId = bank
        bankWithUserId.userId = self.appViewModel.userUid ?? ""

        do {
            let jsonData = try JSONEncoder().encode(bankWithUserId)
            request.httpBody = jsonData
        } catch {
            print("Erro ao codificar JSON: \(error)")
            completion(false)
            return
        }

        let apiRequest = ApiRequest()
        apiRequest.performDataTask(with: request, decodingType:  createBanksResponse.self) { result in
            switch result {
            case .success(let createdBank):
                print("Banco criado com sucesso! \(createdBank)")
                self.fetchUserBanks()
                completion(true)
            case .failure(let error):
                print("A solicitação falhou. Erro: \(error)")
                completion(false)
            }
        }
    }
}

