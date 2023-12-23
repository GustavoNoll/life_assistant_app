//
//  shipmentModel.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import Foundation

class ShipmentModel: ObservableObject {
    @Published var userShipments: [Shipment] = []
    @Published var userId: String = "6584851c1998d9f468e442fc"

    func fetchUserShipments() {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/shipments?userId=\(self.userId)") else {
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
                let shipmentsResponse = try JSONDecoder().decode(UserShipmentsResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.userShipments = shipmentsResponse.userShipments
                }
            } catch {
                print("Erro ao decodificar JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func createShipment(shipment: Shipment, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/shipments") else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var shipmentWithUserId = shipment
        shipmentWithUserId.userId = self.userId
        do {
            let jsonData = try JSONEncoder().encode(shipmentWithUserId)
            request.httpBody = jsonData
        } catch {
            print("Erro ao codificar JSON: \(error)")
            completion(false)
            return
        }
        let apiRequest = ApiRequest()
        apiRequest.performDataTask(with: request, decodingType: CreateShipmentResponse.self){ (result: Result<CreateShipmentResponse, Error>) in
            switch result {
            case .success(let responseData):
                // Lógica para lidar com a conclusão bem-sucedida
                if (responseData.status == "error"){
                    completion(false)
                    print("A solicitação falhou. Erro: \(responseData.message)")
                    return
                }
                print("A solicitação foi bem-sucedida! \(responseData)")
                self.fetchUserShipments()
                completion(true)
            case .failure(let error):
                // Lógica para lidar com a conclusão mal-sucedida
                print("A solicitação falhou. Erro: \(error)")
                completion(false)
            }
        }
    }
    
    func deleteShipment(_ shipment: Shipment, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/shipments?userId=\(userId)&shipmentNumber=\(shipment.shipmentNumber)") else {
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
}