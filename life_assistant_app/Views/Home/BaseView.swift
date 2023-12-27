import SwiftUI

enum TabbedItems: Int, CaseIterable{
    case home = 0
    case banks
    case transactions
    case shipments
    var title: String {
        switch self {
        case .home: return "Home"
        case .banks: return "Bancos"
        case .transactions: return "Transações"
        case .shipments: return "Encomendas"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "home-icon"
        case .banks: return "bank-icon"
        case .transactions: return "money-circ-icon"
        case .shipments: return "shipment-icon"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return Colors.homeColor
        case .banks: return Colors.bankColor
        case .transactions: return Colors.transacationColor
        case .shipments: return Colors.shipmentColor
        }
    }
}

struct BaseView: View {
    @EnvironmentObject var userViewModel: AppViewModel
    @State var selectedTab = 0
    @StateObject var viewModel: ViewModel
    
    init(userViewModel: AppViewModel) {
        _viewModel = StateObject(wrappedValue: ViewModel(appViewModel: userViewModel))
    }

    var body: some View {
        ZStack(alignment: .bottom){
            TabView(selection: $selectedTab) {
                HomeView(viewModel: viewModel)
                    .tag(0)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                BanksView()
                    .tag(1)
                
                TransactionsViewTab(viewModel: viewModel)
                    .tag(2)
                
                ShipmentView()
                    .tag(3)
                    .toolbarBackground(.hidden, for: .tabBar)
            }
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            ZStack{
                HStack{
                    ForEach((TabbedItems.allCases), id: \.self){ item in
                        Button{
                            selectedTab = item.rawValue
                        } label: {
                            CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue), color: item.color)
                        }
                    }
                }
                .padding(6)
            }
            .frame(height: 70)
            .background(Color.white.opacity(0.8))
            .cornerRadius(35)
            .padding(.horizontal, 26)
        }
        
    }
}

extension BaseView{
    func CustomTabItem(imageName: String, title: String, isActive: Bool, color: Color) -> some View{
        HStack(spacing: 10){
            Spacer()
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .black : .gray)
                .frame(width: 20, height: 20)
            Spacer()
        }
        .frame(width: isActive ? .infinity : 60, height: 60)
        .background(isActive ? color.opacity(0.4) : .clear)
        .cornerRadius(30)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AppViewModel()
        BaseView(userViewModel: viewModel)
    }
}

struct HomeView: View {
    @StateObject var viewModel: ViewModel
    var body: some View {
        HomePageView(viewModel: viewModel)
    }
}

struct ShipmentView: View {
    @EnvironmentObject var userViewModel: AppViewModel
    var body: some View {
        ShipmentListView(userViewModel: userViewModel)
    }
}


struct BanksView: View {
    @EnvironmentObject var userViewModel: AppViewModel
    var body: some View {
        BankListView(userViewModel: userViewModel)
    }
}

struct TransactionsViewTab: View {
    @StateObject var viewModel: ViewModel
    var body: some View {
        TransactionsView(viewModel: viewModel)
    }
}


