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
    @State private var alertStatus = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isAddingShipment = false
    
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
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Status da Encomenda"),
                message: Text(alertMessage ?? ""),
                dismissButton: .default(Text(alertStatus)) {
                    // Faça algo quando o usuário tocar em "OK", se necessário
                    presentationMode.wrappedValue.dismiss()
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
                alertStatus = "OK"
            } else {
                alertMessage = "Erro ao adicionar encomenda. Tente novamente."
                alertStatus = "Error"
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
