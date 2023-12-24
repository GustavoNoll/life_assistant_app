//
//  ShipmentFormView.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import SwiftUI

struct ShipmentFormView: View {
    @ObservedObject var viewModel: ShipmentModel
    @State private var cod = ""
    @State private var errorMessage = ""
    @State private var alertMessage: String?
    @State private var isShowingAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isAddingShipment = false
    @State private var alertType: AlertType?
    
    init(viewModel: ShipmentModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Detalhes da Encomenda")) {
                    TextField("Código", text: $cod)
                }
                
                Section {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        // Realiza a chamada POST apenas se todos os campos obrigatórios estiverem preenchidos
                        if areFieldsValid() {
                            errorMessage = ""
                            postShipment()
                            withAnimation {
                                isAddingShipment.toggle()
                            }
                        } else {
                            errorMessage = "Todos os campos são obrigatórios"
                        }

                    }) {
                        Text("Adicionar encomenda")
                            .foregroundColor(!isAddingShipment ? .blue : Color.gray)
                    }
                    .disabled(isAddingShipment)
                }
            }
            .overlay(
                alertMessage.map { message in
                    BannerView(message: message, alertType: alertType)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    alertMessage = nil
                                    if alertType == .success { presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                }
            )
            
        }
        .navigationTitle("Nova Transação")
    }
    private func areFieldsValid() -> Bool {
        return !cod.isEmpty
    }

    private func postShipment() {
        let shipment = Shipment(
            shipmentNumber: cod
        )
        viewModel.createShipment(shipment: shipment) { success in
            if success {
                alertMessage = "Encomenda criada com sucesso!"
                alertType = .success
            } else {
                alertMessage = "Erro ao adicionar encomenda. Tente novamente."
                alertType = .error
                isAddingShipment.toggle()
                
            }
            isShowingAlert = true
        }
    }

}

struct ShipmentFormView_Previews: PreviewProvider {
    static var previews: some View {
        ShipmentFormView(viewModel: ShipmentModel())
    }
}
