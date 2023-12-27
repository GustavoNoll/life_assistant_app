//
//  ViewModel.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import Foundation

class ViewModel: ObservableObject {
    @Published var transactionResponse: [Transaction]?
    @Published var withdrawResponse: WithdrawResponse?
    @Published var userBanks: [UserBank] = []
    var appViewModel: AppViewModel

    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    func fetchAll(month: Int? = nil, year: Int? = nil, limit: Int? = nil){
        fetchWithdraw(month: month, year: year)
        fetchTransactions(month: month, year: year, limit: limit)
        fetchUserBanks()
    }
    func confirmPay(_ transaction: Transaction, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/finances/transactions/confirm_pay") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(["transactionId": transaction._id])
            request.httpBody = jsonData
        } catch {
            print("Erro ao codificar dados para JSON: \(error)")
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Erro na solicitação PATCH: \(error)")
                completion(false)
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let responseData = try decoder.decode(TransactionResponse.self, from: data)
                    if responseData.status != "success" {
                        print("Erro na solicitação PATCH: \(responseData.message)")
                        completion(false)
                        return
                    }
                    if let index = self.transactionResponse?.firstIndex(where: { $0._id == transaction._id }) {
                        self.transactionResponse?[index].isPaid = true
                    }
                    //self.fetchAll()
                    completion(true)
                } catch {
                    print("Erro ao decodificar JSON: \(error)")
                    completion(false)
                }
            } else {
                print("Resposta do servidor não contém dados.")
                completion(false)
            }
        }
        task.resume()
    }
    func deleteTransaction(_ transaction: Transaction, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/finances/transactions?transactionId=\(transaction._id)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let apiRequest = ApiRequest()
        apiRequest.performDataTask(with: request, decodingType: deleteResponse.self){ (result: Result<deleteResponse, Error>) in
            switch result {
            case .success(let responseData):
                // Lógica para lidar com a conclusão bem-sucedida
                if (responseData.status == "error"){
                    completion(false)
                    print("A solicitação falhou. Erro: \(responseData.message)")
                    return
                }
                print("A solicitação foi bem-sucedida! \(responseData)")
                completion(true)
            case .failure(let error):
                // Lógica para lidar com a conclusão mal-sucedida
                print("A solicitação falhou. Erro: \(error)")
                completion(false)
            }
        }
    }
    
    func postTransaction(transaction: Transaction, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/finances/transactions") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(transaction)
            request.httpBody = jsonData
        } catch {
            print("Erro ao codificar dados para JSON: \(error)")
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Erro na solicitação POST: \(error)")
                completion(false)
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let responseData = try decoder.decode(TransactionResponse.self, from: data)
                    print(responseData)
                    if responseData.status != "success" {
                        print("Erro na solicitação POST: \(responseData.message)")
                        completion(false)
                        return
                    }
                    self.fetchAll()
                    completion(true)
                } catch {
                    print("Erro ao decodificar JSON: \(error)")
                    completion(false)
                }
            } else {
                print("Resposta do servidor não contém dados.")
                completion(false)
            }
        }
        task.resume()
    }

    func fetchUserBanks() {
        
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/finances/user_banks?userId=\(self.appViewModel.userUid ?? "")") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Erro na requisição: \(error?.localizedDescription ?? "Erro desconhecido")")
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON decodificado (UserBank):", jsonString)
            }
            do {
                let userBanksResponse = try JSONDecoder().decode(UserBanksResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.userBanks = userBanksResponse.banks
                }
            } catch {
                print("Erro ao decodificar JSON (UserBank): \(error)")
            }
        }
        task.resume()
    }
    func fetchTransactions(month: Int? = nil, year: Int? = nil, limit: Int? = nil) {
        var queryString = "user_transactions?userId=\(self.appViewModel.userUid ?? "")"
        
        if let month = month, let year = year {
            queryString += "&month=\(month)&year=\(year)"
        }
        
        if let limit = limit {
            queryString += "&limit=\(limit)"
        }
        print("fetch transaction\(queryString)")
        
        fetchData(endpoint: queryString) { [weak self] (response: TransactionsResponse) in
            DispatchQueue.main.async {
                self?.transactionResponse = response.transactions
            }
        }
    }


    func fetchWithdraw(month: Int? = nil, year: Int? = nil) {
        var queryString = "user_withdraw?userId=\(self.appViewModel.userUid ?? "")"
        
        if let month = month, let year = year {
            queryString += "&month=\(month)&year=\(year)"
        }
        
        fetchData(endpoint: queryString) { [weak self] (response: WithdrawResponse) in
            DispatchQueue.main.async {
                self?.withdrawResponse = response
            }
        }
    }

    private func fetchData<T: Decodable>(endpoint: String, completion: @escaping (T) -> Void) {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/finances/\(endpoint)") else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Erro na requisição: \(error?.localizedDescription ?? "Erro desconhecido")")
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(T.self, from: data)
                completion(responseObject)
            } catch {
                print("Erro ao decodificar JSON: \(error)")
            }
        }
        task.resume()
    }
}

