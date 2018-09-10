//
//  QRReaderVC.swift
//  BankexWallet
//
//  Created by Vladislav on 10.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRReaderVCDelegate:class {
    func didScan(_ result:String)
}

class QRReaderVC: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    
    
    weak var delegate:QRReaderVCDelegate?
    
    var messageLabel:UILabel = {
        let lbl = UILabel()
        lbl.text = "Scan QR Code"
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.sizeToFit()
        lbl.numberOfLines = 0
        return lbl
    }()
    
    var lineView:UIView!
    
    var qrCodeView:UIView = {
        let view = UIView()
        //        view.layer.borderColor = UIColor.white.cgColor
        //        view.layer.borderWidth = 4.0
        return view
    }()
    
    lazy var greenLayer: CAShapeLayer = {
        let greenLayer = CAShapeLayer()
        greenLayer.fillColor = UIColor.clear.cgColor
        greenLayer.strokeColor = UIColor.white.cgColor
        greenLayer.lineWidth = 4.0
        let distance = NSNumber(value:Float(qrCodeView.bounds.width/2))
        greenLayer.lineDashPattern = [distance,distance]
        greenLayer.lineDashPhase = CGFloat((distance.floatValue)/2)
        return greenLayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    self.setupSession()
                }
            }
        case .restricted: return
        case .denied: return
        }
        
    }
    
    func setupSession() {
        let captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(for: .video)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        let metaDataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metaDataOutput) else { return }
        captureSession.addOutput(metaDataOutput)
        metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        captureSession.commitConfiguration()
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        messageLabel.frame.origin = CGPoint(x: view.bounds.midX - messageLabel.bounds.width, y: view.bounds.maxY - 90.0)
        messageLabel.frame.size = CGSize(width: view.bounds.width/1.5, height:80.0)
        view.addSubview(messageLabel)
        view.bringSubview(toFront: messageLabel)
        let width = view.bounds.width/1.5
        qrCodeView.frame = CGRect(x: view.bounds.midX - width/2, y: view.bounds.midY - width/2, width: width, height: width)
        
        greenLayer.path = UIBezierPath(rect: qrCodeView.bounds).cgPath
        let w = qrCodeView.bounds.width/2
        lineView = UIView(frame: CGRect(x:qrCodeView.bounds.midX - w/2, y: qrCodeView.bounds.midY - 0.5, width: w, height: 1.0))
        lineView.backgroundColor = UIColor.white
        qrCodeView.addSubview(lineView)
        qrCodeView.bringSubview(toFront: lineView)
        qrCodeView.layer.addSublayer(greenLayer)
        view.addSubview(qrCodeView)
        view.bringSubview(toFront: qrCodeView)
        //add close btn
        let widthOfClosebtn:CGFloat = 32.0
        let closeBtn = UIButton(frame: CGRect(x: 22.0, y: widthOfClosebtn * 1.5, width: widthOfClosebtn, height: widthOfClosebtn))
        closeBtn.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        closeBtn.layer.cornerRadius = widthOfClosebtn/2
        closeBtn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        closeBtn.addTarget(self, action: #selector(fadeOut), for: .touchUpInside)
        view.addSubview(closeBtn)
        captureSession.startRunning()
    }
    
    @objc func fadeOut() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            messageLabel.text = "Scan QR Code"
            greenLayer.strokeColor = UIColor.white.cgColor
            lineView.backgroundColor = UIColor.white
            return
        }
        guard let metaDataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            qrCodeView.layer.borderColor = UIColor.red.cgColor
            messageLabel.text = "QR Code is not recognized. Please try again."
            return }
        if metaDataObject.type == AVMetadataObject.ObjectType.qr {
            qrCodeView.layer.borderColor = UIColor.green.cgColor
            if let str = metaDataObject.stringValue {
                if str.count == 64 || str.prefix(2) == "0x" {
                    greenLayer.strokeColor = UIColor.green.cgColor
                    lineView.backgroundColor = UIColor.green
                    messageLabel.text = "Scanning..."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true, completion: {
                            self.delegate?.didScan(str)
                            //StopScanning
                        })
                    }
                }else {
                    greenLayer.strokeColor = UIColor.red.cgColor
                    lineView.backgroundColor = UIColor.red
                    messageLabel.text = "QR Code is not recognized. Please try again."
                }
            }else {
                greenLayer.strokeColor = UIColor.red.cgColor
                lineView.backgroundColor = UIColor.red
                messageLabel.text = "QR Code is not recognized. Please try again."
            }
        }
    }
}
