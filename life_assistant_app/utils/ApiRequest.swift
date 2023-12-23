//
//  ApiRequest.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import Foundation


struct ApiRequest {
    func performDataTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Erro na solicitação POST: \(error)")
                completion(.failure(error))
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let responseData = try decoder.decode(decodingType, from: data)

                    completion(.success(responseData))
                } catch {
                    print("Erro ao decodificar JSON: \(error)")
                    completion(.failure(error))
                }
            } else {
                print("Resposta do servidor não contém dados.")
                completion(.failure(NSError(domain: "EmptyResponse", code: 0, userInfo: nil)))
            }
        }
        task.resume()
    }
}
