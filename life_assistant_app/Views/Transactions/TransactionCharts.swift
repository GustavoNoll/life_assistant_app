import SwiftUI
import SwiftPieChart

struct TransactionPieChartView: View {
    @State var values: [Double]
    @State var names: [String]
    @State var income: Bool
    
    init(transactions: [Transaction], income: Bool) {
        var arrayTransactions = transactions
        arrayTransactions.removeAll(where: { $0.income == !income })
        let groupedDict = Dictionary(grouping: arrayTransactions, by: { $0.kind })
        let grouped = groupedDict.sorted { $0.key < $1.key }
        var list: [Double] = []
        
        for group in grouped {
            let totalAmount = group.value.reduce(0.0) { result, transaction in
                let value = transaction.value
                return result + value
            }
            list.append(totalAmount)
        }
        self._values = State(initialValue: list)
        self._names = State(initialValue: grouped.map { $0.key})
        self._income = State(initialValue: income)
    }
    
    var body: some View {
        PieChartView(values: values, names: names, formatter: { value in
            return "\(value.formatted()) \(Locale.current.currencySymbol!)"
        }, title: (income ? "Receitas" : "Despesas"))
    }
    
    
}

struct PieChartView1_Previews: PreviewProvider {
    static var previews: some View {
        let transactions: [Transaction] = [
            // Adicione outros tipos conforme necessário
        ]
        return TransactionPieChartView(transactions: transactions, income: true)
    }
}

