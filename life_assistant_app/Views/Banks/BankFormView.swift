import SwiftUI

struct BankFormView: View {
    @ObservedObject var viewModel: BankModel
    @State private var bankName = ""
    @State private var bankBalance = 0
    @State private var errorMessage = ""
    @State private var alertMessage: String?
    @State private var isShowingAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isAddingBank = false
    @State private var alertType: AlertType?
    private var numberFormatter: NumberFormatter
    
    init(viewModel: BankModel) {
        self.viewModel = viewModel
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .currency
        self.numberFormatter.maximumFractionDigits = 2
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Detalhes do Banco")) {
                    TextField("Nome do Banco", text: $bankName).disableAutocorrection(true)
                    CurrencyTextField(numberFormatter: numberFormatter, value: $bankBalance)
                        .keyboardType(.numberPad)
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
                            postBank()
                            withAnimation {
                                isAddingBank.toggle()
                            }
                        } else {
                            errorMessage = "Todos os campos são obrigatórios"
                        }
                    }) {
                        Text("Adicionar Banco")
                            .foregroundColor(!isAddingBank ? .blue : Color.gray)
                    }
                    .disabled(isAddingBank)
                }
            }
            .overlay(
                alertMessage.map { message in
                    BannerView(message: message, alertType: alertType)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    alertMessage = nil
                                    if alertType == .success {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                }
            )
            
        }
        .navigationTitle("Novo Banco")
    }
    
    private func areFieldsValid() -> Bool {
        return !bankName.isEmpty && bankBalance > 0
    }

    private func postBank() {
        let bank = BankRequest(_id: "", name: bankName, balance: Double(bankBalance) / 100.0)
        
        viewModel.createBank(bank: bank) { success in
            if success {
                alertMessage = "Banco criado com sucesso!"
                alertType = .success
            } else {
                alertMessage = "Erro ao adicionar banco. Tente novamente."
                alertType = .error
                isAddingBank.toggle()
            }
            isShowingAlert = true
        }
    }
}

struct BankFormView_Previews: PreviewProvider {
    static var previews: some View {
        let userViewModel = AppViewModel()
        let viewModel = BankModel(appViewModel: userViewModel)
        BankFormView(viewModel: viewModel)
    }
}
