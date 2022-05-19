//
//  Created by Tiago Ribeiro on 19/05/2022.
//

import UIKit
import AVFoundation
import Combine
import CameraPreview

class QRCodeReaderViewModel: NSObject, ObservableObject {
    
    private let captureSession: AVCaptureSession = AVCaptureSession()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isTorchEnable: Bool = false
    @Published var isTorchOn: Bool = false
    
    lazy var cameraPreview = CameraPreview(session: self.captureSession)
    var result = PassthroughSubject<String, Never>()
    
    override init() {
        super.init()
        
        self.captureSession.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard self.captureSession.canAddInput(captureDeviceInput) else { return }
        self.captureSession.addInput(captureDeviceInput)
        
        self.isTorchEnable = captureDevice.hasTorch
        self.isTorchOn = false
        
        let metadataOutput = AVCaptureMetadataOutput()
        guard self.captureSession.canAddOutput(metadataOutput) else { return }
        self.captureSession.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        self.$isTorchOn
            .sink { [unowned self] isOn in
                self.toggleTorch(isOn)
            }
            .store(in: &self.cancellables)
    }
    
    func startCapturing() {
        self.captureSession.startRunning()
    }
    
    func stopCapturing() {
        self.captureSession.stopRunning()
    }
}

extension QRCodeReaderViewModel: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            self.result.send(stringValue)
            self.result.send(completion: .finished)
        }
    }
}

fileprivate extension QRCodeReaderViewModel {
    
    func toggleTorch(_ on: Bool) {
        guard self.isTorchEnable else { return }
        guard let input = self.captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        
        try? input.device.lockForConfiguration()
        if on {
            try? input.device.setTorchModeOn(level: 1.0)
        }
        else {
            input.device.torchMode = .off
        }
        input.device.unlockForConfiguration()
    }
}
