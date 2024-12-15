//
//  BarcodeScannerViewModel.swift
//  BarcodeScanner
//
//  Created by Yohai on 15/12/2024.
//

import Foundation
import SwiftUI

final class BarcodeScannerViewModel: ObservableObject {
    
    @Published var scannedCode: String = ""
    @Published var alertItem: AlertItem?
    
    var statusText: String {
        scannedCode.isEmpty ? "Not Yet Scanned" : scannedCode
    }
    
    var statusTextColor: Color {
        scannedCode.isEmpty ? Color.red : Color.green
    }
}
