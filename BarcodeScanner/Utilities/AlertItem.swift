//
//  AlertItem.swift
//  BarcodeScanner
//
//  Created by Yohai on 15/12/2024.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let captureDeviceUnavailable = AlertItem(title: "Camera is unavailable",
                                                    message:  "Something is wrong with the camera. We are unable to capture the input.",
                                                    dismissButton: .default(Text("Ok")))
    static let barcodeExtractionFailed = AlertItem(title: "Barcode capture failed",
                                                   message:  "Something went wrong while extracting the barcode.",
                                                   dismissButton: .default(Text("Ok")))
}
