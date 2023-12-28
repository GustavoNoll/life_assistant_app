//
//  BankListView.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 26/12/23.
//

import SwiftUI

struct BankListView: View {
    @StateObject var viewModel: BankModel
    @State private var isShowingBankForm = false
    @State private var isShowingErrorAlert = false
    @State private var backgroundColor = Colors.bankColor
    @EnvironmentObject var userViewModel: AppViewModel
    
    init(userViewModel: AppViewModel) {
        _viewModel = StateObject(wrappedValue: BankModel(appViewModel: userViewModel))
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ZStack {
                        backgroundColor
                            .ignoresSafeArea()
                        
                        VStack {
                            Text("Bancos")
                                .foregroundColor(.white)
                                .font(.largeTitle.bold())
                                .padding(.top, 5)
                                .padding(.bottom, 8)
                        }
                    }.frame(height: 190)
                    VStack {
                        List {
                            ForEach(viewModel.userBanks, id: \._id) { bank in
                                NavigationLink(destination: BankDetailView(bank: bank)) {
                                    BankRowView(bank: bank)
                                }
                            }
                            .onDelete { indexSet in
                                deleteBank(at: indexSet)
                            }
                        }
                    }
                    .onAppear {
                        viewModel.fetchUserBanks()
                    }
                }
                .navigationBarTitle("")
                .sheet(isPresented: $isShowingBankForm) {
                    BankFormView(viewModel: viewModel)
                }
                .alert(isPresented: $isShowingErrorAlert) {
                    Alert(title: Text("Erro"), message: Text("Falha ao excluir o banco. Tente novamente."), dismissButton: .default(Text("OK")))
                }
            }
            .overlay(
                Button(action: {
                    isShowingBankForm = true
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
                        .padding()

                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 20)
                .padding(.trailing, 0),
                alignment: .bottomTrailing
            )
        }
    }

    private func deleteBank(at offsets: IndexSet) {
        for index in offsets {
            let bank = viewModel.userBanks[index]
            viewModel.deleteBank(bank: bank) { success in
                if success {
                    viewModel.userBanks.remove(at: index)
                } else {
                    print("Erro ao excluir o banco")
                    isShowingErrorAlert = true
                }
            }
        }
    }
}

struct BankRowView: View {
    var bank: BankResponse

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(bank.name)
                    .font(.headline)
                Text("Saldo: \(bank.balance.formatted()) \(Locale.current.currencySymbol!)")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .cornerRadius(10)
        
    }
}

struct BankDetailView: View {
    var bank: BankResponse

    var body: some View {
        // Detalhes do banco, se necessário
        Text("Detalhes do Banco: \(bank.name)")
            .navigationBarTitle(bank.name)
    }
}

struct BankView_Previews: PreviewProvider {
    static var previews: some View {// Substitua pelo seu modelo real
        BankListView(userViewModel: AppViewModel())
    }
}
