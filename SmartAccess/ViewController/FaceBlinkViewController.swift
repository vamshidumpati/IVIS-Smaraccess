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
    
    // MARK: - Properties
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var faceGuideImageView: UIImageView!
    
    // Detection state
    private var isFaceDetected = false
    private var isBlinkDetected = false
    private var lastEyeState: (left: Bool, right: Bool) = (false, false) // false = open
    
    var uploadProfileImage:Bool = false
    
    // UI Components
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Align your face with the guide"
        return label
    }()
    
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📸 CAPTURE", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.isHidden = true
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkCameraPermission()
        disableNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCaptureSession()
    }
    
    // MARK: - Setup
    private func disableNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Face guide image
        faceGuideImageView = UIImageView(image: UIImage(named: "face_authorization_image"))
        faceGuideImageView.contentMode = .scaleAspectFit
        faceGuideImageView.alpha = 0.7
        view.addSubview(faceGuideImageView)
        faceGuideImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            faceGuideImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            faceGuideImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            faceGuideImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            faceGuideImageView.heightAnchor.constraint(equalTo: faceGuideImageView.widthAnchor)
        ])
        
        // Status label
        view.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: faceGuideImageView.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Capture button
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        captureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
    }
    
    private func startCaptureSession() {
         sessionQueue.async {
             if !self.captureSession.isRunning {
                 self.captureSession.startRunning()
             }
         }
     }
     
     private func stopCaptureSession() {
         sessionQueue.async {
             if self.captureSession.isRunning {
                 self.captureSession.stopRunning()
             }
         }
     }
    
    // MARK: - Camera Setup
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
            }
        default:
            //showCameraAccessAlert()
            print("Camera not detected")
        }
    }
    
    private func setupCamera() {
        sessionQueue.async {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                DispatchQueue.main.async {
                    self.statusLabel.text = "Camera not available"
                }
                return
            }
            
            self.captureSession.beginConfiguration()
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video.queue"))
            
            if self.captureSession.canAddOutput(output) {
                self.captureSession.addOutput(output)
            }
            
            self.captureSession.commitConfiguration()
            
            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer.frame = self.view.layer.bounds
                self.previewLayer.videoGravity = .resizeAspectFill
                self.view.layer.insertSublayer(self.previewLayer, at: 0)
            }
        }
    }
    
    // MARK: - Blink Detection
    private func processFace(_ face: VNFaceObservation) {
        guard let landmarks = face.landmarks,
              let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else {
            // No face or no eyes detected
            handleNoFaceDetected()
            return
        }
        
        if !uploadProfileImage{
            // Face is detected
            isFaceDetected = true
            
            // Check eye states
            let leftEyeClosed = isEyeClosed(leftEye)
            let rightEyeClosed = isEyeClosed(rightEye)
            
            // Detect blink (transition from open to closed)
            if leftEyeClosed && rightEyeClosed && (!lastEyeState.left || !lastEyeState.right) {
                handleBlinkDetected()
            }
            
            // Update last eye state
            lastEyeState = (leftEyeClosed, rightEyeClosed)
        }
        
        updateUI()
    }
    
    private func isEyeClosed(_ eye: VNFaceLandmarkRegion2D) -> Bool {
        let points = eye.normalizedPoints
        let eyeWidth = (points.map { $0.x }.max() ?? 0) - (points.map { $0.x }.min() ?? 0)
        let eyeHeight = (points.map { $0.y }.max() ?? 0) - (points.map { $0.y }.min() ?? 0)
        
        // Calculate eye aspect ratio (more reliable than just height)
        let ear = eyeHeight / eyeWidth
        
        // Threshold for closed eye (adjust as needed)
        return ear < 0.25
    }
    
    private func handleNoFaceDetected() {
        isFaceDetected = false
        isBlinkDetected = false
        lastEyeState = (false, false)
        DispatchQueue.main.async {
            self.statusLabel.text = "Align your face with the guide"
            self.statusLabel.textColor = .white
            self.captureButton.isHidden = true
        }
    }
    
    private func handleBlinkDetected() {
        isBlinkDetected = true
        DispatchQueue.main.async {
            self.statusLabel.text = "Blink detected!"
            self.statusLabel.textColor = .systemGreen
            self.captureButton.isHidden = false
            
//            // Auto-hide after 3 seconds if not captured
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                if !self.captureButton.isHidden {
//                    self.isBlinkDetected = false
//                    self.updateUI()
//                }
//            }
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            if !self.isFaceDetected {
                self.statusLabel.text = "Align your face with the guide"
                self.statusLabel.textColor = .white
                self.captureButton.isHidden = true
            } else if !self.isBlinkDetected {
                self.statusLabel.text = "Face detected - blink to capture"
                self.statusLabel.textColor = .systemYellow
                self.captureButton.isHidden = true
            } else {
                self.statusLabel.text = "Ready to capture!"
                self.statusLabel.textColor = .systemGreen
                self.captureButton.isHidden = false
            }
        }
    }
    
    @objc private func captureImage() {
        print("Photo captured!")
        // Add your capture logic here
        isBlinkDetected = false
        updateUI()
    }
}

// MARK: - Video Data Output Delegate
extension FaceBlinkViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                      didOutput sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Face detection error: \(error.localizedDescription)")
                self.handleNoFaceDetected()
                return
            }
            
            guard let results = request.results as? [VNFaceObservation],
                  let face = results.first else {
                self.handleNoFaceDetected()
                return
            }
            
            self.processFace(face)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored)
        try? handler.perform([request])
    }
}
