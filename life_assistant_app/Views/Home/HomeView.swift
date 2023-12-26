
import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var userViewModel: AppViewModel
    @StateObject var viewModel: ViewModel
    @State private var month: Int
    @State private var year: Int
    @State private var limit = 7
    private var dateFormatter = DateFormatter()
    @State private var isShowingTransactionForm = false
    @State private var fetchesPerformed = false
    @State private var backgroundColor = Colors.homeColor
    
        
    init(userViewModel: AppViewModel) {
        let currentDate = Date()
        self._month = State(initialValue: Calendar.current.component(.month, from: currentDate))
        self._year = State(initialValue: Calendar.current.component(.year, from: currentDate))
        dateFormatter.dateFormat = "dd/MM/yyyy"
        _viewModel = StateObject(wrappedValue: ViewModel(appViewModel: userViewModel))
    }
    var body: some View {
        ScrollView {
            ZStack {
                ZStack {
                    backgroundColor
                        .ignoresSafeArea()
                    
                    Text("Finanças")
                        .foregroundColor(.white)
                        .font(.largeTitle.bold())
                        .padding(.top, 60)
                        .padding(.bottom, 8)
                }
            }
            .frame(height: 250)
            Spacer()
            VStack {
                HStack {
                    Text("Balanço do mês")
                        .font(.title2.bold())
                        .foregroundColor(Colors.homeColor)
                        .padding(.bottom, 0)
                        .lineLimit(1)
                        .frame(alignment: .center)
                }
                Spacer()
                HStack {
                    Text("Saldo:")
                        .font(.headline)

                    Text("\((viewModel.withdrawResponse?.withdraw ?? 0).formatted()) \(Locale.current.currencySymbol!)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.withdrawResponse?.withdraw ?? 0 >= 0 ? .green : .red)
                }
                .padding(.bottom, 5)
                HStack {
                    Text("Despesas:")
                        .font(.subheadline)

                    Text("\((viewModel.withdrawResponse?.expenses ?? 0).formatted()) \(Locale.current.currencySymbol!)")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.trailing, 20)

                    Text("Receitas:")
                        .font(.subheadline)

                    Text("\((viewModel.withdrawResponse?.incomes ?? 0).formatted()) \(Locale.current.currencySymbol!)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                Spacer()
                VStack {
                    Section(header: Text("Últimas Transações").font(.title2)){
                        ForEach(viewModel.transactionResponse ?? [], id: \.self){ transaction in
                            ListDesign(name: transaction.name, value: transaction.value, kind: transaction.kind, backgroundColor: (transaction.income ? Colors.sucessColor : Colors.errorColor),
                                       rightCorner: transaction.timestamp)
                        }
                        Button(action: {
                            userViewModel.signOut()
                        }) {
                            Text("Sair")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        Spacer().frame(height: 100)
                    }
                }
                Spacer()
            }
            
        }
        .ignoresSafeArea()
        .navigationTitle("")
        .navigationBarHidden(true)
        .overlay(
            Button(action: {
                isShowingTransactionForm = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(backgroundColor)
                    .background(.white)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(backgroundColor, lineWidth: 2) // Ajuste a largura da borda aqui
                    )
            }
            .padding()
            .padding(.bottom, 20)
            .padding(.trailing, 0),
            alignment: .bottomTrailing
        )
        .onAppear {
            viewModel.fetchAll(month: month, year: year, limit: limit)
        }
        .sheet(isPresented: $isShowingTransactionForm) {
                            TransactionFormView(viewModel: viewModel)
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        let userViewModel = AppViewModel()
        HomePageView(userViewModel: userViewModel)
    }
}

