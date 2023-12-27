//
//  Utils.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import Foundation
import SwiftUI

extension Double {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","

        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
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
    static let bankColor = Color(red: 0.65, green: 0.50, blue: 0.41)
    static let transacationColor = Color(red: 0.56, green: 0.44, blue: 0.58)
    static let sucessColor = Color(red: 0.24, green: 0.70, blue: 0.44)
    static let errorColor = Color(red: 1.00, green: 0.39, blue: 0.28)
}

struct ToggleButton: View {
    var title: String
    @Binding var isOn: Bool
    var color: Color

    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .opacity(isOn ? 1.0 : 0.5)
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .frame(height: 40)
            .padding(.vertical, 4)
        }
    }
}
