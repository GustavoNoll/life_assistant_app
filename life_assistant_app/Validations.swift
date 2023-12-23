//
//  Validations.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import Foundation

struct Validations {
    static func areTransactionFieldsValid(name: String, value: String, kind: String, selectedBankIndex: Int) -> Bool {
        return !name.isEmpty && !value.isEmpty && !kind.isEmpty && selectedBankIndex >= 0
    }
}
