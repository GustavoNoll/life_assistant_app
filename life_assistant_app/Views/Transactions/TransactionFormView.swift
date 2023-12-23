//
//  TransactionFormView.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import SwiftUI

struct TransactionFormView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var name = ""
    @State private var value = 0
    @State private var income = false
    @State private var kind = ""
    @State private var selectedBankIndex = 0
    @State private var errorMessage = ""
    @State private var alertMessage: String?
    @State private var isShowingAlert = false
    @State private var alertStatus = ""
    private var numberFormatter: NumberFormatter
    @Environment(\.presentationMode) var presentationMode
    @State private var isAddingShipment = false
    
    init(viewModel: ViewModel, numberFormatter: NumberFormatter = NumberFormatter()) {
        self.viewModel = viewModel
        self.numberFormatter = numberFormatter
        self.numberFormatter.numberStyle = .currency
        self.numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Detalhes da Transação")) {
                    TextField("Nome", text: $name)
                    CurrencyTextField(numberFormatter: numberFormatter, value: $value)
                    Toggle("Receita", isOn: $income)
                    TextField("Categoria", text: $kind)
                    Picker("Banco", selection: $selectedBankIndex) {
                        ForEach(0..<viewModel.userBanks.count, id: \.self) { index in
                            Text(viewModel.userBanks[index].name)
                        }
                    }
                    .id(selectedBankIndex)
                    
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
                            postTransaction()
                            withAnimation {
                                isAddingShipment.toggle()
                            }
                        } else {
                            errorMessage = "Todos os campos são obrigatórios"
                        }
                    }) {
                        Text("Adicionar Transação")
                            .foregroundColor(!isAddingShipment ? .blue : Color.gray)
                    }
                    .disabled(isAddingShipment)
                }
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Status da Transação"),
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
        return !name.isEmpty && (value > 0) && !kind.isEmpty && selectedBankIndex >= 0 && viewModel.userBanks.count > 0
    }

    private func postTransaction() {
        let transaction = Transaction(
            name: name,
            value: Double(value) / 100.0,
            income: income,
            kind: kind,
            bankId: viewModel.userBanks[selectedBankIndex]._id, // Use o ID do banco selecionado
            userId: viewModel.userId,
            timestamp: ""
        )
        viewModel.postTransaction(transaction: transaction) { success in
            if success {
                alertMessage = "Transação criada com sucesso!"
                alertStatus = "OK"
            } else {
                alertMessage = "Erro ao adicionar transação. Tente novamente."
                alertStatus = "Error"
                isAddingShipment.toggle()
            }
            isShowingAlert = true
        }
    }
}