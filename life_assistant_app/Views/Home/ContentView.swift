import SwiftUI

extension Double {
    func formatted() -> String {
        return String(format: "%.2f", self)
    }
}


struct ContentView: View {
    var body: some View {
        NavigationView {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                // Primeira aba
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
    @StateObject var viewModel = ViewModel()
    @State private var month: Int
    @State private var year: Int
    @State private var limit = 5
    private var dateFormatter = DateFormatter()
    @State private var isShowingTransactionForm = false
    @State private var fetchesPerformed = false
    

    init() {
        // Inicialize com o mês e ano atuais
        let currentDate = Date()
        self._month = State(initialValue: Calendar.current.component(.month, from: currentDate))
        self._year = State(initialValue: Calendar.current.component(.year, from: currentDate))
        dateFormatter.dateFormat = "dd/MM/yyyy"
    }

    var body: some View {
        VStack {
            ZStack {
                Color.blue
                    .ignoresSafeArea()

                VStack {
                    Text("Finanças")
                        .foregroundColor(.white)
                        .font(.largeTitle.bold())
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                }
            }
            .frame(height: 200)

            VStack {
                HStack {
                    Button(action: {
                        // Lógica para diminuir o mês
                        if month == 1 {
                            month = 12
                            year -= 1
                        } else {
                            month -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                    }

                    Text("\(viewModel.withdrawResponse?.message ?? "")")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                        .padding(.bottom, 0)
                        .lineLimit(1)
                        .frame(alignment: .center)

                    Button(action: {
                        if month == 12 {
                            month = 1
                            year += 1
                        } else {
                            month += 1
                        }
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
                        Text("Últimas transações")
                            .font(.headline)
                            .padding(.bottom, 5)

                        List {
                            ForEach(viewModel.transactionResponse ?? [], id: \.self) { transaction in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(transaction.name)
                                            .font(.headline)
                                        Spacer()
                                        Text(transaction.timestamp)
                                    }

                                    HStack {
                                        Text("Valor:")
                                            .foregroundColor(.gray)

                                        Text("\(transaction.value.formatted())")
                                            .foregroundColor(transaction.income ? .green : .red)
                                    }
                                }
                            }
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10) // Ajuste o valor do raio conforme necessário
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1) // Adiciona uma borda cinza com largura de 1 ponto
                                )                        }
                        .listStyle(PlainListStyle())
                    }
                    .padding()
                }
                .sheet(isPresented: $isShowingTransactionForm) {
                    TransactionFormView(viewModel: viewModel)
                }

                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        Button(action: {
                            isShowingTransactionForm = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .frame(width: 50, height: 50)
                                .cornerRadius(20)
                                .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            if !fetchesPerformed {
                viewModel.fetchAll(month: month, year: year, limit: limit)
                fetchesPerformed = true
            }
        }
        .onChange(of: month) { newMonth in
            // Chamado quando o valor de month muda
            viewModel.fetchExpenses(month: newMonth, year: year)
            viewModel.fetchIncomes(month: newMonth, year: year)
            viewModel.fetchWithdraw(month: newMonth, year: year)
        }
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
        ShipmentListView(viewModel: ShipmentModel())
    }
}


