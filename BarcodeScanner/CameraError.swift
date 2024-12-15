//
//  CameraError.swift
//  BarcodeScanner
//
//  Created by Yohai on 15/12/2024.
//

import Foundation

enum CameraError: Error, CustomStringConvertible {
    case captureDeviceUnavailable
    case inputInitializationFailed(error: Error)
    case inputAdditionFailed
    case metataDataOutputAdditionFailed
    case previewLayerInitializationFailed
    
    case noMetadataDetected
    case metadataNotMachineReadable
    case barcodeExtractionFailed
    
    var description: String {
        switch self {
        case .captureDeviceUnavailable: return "Something is wrong with the camera. We are unable to capture the input."
        case .inputInitializationFailed(let error): return "Failed to initialize video input: \(error.localizedDescription)"
        case .inputAdditionFailed: return "Failed to add video input to capture session."
        case .metataDataOutputAdditionFailed: return "Failed to add metadata output to capture session."
        case .previewLayerInitializationFailed: return "Failed to initialize preview layer."
            
        case .noMetadataDetected: return "No metadata objects were detected."
        case .metadataNotMachineReadable: return "The metadata object is not machine-readable."
        case .barcodeExtractionFailed: return "Failed to extract barcode value from metadata object."
        }
    }
}
