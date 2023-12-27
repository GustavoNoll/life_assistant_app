//
//  TransactionsView.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 26/12/23.
//

import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var userViewModel: AppViewModel
    @StateObject var viewModel: ViewModel
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedDay = Calendar.current.component(.day, from: Date())
    @State private var showOnlyIncomes = true
    @State private var showOnlyExpenses = true
    @State private var filterByKind = false
    @State private var isShowingTransactionForm = false
    @State private var fetchesPerformed = false
    @State private var backgroundColor = Colors.transacationColor
    @State private var alertType: AlertType?
    @State private var alertMessage: String?

    init(viewModel: ViewModel) {
        let currentDate = Date()
        self._selectedMonth = State(initialValue: Calendar.current.component(.month, from: currentDate))
        self._selectedYear = State(initialValue: Calendar.current.component(.year, from: currentDate))
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            ZStack {
                ZStack {
                    backgroundColor
                        .ignoresSafeArea()

                    Text("Transações")
                        .foregroundColor(.white)
                        .font(.largeTitle.bold())
                        .padding(.top, 60)
                        .padding(.bottom, 8)
                }
            }
            .frame(height: 250)

            VStack {
                FilterView(selectedMonth: $selectedMonth, selectedYear: $selectedYear, selectedDay: $selectedDay,showOnlyIncomes: $showOnlyIncomes, showOnlyExpenses: $showOnlyExpenses, filterByKind: $filterByKind, viewModel: viewModel)

                ChartsView(viewModel: viewModel, selectedMonth: $selectedMonth, selectedYear: $selectedYear, showOnlyIncomes: $showOnlyIncomes, showOnlyExpenses: $showOnlyExpenses, filterByKind: $filterByKind)
                    .frame(height: 300)
                
                TransactionsListView(viewModel: viewModel,showOnlyIncomes: $showOnlyIncomes, showOnlyExpenses: $showOnlyExpenses, filterByKind: $filterByKind, alertType: $alertType, alertMessage: $alertMessage)
                Spacer().frame(height: 100)
            }
            .navigationBarTitle("Transações")

        }.ignoresSafeArea()
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
    }
}

struct FilterView: View {
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    @Binding var selectedDay: Int
    @Binding var showOnlyIncomes: Bool
    @Binding var showOnlyExpenses: Bool
    @Binding var filterByKind: Bool
    @State private var isDatePickerPresented = false
    @ObservedObject var viewModel:  ViewModel
    @State private var calendarId: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray)
                Text(formattedDate())
                    .foregroundColor(.white)
                    .font(.headline)
                    .overlay{ //MARK: Place the DatePicker in the overlay extension
                        DatePicker(
                            "",
                            selection: getDate(),
                            displayedComponents: [.date]
                        ).id(calendarId)
                        .onChange(of: [selectedMonth, selectedYear]) {
                            calendarId += 1
                        }
                        .blendMode(.destinationOver) //MARK: use this extension to keep the clickable functionality
                    }
            }
            .frame(height: 40)
            .padding(.vertical, 4)

            HStack {
                ToggleButton(title: "Receitas", isOn: $showOnlyIncomes, color: .green)
                ToggleButton(title: "Despesas", isOn: $showOnlyExpenses, color: .red)
                ToggleButton(title: "Por Gênero", isOn: $filterByKind, color: .blue)
            }
        }
        .padding()
    }

    private func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        return dateFormatter.string(from: date)
    }
    
    private func getDate() -> Binding<Date> {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        components.day = selectedDay
        let initialDate = calendar.date(from: components) ?? Date()

        return Binding<Date>(
            get: { initialDate },
            set: { newValue in
                let newComponents = calendar.dateComponents([.day, .month, .year], from: newValue)
                selectedMonth = newComponents.month ?? 1
                selectedYear = newComponents.year ?? 2023 // Coloque o ano padrão desejado
                selectedDay = newComponents.day ?? 1
                viewModel.fetchAll(month: selectedMonth, year: selectedYear)
            }
        )
    }
}


struct ChartsView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var selectedTab = 0
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    @Binding var showOnlyIncomes: Bool
    @Binding var showOnlyExpenses: Bool
    @Binding var filterByKind: Bool

    
    // Implemente os gráficos aqui
    var body: some View {
        if viewModel.transactionResponse?.count ?? 0 > 0 {
            VStack {
                TabView(selection: $selectedTab) {
                    TransactionPieChartView(transactions: viewModel.transactionResponse ?? [], income: true)
                        .tag(0)

                    TransactionPieChartView(transactions: viewModel.transactionResponse ?? [], income: false)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .gesture(DragGesture()
                    .onEnded { value in
                        if value.translation.width < 0 {
                            // Swiped to the left
                            selectedTab = min(selectedTab + 1, 1)
                        } else if value.translation.width > 0 {
                            // Swiped to the right
                            selectedTab = max(selectedTab - 1, 0)
                        }
                    }
                )
                .padding(.horizontal, 20) 
                PageControl(numberOfPages: 2, currentPage: $selectedTab)
                                    .padding(.bottom, 10)
            }
        }
    }
}

struct PageControl: View {
    var numberOfPages: Int
    @Binding var currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(page == currentPage ? .blue : .gray)
            }
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        let userViewModel = AppViewModel()
        TransactionsView(viewModel: ViewModel(appViewModel: userViewModel))
    }
}
