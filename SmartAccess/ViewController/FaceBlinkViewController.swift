//
//  FaceBlinkViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 09/04/25.
//

import UIKit
import AVFoundation
import Vision

class FaceBlinkViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var retakeBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var faceBoundaryView: UIImageView!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    var isFaceDetected = false
    var isBlinkDetected = false
    private var lastEyeState: (left: Bool, right: Bool) = (false, false)
    private var lastCapturedImage: UIImage?
    private var currentSampleBuffer: CMSampleBuffer?



    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        setupUI()
    }

    func setupUI() {
        self.captureBtn.layer.cornerRadius = self.captureBtn.frame.width / 2
        self.captureBtn.isHidden = true
        self.retakeBtn.isHidden = true
        self.doneBtn.isHidden = true
        self.capturedImageView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCamera()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession?.stopRunning()
    }

    func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            self.captureSession = AVCaptureSession()
            self.captureSession.sessionPreset = .medium

            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                            for: .video,
                                                            position: .front) else {
                print("Unable to access front camera!")
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: frontCamera)
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                }

                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                if self.captureSession.canAddOutput(videoOutput) {
                    self.captureSession.addOutput(videoOutput)
                }

                self.captureSession.startRunning()

                DispatchQueue.main.async {
                    self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    self.videoPreviewLayer.videoGravity = .resizeAspectFill
                    self.videoPreviewLayer.connection?.videoOrientation = .portrait
                    self.videoPreviewLayer.frame = self.captureView.bounds
                    self.captureView.layer.insertSublayer(self.videoPreviewLayer, at: 0)
                }

            } catch {
                print("Error setting up camera input: \(error)")
            }
        }
    }


    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        currentSampleBuffer = sampleBuffer // 👈 store latest buffer for capture

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        detectFace(in: pixelBuffer)
    }

    // MARK: - Face & Blink Detection
    private func detectFace(in pixelBuffer: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                print("Face detection error: \(error.localizedDescription)")
                self.handleNoFaceDetected()
                return
            }

            guard let results = request.results as? [VNFaceObservation], let face = results.first else {
                self.handleNoFaceDetected()
                return
            }

            if !self.isFaceDetected {
                self.handleFaceInitiallyDetected()
            }

            if self.isFaceDetected && !self.isBlinkDetected {
                self.detectBlink(face: face)
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .leftMirrored,
                                            options: [:])
        try? handler.perform([faceDetectionRequest])
    }

    private func handleFaceInitiallyDetected() {
        isFaceDetected = true
        DispatchQueue.main.async {
            self.statusLabel.text = "Great! Now blink your eyes"
            self.statusLabel.textColor = .systemYellow
            self.statusLabel.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.statusLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }, completion: nil)
        }
    }

    private func handleNoFaceDetected() {
        isFaceDetected = false
        isBlinkDetected = false
        lastEyeState = (false, false)
        DispatchQueue.main.async {
            self.statusLabel.text = "Align your face with the guide"
            self.statusLabel.textColor = .white
            self.statusLabel.layer.removeAllAnimations()
            self.statusLabel.transform = .identity
            self.captureBtn.isHidden = true
        }
    }

    private func detectBlink(face: VNFaceObservation) {
        guard let landmarks = face.landmarks,
              let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else {
            return
        }

        let leftEyeClosed = isEyeClosed(leftEye)
        let rightEyeClosed = isEyeClosed(rightEye)

        if leftEyeClosed && rightEyeClosed && (!lastEyeState.left || !lastEyeState.right) {
            handleBlinkDetected()
        }

        lastEyeState = (leftEyeClosed, rightEyeClosed)
    }

    private func isEyeClosed(_ eye: VNFaceLandmarkRegion2D) -> Bool {
        let points = eye.normalizedPoints
        let eyeWidth = (points.map { $0.x }.max() ?? 0) - (points.map { $0.x }.min() ?? 0)
        let eyeHeight = (points.map { $0.y }.max() ?? 0) - (points.map { $0.y }.min() ?? 0)
        let ear = eyeHeight / eyeWidth
        return ear < 0.25
    }

    private func handleBlinkDetected() {
        isBlinkDetected = true
        DispatchQueue.main.async {
            self.statusLabel.text = "Perfect! Ready to capture"
            self.statusLabel.textColor = .systemGreen
            self.statusLabel.layer.removeAllAnimations()
            self.statusLabel.transform = .identity
            self.captureBtn.isHidden = false

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5, options: [], animations: {
                self.captureBtn.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    self.captureBtn.transform = .identity
                }
            }
        }
    }
    
    func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .leftMirrored)
    }
    
    @IBAction func onRetakeTapped(_ sender: UIButton) {
        captureBtn.isHidden = false
        doneBtn.isHidden = true
        retakeBtn.isHidden = true
        capturedImageView.isHidden = true
        self.view.sendSubviewToBack(retakeBtn)
        self.view.sendSubviewToBack(doneBtn)
//        if let boundaryView = self.faceBoundaryView {
//            boundaryView.isHidden = false
//        }
        isBlinkDetected = false
        lastEyeState = (false, false)
        statusLabel.text = "Align your face with the guide"
        statusLabel.textColor = .white
        statusLabel.isHidden = false
        // Restart the camera feed
            if !captureSession.isRunning {
                DispatchQueue.global(qos: .userInteractive).async{
                    self.captureSession.startRunning()
                }
            }
    }
    
    @IBAction func onCaptureTapped(_ sender: UIButton) {
        guard let buffer = currentSampleBuffer,
              let image = imageFromSampleBuffer(buffer) else { return }
        faceBoundaryView.isHidden = true
        lastCapturedImage = image
        capturedImageView.image = image
        capturedImageView.isHidden = false
        //self.view.bringSubviewToFront(capturedImageView)
        self.view.bringSubviewToFront(retakeBtn)
        self.view.bringSubviewToFront(doneBtn)
        captureBtn.isHidden = true
        doneBtn.isHidden = false
        retakeBtn.isHidden = false
        statusLabel.isHidden = true
        captureSession.stopRunning()
    }
    
    @IBAction func validateFaceAction(_ sender: Any) {
        guard let capturedImage = capturedImageView.image else { return }
        NetworkManager.validateFace(image: capturedImage, completion: { result in
            switch result {
            case .success(_):
                self.fetchChecklistQuestions()
            case .failure(let error):
                print("❌ Validation failed: \(error.localizedDescription)")
            }
        })
    }
    
    func fetchChecklistQuestions(){
        NetworkManager.getChecklistQuestions { data, error in
            if error == ""{
                self.navigateToQuestionsVC(questionsData: data ?? [])
            } else {
                self.displayAlert(title: "Error", message: "Failed to fetch checklist questions")
            }
        }
    }
    
    func navigateToQuestionsVC(questionsData:[Question]){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let questionsVC = storyBoard.instantiateViewController(withIdentifier: "QuestionsViewController") as? QuestionsViewController
        questionsVC?.questions = questionsData
        self.navigationController?.pushViewController(questionsVC!, animated: true)
    }
}

