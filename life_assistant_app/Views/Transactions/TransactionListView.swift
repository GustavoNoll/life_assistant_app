//
//  TransactionListView.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 26/12/23.
//

import SwiftUI

struct TransactionKindRow: View {
    var kind: String
    var transactions: [Transaction]
    @Binding var alertType: AlertType?
    @Binding var alertMessage: String?
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationLink(destination: TransactionDetailListView(kind: kind,transactions: transactions, alertType: $alertType, alertMessage: $alertMessage, viewModel: viewModel)) {
            let total = totalAmountFormatted()
            VStack {
                ListDesign(name: kind, value: total, backgroundColor: (total >= 0 ? Colors.sucessColor : Colors.errorColor),
                           rightCorner: "", isPaid: true)
            }
        }
    }
    
    private func totalAmountFormatted() -> Double {
        let totalAmount = transactions.reduce(0.0) { result, transaction in
            let value = transaction.income ? transaction.value : -transaction.value
            return result + (value)
        }
        
        return totalAmount
    }
}

struct TransactionDetailListView: View {
    var kind: String
    var transactions: [Transaction]
    @Binding var alertType: AlertType?
    @Binding var alertMessage: String?
    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            ForEach(transactions, id: \.self){ transaction in
                TransactionRow(item: Item(transaction: transaction, isSwiped: false, offset: 0), viewModel: viewModel, alertType:
                                $alertType, alertMessage: $alertMessage)

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
    }
}
struct TransactionsListView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var showOnlyIncomes: Bool
    @Binding var showOnlyExpenses: Bool
    @Binding var filterByKind: Bool
    @Binding var alertType: AlertType?
    @Binding var alertMessage: String?

    var body: some View {
        VStack {
            if filterByKind {
                // Agrupar por kind e mostrar gastos/receitas por kind
                ForEach(groupedTransactionsByKind(), id: \.key) { group in
                    TransactionKindRow(kind: group.key, transactions: group.value, alertType: $alertType, alertMessage: $alertMessage, viewModel: viewModel)
                }
            } else {
                ForEach(groupedTransactionsByScheduledDate(), id: \.key) { scheduledDate, transactions in
                    Section(header: Text("\(scheduledDate)")) {
                        ForEach(transactions, id: \.self) { transaction in
                            TransactionRow(item: Item(transaction: transaction, isSwiped: false, offset: 0), viewModel: viewModel, alertType:
                                            $alertType, alertMessage: $alertMessage)
                        }
                    }
                }
            }
        }
    }

    private func groupedTransactionsByKind() -> [(key: String, value: [Transaction])] {
        // Agrupar transações por kind e calcular a soma dos valores
        let groupedDict = Dictionary(grouping: filteredTransactions(), by: { $0.kind })
        return groupedDict.sorted { $0.key < $1.key }
    }

    private func groupedTransactionsByScheduledDate() -> [(key: String, value: [Transaction])] {
        // Agrupar transações por timestamp
        let groupedDict = Dictionary(grouping: filteredTransactions (), by: { $0.scheduledDate })
        return groupedDict.sorted { $0.key > $1.key }
    }

    private func filteredTransactions() -> [Transaction] {
        var filteredList: [Transaction] = viewModel.transactionResponse ?? []

        if !showOnlyIncomes {
            filteredList.removeAll(where: { $0.income == true })
        }

        if !showOnlyExpenses {
            filteredList.removeAll(where: { $0.income == false })
        }

        return filteredList
    }
}


