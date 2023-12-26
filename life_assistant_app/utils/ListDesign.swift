//
//  ListDesign.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import SwiftUI

struct ListDesign: View {
    @State var name: String
    @State var value: Double
    @State var kind: String
    @State var backgroundColor: Color
    @State var rightCorner: String
    
    var body: some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 10.0)
                .fill(backgroundColor)
                .frame(height: 75)
            VStack(alignment: .leading){
                HStack {
                    Text(name)
                        .foregroundColor(.white)
                        .font(.title.bold())
                    Text("(\(kind))").foregroundColor(.white)
                        .font(.headline.bold())
                    Spacer()
                    Text(rightCorner)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Text("\(value.formatted()) \(Locale.current.currencySymbol!)")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

struct ListDesignView_Previews: PreviewProvider {
    static var previews: some View {
        ListDesign(name: "John", value: 21.0, kind: "Male", backgroundColor: .red, rightCorner: "22/02/2332")
    }
}
