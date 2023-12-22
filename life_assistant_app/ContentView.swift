import SwiftUI

extension Double {
    func formatted() -> String {
        return String(format: "%.2f", self)
    }
}

struct TransactionCategory: Hashable, Codable {
    let total: Double
}

struct TransactionResponse: Codable {
    let message: String
    let transactions: [String: TransactionCategory]
}

struct TransactionsResponse: Codable {
    let status: Int
    let message: String
    let transaction: Transaction
}

struct WithdrawResponse: Codable {
    let incomes: Double
    let expenses: Double
    let withdraw: Double
    let message: String
}

struct User: Codable {
    let userId: String
}
struct UserBank: Codable, Hashable {
    let _id: String
    let name: String
    let balance: Double
    let userId: String
    let __v: Int?
}

struct UserBanksResponse: Codable {
    let message: String
    let banks: [UserBank]
}
struct Transaction: Hashable, Codable {
    let name: String
    let value: Double
    let income: Bool
    let kind: String
    let scheduledDate: Date?
    let bankId: String
    let userId: String
}

struct TransactionFormView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var name = ""
    @State private var value = ""
    @State private var income = false
    @State private var kind = ""
    @State private var selectedBankIndex = 0
    @State private var scheduledDate = Date()
    @State private var errorMessage = ""
    @State private var isScheduled = false
    @State private var alertMessage: String?
    @State private var isShowingAlert = false
    @State private var alertStatus = ""
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }


    var body: some View {
        VStack {
            Form {
                Section(header: Text("Detalhes da Transação")) {
                    TextField("Nome", text: $name)
                    TextField("Valor", text: $value).keyboardType(.decimalPad)
                    
                    
                    Toggle("Receita", isOn: $income)
                    TextField("Categoria", text: $kind)
                    Picker("Banco", selection: $selectedBankIndex) {
                        ForEach(0..<viewModel.userBanks.count, id: \.self) { index in
                            Text(viewModel.userBanks[index].name)
                        }
                    }
                    .id(selectedBankIndex)
                    
                    Toggle("Agendar", isOn: $isScheduled.animation())
                    
                    if isScheduled {
                        DatePicker("Data Agendada", selection: $scheduledDate, displayedComponents: .date)
                    }
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
                        } else {
                            errorMessage = "Todos os campos são obrigatórios"
                        }
                    }) {
                        Text("Adicionar Transação")
                    }
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
        return !name.isEmpty && !value.isEmpty && !kind.isEmpty && selectedBankIndex >= 0
    }

    private func postTransaction() {

        let doubleValue = Double(value) ?? 0.0

        let transaction = Transaction(
            name: name,
            value: doubleValue, // Convertendo para Double, assumindo que "value" representa um valor numérico
            income: income,
            kind: kind,
            scheduledDate: isScheduled ? scheduledDate : nil,
            bankId: viewModel.userBanks[selectedBankIndex]._id, // Use o ID do banco selecionado
            userId: viewModel.userId
        )
        viewModel.postTransaction(transaction: transaction) { success in
            if success {
                alertMessage = "Transação criada com sucesso!"
                alertStatus = "OK"
            } else {
                alertMessage = "Erro ao adicionar transação. Tente novamente."
                alertStatus = "Error"
            }
            isShowingAlert = true
        }
    }
}

class ViewModel: ObservableObject {
    @Published var expenseResponse: TransactionResponse?
    @Published var incomeResponse: TransactionResponse?
    @Published var withdrawResponse: WithdrawResponse?
    @Published var userBanks: [UserBank] = []
    @Published var userId: String = "6584851c1998d9f468e442fc"
    
