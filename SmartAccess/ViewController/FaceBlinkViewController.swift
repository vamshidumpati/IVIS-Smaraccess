//
//  FaceBlinkViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 09/04/25.
//

import UIKit
import AVFoundation
import Vision

class FaceBlinkViewController: UIViewController {
    
    private var captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📸 Capture", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
        button.layer.cornerRadius = 10
        button.isHidden = true
        return button
    }()
    
    private var isFaceDetected = false
    private var isBlinkDetected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 160),
            captureButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        captureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        captureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.processing"))
        captureSession.addOutput(output)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        captureSession.startRunning()
    }
    
    @objc private func captureImage() {
        print("📸 Capture triggered!")
        // Your capture logic goes here...
    }
    
    private func processFace(_ face: VNFaceObservation) {
        guard let landmarks = face.landmarks,
              let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else { return }
        
        let isLeftEyeClosed = isEyeClosed(leftEye)
        let isRightEyeClosed = isEyeClosed(rightEye)
        
        isBlinkDetected = isLeftEyeClosed && isRightEyeClosed
        updateCaptureButton()
    }
    
    private func isEyeClosed(_ eye: VNFaceLandmarkRegion2D) -> Bool {
        let points = eye.normalizedPoints
        let eyeHeight = (points.map { $0.y }.max() ?? 0) - (points.map { $0.y }.min() ?? 0)
        return eyeHeight < 0.01 // Tweak this threshold based on testing
    }
    
    private func updateCaptureButton() {
        DispatchQueue.main.async {
            self.captureButton.isHidden = !(self.isFaceDetected && self.isBlinkDetected)
        }
    }
}

extension FaceBlinkViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self else { return }
            guard let results = request.results as? [VNFaceObservation], let face = results.first else {
                self.isFaceDetected = false
                self.isBlinkDetected = false
                self.updateCaptureButton()
                return
            }
            self.isFaceDetected = true
            self.processFace(face)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored)
        try? handler.perform([request])
    }
}
