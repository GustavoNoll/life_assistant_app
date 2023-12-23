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
    @State private var limit = 7
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
        ScrollView {
            ZStack {
                ZStack {
                    Color.blue
                        .ignoresSafeArea()
                    
                    Text("Finanças")
                        .foregroundColor(.white)
                        .font(.largeTitle.bold())
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                }
            }
            .frame(height: 250)
            Spacer()
            VStack {
                HStack {
                    Text("Balanço do mês")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                        .padding(.bottom, 0)
                        .lineLimit(1)
                        .frame(alignment: .center)
                }
                Spacer()
                HStack {
                    Text("Saldo:")
                        .font(.headline)

                    Text("\((viewModel.withdrawResponse?.withdraw ?? 0).formatted()) $")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.withdrawResponse?.withdraw ?? 0 >= 0 ? .green : .red)
                }
                .padding(.bottom, 5)
                HStack {
                    Text("Despesas:")
                        .font(.subheadline)

                    Text("\((viewModel.withdrawResponse?.expenses ?? 0).formatted()) $")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.trailing, 20)

                    Text("Receitas:")
                        .font(.subheadline)

                    Text("\((viewModel.withdrawResponse?.incomes ?? 0).formatted()) $")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                Spacer()
                VStack {
                    Section(header: Text("Últimas Transações").font(.title2)){
                        Button(action: {
                            isShowingTransactionForm = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .frame(width: 30, height:30)
                                .cornerRadius(10)
                        }
                        ForEach(viewModel.transactionResponse ?? [], id: \.self){ transaction in
                            ListDesign(name: transaction.name, value: transaction.value, kind: transaction.kind, backgroundColor: (transaction.income ? .green : .red),
                                       rightCorner: transaction.timestamp)
                        }
                    }
                }
            }
            
        }
        .ignoresSafeArea().onAppear{
            viewModel.fetchAll(month: month, year: year, limit: limit)
            //remove
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            if !fetchesPerformed {
                viewModel.fetchAll(month: month, year: year, limit: limit)
                fetchesPerformed = true
            }
        }
        .sheet(isPresented: $isShowingTransactionForm) {
                            TransactionFormView(viewModel: viewModel)
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


