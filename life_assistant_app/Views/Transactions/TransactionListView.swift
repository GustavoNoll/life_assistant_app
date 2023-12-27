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

    var body: some View {
        NavigationLink(destination: TransactionDetailListView(transactions: transactions)) {
            VStack {
                ListDesign(name: kind, value: totalAmountFormatted(), backgroundColor: (totalAmountFormatted() >= 0 ? Colors.sucessColor : Colors.errorColor),
                           rightCorner: "")
            }
        }
    }

    private func totalAmountFormatted() -> Double {
        let totalAmount = transactions.reduce(0.0) { result, transaction in
            let value = transaction.income ? transaction.value : -transaction.value
            return result + (value)
        }

        return totalAmount
    }}

struct TransactionDetailListView: View {
    var transactions: [Transaction]

    var body: some View {
        ScrollView {
            ForEach(transactions, id: \.self){ transaction in
                ListDesign(name: transaction.name, value: transaction.value, kind: transaction.kind, backgroundColor: (transaction.income ? Colors.sucessColor : Colors.errorColor),
                           rightCorner: transaction.timestamp)
            }
            .navigationTitle("Detalhes")
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
                    TransactionKindRow(kind: group.key, transactions: group.value)
                }
            } else {
                ForEach(groupedTransactionsByTimestamp(), id: \.key) { timestamp, transactions in
                    Section(header: Text("\(timestamp)")) {
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

    private func groupedTransactionsByTimestamp() -> [(key: String, value: [Transaction])] {
        // Agrupar transações por timestamp
        let groupedDict = Dictionary(grouping: filteredTransactions(), by: { $0.timestamp })
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