    func postTransaction(transaction: Transaction, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3008/finances/transactions") else {
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
                    let responseData = try decoder.decode(TransactionsResponse.self, from: data)
                    
                    print("Mensagem: \(responseData.status)")
                    print("Nome da Transação: \(responseData.message)")
                    
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
        
        guard let url = URL(string: "http://localhost:3008/finances/user_banks?userId=\(self.userId)") else { return }
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
    func fetchExpenses() {
        fetchData(urlString: "http://localhost:3008/finances/user_expenses")
    }

    func fetchIncomes() {
        fetchData(urlString: "http://localhost:3008/finances/user_incomes")
    }

    func fetchWithdraw() {
        guard let url = URL(string: "http://localhost:3008/finances/user_withdraw?userId=\(self.userId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Erro na requisição: \(error?.localizedDescription ?? "Erro desconhecido")")
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON decodificado (Withdraw):", jsonString)
            }
            do {
                let withdrawResponse = try JSONDecoder().decode(WithdrawResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.withdrawResponse = withdrawResponse
                }
            } catch {
                print("Erro ao decodificar JSON (Withdraw): \(error)")
            }
        }
        task.resume()
    }

    private func fetchData(urlString: String) {
        guard let url = URL(string: "\(urlString)?userId=\(self.userId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Erro na requisição: \(error?.localizedDescription ?? "Erro desconhecido")")
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON decodificado:", jsonString)
            }
            do {
                let transactionResponse = try JSONDecoder().decode(TransactionResponse.self, from: data)
                DispatchQueue.main.async {
                    if urlString.contains("user_expenses") {
                        self?.expenseResponse = transactionResponse
                    } else if urlString.contains("user_incomes") {
                        self?.incomeResponse = transactionResponse
                    }
                }
            } catch {
                print("Erro ao decodificar JSON: \(error)")
            }
        }
        task.resume()
    }
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            TabView {
                // Primeira aba
                VStack {
                    ZStack {
                        Color.blue
                            .ignoresSafeArea()

                        VStack {
                            Text("Finanças")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                        }
                    }.frame(height: 200)
                    VStack {
                        HStack {
                            Button(action: {
                            }) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .resizable()
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                            }
                            Text("\(viewModel.withdrawResponse?.message ?? "")")
                                .font(.title)
                                .foregroundColor(.blue)
                                .padding(.bottom, 0)
                                .lineLimit(1)
                                .frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            Button(action: {
                            }) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .resizable()
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                            }
                        }

                        HStack {
                            Text("Saldo:")
                                .font(.headline)
                            Text("\((viewModel.withdrawResponse?.withdraw ?? 0).formatted())")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(viewModel.withdrawResponse?.withdraw ?? 0 >= 0 ? .green : .red)
                        }
                        .padding(.bottom, 5)

                        HStack {
                            Text("Despesas:")
                                .font(.subheadline)
                            Text("\((viewModel.withdrawResponse?.expenses ?? 0).formatted())")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.trailing, 20)

                            Text("Receitas:")
                                .font(.subheadline)
                            Text("\((viewModel.withdrawResponse?.incomes ?? 0).formatted())")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()

                    ZStack {
                        HStack {
                            VStack {
                                Text("Últimas Despesas")
                                    .font(.title3)
                                    .padding(.bottom, 5)

                                List {
                                    ForEach(viewModel.expenseResponse?.transactions.keys.sorted() ?? [], id: \.self) { category in
                                        if let transaction = viewModel.expenseResponse?.transactions[category] {
                                            VStack(alignment: .leading) {
                                                Text(category)
                                                    .font(.headline)
                                                Text("Total: \(transaction.total.formatted())")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .listStyle(PlainListStyle())
                            }
                            .padding()

                            VStack {
                                Text("Últimas Receitas")
                                    .font(.title3)
                                    .padding(.bottom, 5)

                                List {
                                    ForEach(viewModel.incomeResponse?.transactions.keys.sorted() ?? [], id: \.self) { category in
                                        if let transaction = viewModel.incomeResponse?.transactions[category] {
                                            VStack(alignment: .leading) {
                                                Text(category)
                                                    .font(.headline)
                                                Text("Total: \(transaction.total.formatted())")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .listStyle(PlainListStyle())
                                
                            }
                            .padding()
                        }
                        
                        HStack {
                            Spacer()
                            NavigationLink(destination: TransactionFormView(viewModel: viewModel).onAppear{
                                viewModel.fetchUserBanks()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .foregroundColor(.blue)
                                    .background(Color.white)
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(20)
                                    .padding()
                            }
                            .padding(.top, 200)

                        }
                    }

                }
                .navigationTitle("")
                .navigationBarHidden(true)
                .onAppear {
                    viewModel.fetchExpenses()
                    viewModel.fetchIncomes()
                    viewModel.fetchWithdraw()
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                BanksView()
                .tabItem {
                    Label("Bancos", systemImage: "bag.fill")
                }
                TransactionsView()
                .tabItem {
                    Label("Transações", systemImage: "arrow.right.arrow.left")
                }
                shipmentView()
                .tabItem {
                    Label("Encomendas", systemImage: "shippingbox")
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HomeView: View {
    var body: some View {
        // Conteúdo da visualização principal (Home)
        Text("Home View")
    }
}

struct BanksView: View {
    var body: some View {
        Text("Conteúdo de Bancos")
    }
}

struct TransactionsView: View {
    var body: some View {
        Text("Conteúdo de Transações")
    }
}

struct shipmentView: View {
    var body: some View {
        Text("Conteúdo de Encomendas")
    }
}


