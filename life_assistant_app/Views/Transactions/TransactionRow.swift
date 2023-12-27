//
//  TransactionRow.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 26/12/23.
//

import SwiftUI

struct TransactionRow: View {
    @State var item: Item
    @ObservedObject var viewModel: ViewModel
    @Binding var alertType: AlertType?
    @Binding var alertMessage: String?
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(item.transaction.isPaid ? (item.transaction.income ? Colors.sucessColor : Colors.errorColor) : .gray)
                .frame(height: 75)

            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.easeIn){deleteItem()}
                }) {
                    Image(systemName: "trash")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 90, height: 50)
                }
            }
            HStack{
                ListDesignTest(name: item.transaction.name, value: item.transaction.value, scheduled: item.transaction.scheduledDate, backgroundColor: (item.transaction.income ? Colors.sucessColor : Colors.errorColor))
            }
        }
        .onTapGesture {
            if ( !item.transaction.isPaid) {
                showPaymentConfirmationAlert()
            }
        }
        .padding(.horizontal)
            .background(Color("gray"))
            .offset(x: item.offset)
            .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))    }
    func onChanged(value: DragGesture.Value) {
        if value.translation.width < 0 {
            if item.isSwiped {
                item.offset = value.translation.width - 90
            } else {
                item.offset = value.translation.width
            }
        }
    }
    
    func showPaymentConfirmationAlert() {
        let paymentAlertController = UIAlertController(title: "Confirmar Pagamento", message: "Tem certeza de que deseja marcar este item como pago?", preferredStyle: .alert)

        let cancelPaymentAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            // Resetar isSwiped e offset ao cancelar a ação
            self.item.isSwiped = false
            self.item.offset = 0
        }

        paymentAlertController.addAction(cancelPaymentAction)

        let confirmPaymentAction = UIAlertAction(title: "Confirmar Pagamento", style: .default) { _ in
            
            var transactions = self.viewModel.transactionResponse ?? []
            // Chamar a função no seu ViewModel para confirmar o pagamento
            self.viewModel.confirmPay(self.item.transaction) { success in
                if success {
                    self.alertMessage = "Item pago com sucesso!"
                    self.alertType = .success
                } else {
                    self.item.isSwiped = false
                    self.item.offset = 0
                    self.alertMessage = "Erro ao confirmar pagamento!"
                    self.alertType = .error
                }
            }
        }
        paymentAlertController.addAction(confirmPaymentAction)

        // Obtém a referência à view controller atual (onde você está chamando a função deleteItem)
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            viewController.present(paymentAlertController, animated: true, completion: nil)
        }
    }
    
    func onEnd(value: DragGesture.Value) {
        withAnimation(.easeOut) {
            if value.translation.width < 0 {
                if -value.translation.width > UIScreen.main.bounds.width / 2 {
                    item.offset = -1000
                    deleteItem()
                } else if -item.offset > 50 {
                    item.isSwiped = true
                    item.offset = -90
                } else {
                    item.isSwiped = false
                    item.offset = 0
                }
            } else {
                item.isSwiped = false
                item.offset = 0
            }
        }
    }
    func deleteItem() {
        // Certifique-se de que viewModel.transactionResponse é uma variável (var), não uma constante (let)
        let alertController = UIAlertController(title: "Confirmar Deleção", message: "Tem certeza de que deseja excluir este item?", preferredStyle: .alert)
        // Remove o item com base em alguma condição, por exemplo, usando a propriedade 'id'
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            // Resetar isSwiped e offset ao cancelar a ação
            item.isSwiped = false
            item.offset = 0
        }

        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Deletar", style: .destructive) { _ in
            
            //remove from list
            var transactions = self.viewModel.transactionResponse ?? []
            transactions.removeAll { $0.self == item.transaction.self }
            
            // Remove da API
            self.viewModel.deleteTransaction(item.transaction) { success in
                if success {
                    alertMessage = "Transação deletada com sucesso!"
                    alertType = .success
                    self.viewModel.transactionResponse = transactions
                } else {
                    item.isSwiped = false
                    item.offset = 0
                    alertMessage = "Erro ao deletar transação!"
                    alertType = .error
                }
            }
            
        }
        alertController.addAction(deleteAction)

        // Obtém a referência à view controller atual (onde você está chamando a função deleteItem)
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }

    }
}
