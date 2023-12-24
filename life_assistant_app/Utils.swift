//
//  Utils.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import Foundation
import SwiftUI

struct Utils {
    static func formattedDouble(_ value: Double) -> String {
        return String(format: "%.2f", value)
    }
}

enum AlertType {
    case success
    case error
}

struct BannerView: View {
    let message: String
    let alertType: AlertType?

    var body: some View {
        VStack {
            HStack {
                Text(message)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(alertType == .success ? Colors.sucessColor : Colors.errorColor)
            .cornerRadius(20)
            .padding(.horizontal, 16)
            Spacer()
        }
    }
}
struct BViewanner_Previews: PreviewProvider {
    static var previews: some View {
        BannerView(message: "Atualizado com sucesso", alertType: .success)
    }
}

struct Colors {
    static let shipmentColor = Color(red: 0.87, green: 0.63, blue: 0.87)
    static let homeColor = Color(red: 0.27, green: 0.51, blue: 0.71)
    static let sucessColor = Color(red: 0.24, green: 0.70, blue: 0.44)
    static let errorColor = Color(red: 1.00, green: 0.39, blue: 0.28)
}
