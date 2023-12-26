//
//  shipmentModel.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import Foundation

class ShipmentModel: ObservableObject {
    @Published var userShipments: [Shipment] = []
    var appViewModel: AppViewModel

    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }

    func fetchUserShipments() {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/shipments?userId=\(self.appViewModel.userUid ?? "")") else {
            return
        }
        print("request \(url)")

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
                print(shipmentsResponse)
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
        shipmentWithUserId.userId = self.appViewModel.userUid ?? ""
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
    func forceUpdateShipment(shipment: Shipment, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/shipments/update_status") else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var shipmentWithUserId = shipment
        shipmentWithUserId.userId = self.appViewModel.userUid ?? ""
        do {
            let jsonData = try JSONEncoder().encode(shipmentWithUserId)
            request.httpBody = jsonData
        } catch {
            print("Erro ao codificar JSON: \(error)")
            completion(false)
            return
        }
        let apiRequest = ApiRequest()
        apiRequest.performDataTask(with: request, decodingType: UpdateStatusShipmentResponse.self){ (result: Result<UpdateStatusShipmentResponse, Error>) in
            switch result {
            case .success(let responseData):
                // Lógica para lidar com a conclusão bem-sucedida
                if (responseData.status == "error"){
                    completion(false)
                    print("O SHIPMENT UPDATE STATUS falhou. Erro: \(responseData.message)")
                    return
                }
                print("A solicitação foi bem-sucedida! \(responseData)")
                self.fetchUserShipments()
                completion(true)
            case .failure(let error):
                // Lógica para lidar com a conclusão mal-sucedida
                print("O SHIPMENT UPDATE STATUS falhou. Erro: \(error)")
                completion(false)
            }
        }

    }
    
    func deleteShipment(_ shipment: Shipment, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(NetworkConfiguration.baseURL)/shipments?userId=\(self.appViewModel.userUid ?? "")&shipmentNumber=\(shipment.shipmentNumber)") else {
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
