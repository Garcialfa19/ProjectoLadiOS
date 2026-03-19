import AVFoundation
import SwiftUI
import UIKit
import VisionKit

struct ScannerCameraView: View {
    @Binding var isPaused: Bool
    let onCodeScanned: (String) -> Void

    var body: some View {
        ZStack {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerRepresentable(isPaused: $isPaused, onCodeScanned: onCodeScanned)
            } else {
                LegacyQRScannerRepresentable(isPaused: $isPaused, onCodeScanned: onCodeScanned)
            }

            ScannerOverlayView()
                .allowsHitTesting(false)
        }
    }
}

@available(iOS 16.0, *)
private struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var isPaused: Bool
    let onCodeScanned: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onCodeScanned: onCodeScanned) }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: false,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        try? controller.startScanning()
        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if isPaused {
            uiViewController.stopScanning()
        } else {
            try? uiViewController.startScanning()
        }
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onCodeScanned: (String) -> Void

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case .barcode(let barcode) = item, let payload = barcode.payloadStringValue {
                onCodeScanned(payload)
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let first = addedItems.first,
                  case .barcode(let barcode) = first,
                  let payload = barcode.payloadStringValue
            else {
                return
            }
            onCodeScanned(payload)
        }
    }
}

private struct LegacyQRScannerRepresentable: UIViewRepresentable {
    @Binding var isPaused: Bool
    let onCodeScanned: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onCodeScanned: onCodeScanned) }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        context.coordinator.configureSession(previewView: view)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        context.coordinator.setPaused(isPaused)
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        private let onCodeScanned: (String) -> Void
        private let session = AVCaptureSession()
        private var didConfigure = false

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }

        func configureSession(previewView: PreviewView) {
            guard !didConfigure else { return }
            defer { didConfigure = true }

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input)
            else { return }

            session.addInput(input)

            let output = AVCaptureMetadataOutput()
            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]

            previewView.previewLayer.session = session
            previewView.previewLayer.videoGravity = .resizeAspectFill
            session.startRunning()
        }

        func setPaused(_ paused: Bool) {
            if paused, session.isRunning {
                session.stopRunning()
            } else if !paused, !session.isRunning {
                session.startRunning()
            }
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  object.type == .qr,
                  let payload = object.stringValue
            else {
                return
            }

            onCodeScanned(payload)
        }
    }
}

private final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
