//
//  ViewController.swift
//  ARTranslator
//
//  Created by Nora AlNashwan on 18/06/2018.
//  Copyright © 2018 Nora AlNashwan. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    
    let session = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    let sessionQueue = DispatchQueue(label: "session queue",
                                     attributes: [],
                                     target: nil)
    var previewLayer : AVCaptureVideoPreviewLayer!
    var videoDeviceInput: AVCaptureDeviceInput!
    var setupResult: SessionSetupResult = .success
    
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorization()
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                DispatchQueue.main.async { [unowned self] in
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                    self.previewLayer.frame = self.previewView.bounds
                    self.previewView.layer.addSublayer(self.previewLayer)
                    self.session.startRunning()
                }
            case .notAuthorized:
                DispatchQueue.main.async { [unowned self] in
                    self.showAlert(alertTitle: "AVCam", alertMessage: NSLocalizedString("changePrivacySetting",comment:""), withSettings: true)
                }
            case .configurationFailed:
                DispatchQueue.main.async { [unowned self] in
                    self.showAlert(alertTitle: "Unable to capture media", alertMessage: NSLocalizedString("configurationErrorMessage",comment:""), withSettings: false)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async { [unowned self] in
            if self.setupResult == .success {
                self.session.stopRunning()
            }
        }
        super.viewWillDisappear(animated)
    }
   
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            break
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
    }
    
    // Crate and add video device input then add photo output.
    private func configureSession() {
        if setupResult != .success {
            return
        }
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.photo
        do {
            var defaultVideoDevice: AVCaptureDevice?
            let dualCameraDeviceType: AVCaptureDevice.DeviceType
            if #available(iOS 11, *) {
                dualCameraDeviceType = .builtInDualCamera
            } else {
                dualCameraDeviceType = .builtInDuoCamera
            }
            
            if let dualCameraDevice = AVCaptureDevice.default(dualCameraDeviceType, for: AVMediaType.video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                showAlert(alertMessage: NSLocalizedString("InputAdditionErrorMessage", comment: ""), withSettings: false)
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            showAlert(alertMessage: NSLocalizedString("InputCreationErrorMessage", comment: "")+error.localizedDescription, withSettings: false)
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        } else {
            showAlert(alertMessage: NSLocalizedString("OutputAdditionErrorMessage", comment: ""), withSettings: false)
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
    }
    
    @IBAction private func capturePhoto(_ sender: UIButton) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        if self.videoDeviceInput.device.isFlashAvailable {
            photoSettings.flashMode = .auto
        }

        if let firstAvailablePreviewPhotoPixelFormatTypes = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: firstAvailablePreviewPhotoPixelFormatTypes]
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

// #MARK: - AVCapturePhotoCaptureDelegate Methods
extension ViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            showAlert(alertMessage: "Error capturing photo: \(error)", withSettings: false)
        } else {
            if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
                if let image = UIImage(data: dataImage) {
                    let imageViewController = self.storyboard!.instantiateViewController(withIdentifier: "ImageVC") as! ImageViewController
                    imageViewController.capturedImage = image
                    self.navigationController!.pushViewController(imageViewController, animated: true)
                }
            }
        }
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
            let image =  UIImage(data: data) else {
                return
        }
        let imageViewController = self.storyboard!.instantiateViewController(withIdentifier: "ImageVC") as! ImageViewController
        imageViewController.capturedImage = image
        self.navigationController!.pushViewController(imageViewController, animated: true)
    }
    
    func showAlert(alertTitle: String = "", alertMessage: String, withSettings: Bool) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        if withSettings {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""),
                                                    style: .`default`,
                                                    handler: { _ in
                                                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
}

