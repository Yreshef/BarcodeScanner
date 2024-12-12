//
//  CameraViewController.swift
//  BarcodeScanner
//
//  Created by Yohai on 12/12/2024.
//

import UIKit
import AVFoundation

enum CameraError: Error, CustomStringConvertible {
    case captureDeviceUnavailable
    case inputInitializationFailed(error: Error)
    case inputAdditionFailed
    case metataDataOutputAdditionFailed
    case previewLayerInitializationFailed
    
    var description: String {
        switch self {
        case .captureDeviceUnavailable: return "Something is wrong with the camera. We are unable to capture the input."
        case .inputInitializationFailed(let error): return "Failed to initialize video input: \(error.localizedDescription)"
        case .inputAdditionFailed: return "Failed to add video input to capture session."
        case .metataDataOutputAdditionFailed: return "Failed to add metadata output to capture session."
        case .previewLayerInitializationFailed: return "Failed to initialize preview layer."
        }
    }
}

protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String)
    func didSurface(error: CameraError)
}

final class ScannerVC: UIViewController {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: ScannerVCDelegate?
    
    init(scannerDelegate: ScannerVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = configureCaptureDevice() else {
            scannerDelegate?.didSurface(error: .captureDeviceUnavailable)
            return
        }
        
        guard let videoInput = configureVideoInput(for: videoCaptureDevice) else {
            return
        }
        
        guard addInputToSession(videoInput) else {
            scannerDelegate?.didSurface(error: .inputAdditionFailed)
            return
        }
        
        guard addMetadataOutputToSession() else {
            scannerDelegate?.didSurface(error: .metataDataOutputAdditionFailed)
            return
        }
        
        configurePreviewLayers()
        captureSession.startRunning()
    }
    
    private func configureCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.default(for: .video)
    }
    
    private func configureVideoInput(for device: AVCaptureDevice) -> AVCaptureDeviceInput? {
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch {
            scannerDelegate?.didSurface(error: .inputInitializationFailed(error: error))
            return nil
        }
    }
    
    private func addInputToSession(_ input: AVCaptureDeviceInput) -> Bool {
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
            return true
        }
        return false
    }
    
    private func addMetadataOutputToSession() -> Bool {
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13]
            return true
        }
        return false
    }
    
    private func configurePreviewLayers() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer {
            view.layer.addSublayer(previewLayer)
        } else {
            scannerDelegate?.didSurface(error: .previewLayerInitializationFailed)
        }
    }
    //TODO: Remove
    //    private func setupCatpureSession() {
    //        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
    //            return
    //        }
    //
    //        let videoInput: AVCaptureDeviceInput
    //
    //        do {
    //            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
    //        } catch {
    //            return
    //        }
    //
    //        if captureSession.canAddInput(videoInput) {
    //            captureSession.addInput(videoInput)
    //        } else {
    //            return
    //        }
    //
    //        let metadataOutput = AVCaptureMetadataOutput()
    //
    //        if captureSession.canAddOutput(metadataOutput) {
    //            captureSession.addOutput(metadataOutput)
    //            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    //            metadataOutput.metadataObjectTypes = [.ean8, .ean13]
    //        } else {
    //            return
    //        }
    //
    //        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    //        previewLayer?.videoGravity = .resizeAspectFill
    //        view.layer.addSublayer(previewLayer!) //TODO: safe unwrap
    //
    //        captureSession.startRunning()
    //    }
}

extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let object = metadataObjects.first else { return }
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else { return }
        guard let barcode = machineReadableObject.stringValue else { return }
        
        scannerDelegate?.didFind(barcode: barcode)
    }
}
