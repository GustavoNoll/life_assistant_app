
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
    @State var alertType: AlertType?
    @State var alertMessage: String?
    
        
    init(viewModel: ViewModel) {
        let currentDate = Date()
        self._month = State(initialValue: Calendar.current.component(.month, from: currentDate))
        self._year = State(initialValue: Calendar.current.component(.year, from: currentDate))
        dateFormatter.dateFormat = "dd/MM/yyyy"
        _viewModel = StateObject(wrappedValue: viewModel)
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
                        .font(.title3)
                        .foregroundColor(Colors.homeColor)
                        .padding(.bottom, 0)
                        .lineLimit(1)
                        .frame(alignment: .center)
                }
                Spacer()
                HStack {

                    Text("\((viewModel.withdrawResponse?.withdraw ?? 0).formatted()) \(Locale.current.currencySymbol!)")
                        .font(.title)
                        .foregroundColor(viewModel.withdrawResponse?.withdraw ?? 0 >= 0 ? .green : .red)
                }
                .padding(.bottom, 5)
                HStack {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                                           .resizable()
                                           .scaledToFit()
                                           .frame(width: 30, height: 30)  // Ajuste o tamanho conforme necessário
                                           .padding(.leading, 20)
                                           .foregroundColor(.red)
                                           .background(.white)
                        VStack {
                            Text("\((viewModel.withdrawResponse?.expenses ?? 0).formatted()) \(Locale.current.currencySymbol!)")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.trailing, 20)
                            Text("\((viewModel.withdrawResponse?.scheduledExpenses ?? 0).formatted()) \(Locale.current.currencySymbol!)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.trailing, 20)

                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        VStack {
                            Text("\((viewModel.withdrawResponse?.incomes ?? 0).formatted()) \(Locale.current.currencySymbol!)")
                                .font(.headline)
                                .foregroundColor(.green)
                            Text("\((viewModel.withdrawResponse?.scheduledIncomes ?? 0).formatted()) \(Locale.current.currencySymbol!)")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                        }
                        Image(systemName: "arrow.up.circle.fill")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 30, height: 30)  // Ajuste o tamanho conforme necessário
                           .padding(.trailing, 20)
                           .foregroundColor(.green)
                           .background(.white)
                    }
                }
                Spacer()
                VStack {
                    Section(header: Text("Últimas Transações").font(.title2)){
                        ForEach(Dictionary(grouping: viewModel.transactionResponse?.prefix(limit) ?? [], by: { $0.scheduledDate }).sorted(by: { $0.key > $1.key }), id: \.key) { scheduledDate, transactions in
                            Section(header: Text("\(scheduledDate)")) {
                                ForEach(transactions, id: \.self) { transaction in
                                    TransactionRow(item: Item(transaction: transaction, isSwiped: false, offset: 0), viewModel: viewModel, alertType: $alertType, alertMessage: $alertMessage)
                                }
                            }
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
        .navigationBarHidden(false)
        .overlay(
            alertMessage.map { message in
                BannerView(message: message, alertType: alertType)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                alertMessage = nil
                                if alertType == .success {
                                }
                            }
                        }
                    }
            }
        )
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
            viewModel.fetchAll(month: month, year: year)
        }
        .sheet(isPresented: $isShowingTransactionForm) {
                            TransactionFormView(viewModel: viewModel)
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        let userViewModel = AppViewModel()
        let viewModel = ViewModel(appViewModel: userViewModel)
        HomePageView(viewModel: viewModel)
    }
}

