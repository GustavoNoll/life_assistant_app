//
//  ShipmentListView.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import SwiftUI

struct ShipmentListView: View {
    @ObservedObject var viewModel: ShipmentModel
    @State private var isShowingShipmentForm = false
    @State private var isShowingErrorAlert = false
    @State private var backgroundColor = Colors.shipmentColor

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ZStack {
                        backgroundColor
                            .ignoresSafeArea()
                        
                        VStack {
                            Text("Encomendas")
                                .foregroundColor(.white)
                                .font(.largeTitle.bold())
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                        }
                    }.frame(height: 200)
                    
                    VStack {
                            List {
                                ForEach(viewModel.userShipments, id: \.shipmentNumber) { shipment in
                                    NavigationLink(destination: ShipmentDetailsView(shipment: shipment, viewModel: viewModel)) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(shipment.shipmentNumber)
                                                    .font(.headline)
                                                Text("\(shipment.details?.first?.status ?? "N/A")")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                    }
                                }
                                .onDelete(perform: deleteShipment)
                            }
                    }
                    .onAppear {
                        viewModel.fetchUserShipments()
                    }
                }
                .navigationBarTitle("")
                .sheet(isPresented: $isShowingShipmentForm) {
                                ShipmentFormView(viewModel: viewModel)
                            }
                .alert(isPresented: $isShowingErrorAlert) {
                                Alert(title: Text("Erro"), message: Text("Falha ao excluir a encomenda. Tente novamente."), dismissButton: .default(Text("OK")))
                            }
                
                // Botão "+" no canto inferior direito
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingShipmentForm = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .foregroundColor(backgroundColor)
                                .background(Color.white)
                                .frame(width: 50, height: 50)
                                .cornerRadius(20)
                                .padding()
                        }
                    }
                }
            }
        }
    }
    private func deleteShipment(at offsets: IndexSet) {
        for index in offsets {
            let shipment = viewModel.userShipments[index]
            viewModel.deleteShipment(shipment) { success in
                if success {
                    viewModel.userShipments.remove(at: index)
                } else {
                    print("Erro ao excluir a encomenda")
                    isShowingErrorAlert = true
                }
            }
        }
    }

}



struct ShipmentDetailsView: View {
    let shipment: Shipment
    let viewModel: ShipmentModel
    @State private var alertMessage: String?
    @State private var alertType: AlertType?

    var body: some View {
        VStack {
            List(shipment.details ?? [], id: \.self) { detail in
                VStack(alignment: .leading) {
                    Text("Data: \(detail.data)")
                    Text("Hora: \(detail.hora)")
                    Text("Local: \(detail.local)")
                    Text("Status: \(detail.status)")
                    ForEach(detail.subStatus, id: \.self) { subStatus in
                        Text(subStatus)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .refreshable {
                await updateStatusShipment(shipment: shipment)
            }
            .overlay(
                alertMessage.map { message in
                    BannerView(message: message, alertType: alertType)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    alertMessage = nil
                                }
                            }
                        }
                }
            )
            .navigationTitle("Detalhes da Encomenda")
        }
    }
    private func updateStatusShipment(shipment: Shipment) async {
        viewModel.forceUpdateShipment(shipment: shipment) { success in
            if success {
                viewModel.fetchUserShipments()
                alertMessage = "Atualização bem-sucedida"
                alertType = .success
            }
            else {
                print("Erro ao atualizar status da encomenda")
                alertMessage = "Erro ao atualizar status da encomenda"
                alertType = .error
            }
        }
    }
}

struct ShipmentListView_Previews: PreviewProvider {
    static var previews: some View {
        ShipmentListView(viewModel: ShipmentModel())
    }
}
