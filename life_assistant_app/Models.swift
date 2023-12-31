//
//  Models.swift
//  life_assistant_app
//
//  Created by Gustavo Noll on 23/12/23.
//

import Foundation

struct TransactionsResponse: Codable {
    let status: String
    let message: String
    let transactions: [Transaction]
}

struct TransactionResponse: Codable {
    let status: String
    let message: String
}

struct WithdrawResponse: Codable {
    let scheduledIncomes: Double
    let incomes: Double
    let scheduledExpenses: Double
    let expenses: Double
    let withdraw: Double
    let message: String
}

struct User: Codable {
    let userId: String
}
struct UserBank: Codable, Hashable {
    let _id: String
    let name: String
    let balance: Double
    let userId: String
    let __v: Int?
}
struct Item: Codable {
    let transaction: Transaction
    var isSwiped: Bool
    var offset:  CGFloat
}

struct UserBanksResponse: Codable {
    let message: String
    let banks: [UserBank]
}
struct Transaction: Hashable, Codable {
    let _id: String
    let name: String
    let value: Double
    let income: Bool
    let kind: String
    let bankId: String
    let userId: String
    let timestamp: String
    let isParcel: Bool
    let currentParcel: Int
    let parcelId: String?
    let scheduledDate: String
    var isPaid: Bool
}

struct Shipment: Codable, Hashable {
    let _id: String?
    let shipmentNumber: String
    let details: [ShipmentDetail]?
    var userId: String?
    
    init(shipmentNumber: String, _id: String? = nil, details: [ShipmentDetail]? = [], userId: String? = nil) {
        self._id = _id
        self.shipmentNumber = shipmentNumber
        self.details = details
        self.userId = userId
    }

    
}

struct deleteResponse: Codable, Hashable {
    let status: String
    let message: String
}
struct ShipmentDetail: Codable, Hashable {
    let data: String
    let hora: String
    let local: String
    let status: String
    let subStatus: [String]
}

struct UserShipmentsResponse: Codable {
    let status: String
    let message: String
    let userShipments: [Shipment]
}

struct CreateShipmentResponse: Codable {
    let status: String
    let message: String
    let shipment: Shipment
    let apiRequestStatus: String
}

struct UpdateStatusShipmentResponse: Codable{
    let status: String
    let message: String
    let apiRequestStatus: String
}

