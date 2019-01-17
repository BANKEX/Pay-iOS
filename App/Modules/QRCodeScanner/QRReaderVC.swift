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
    
    enum State {
        case success,error,standard
    }


    let defautText = NSLocalizedString("ScanQR", comment: "")
    let errorText = NSLocalizedString("QRNotRec", comment: "")
    let successText = NSLocalizedString("Scanning", comment: "")
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    var captureSession:AVCaptureSession!
    var state:State = .standard {
        didSet {
            switch state {
            case .error:
                messageLabel.text = errorText
                lineView.backgroundColor = UIColor.QRReader.errorColor
                greenLayer.strokeColor = UIColor.QRReader.errorColor.cgColor
            case .success:
                messageLabel.text = successText
                lineView.backgroundColor = UIColor.QRReader.successColor
                greenLayer.strokeColor = UIColor.QRReader.successColor.cgColor
            case .standard:
                messageLabel.text = defautText
                lineView.backgroundColor = UIColor.QRReader.defaultColor
                greenLayer.strokeColor = UIColor.QRReader.defaultColor.cgColor
            }
        }
    }
    
    weak var delegate:QRReaderVCDelegate?
    
    var messageLabel:UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.sizeToFit()
        lbl.numberOfLines = 0
        return lbl
    }()
    
    var lineView:UIView = UIView()
    
    var qrCodeView:UIView = {
        let view = UIView()
        //        view.layer.borderColor = UIColor.white.cgColor
        //        view.layer.borderWidth = 4.0
        return view
    }()
    
    lazy var greenLayer: CAShapeLayer = {
        let greenLayer = CAShapeLayer()
        greenLayer.fillColor = UIColor.clear.cgColor
        greenLayer.lineWidth = 4.0
        let distance = NSNumber(value:Float(qrCodeView.bounds.width/2))
        greenLayer.lineDashPattern = [distance,distance]
        greenLayer.lineDashPhase = CGFloat((distance.floatValue)/2)
        return greenLayer
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .white
    }
    
    fileprivate func auth() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.setupSession()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                }
            }
        case .restricted: return
        case .denied: return
        }
    }
    
    fileprivate func configurationSesion() {
        captureSession.beginConfiguration()
        addInput()
        addOutput()
        captureSession.commitConfiguration()
    }
    
    fileprivate func addInput() {
        let videoDevice = AVCaptureDevice.default(for: .video)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
    }
    
    fileprivate func addOutput() {
        let metaDataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metaDataOutput) else { return }
        captureSession.addOutput(metaDataOutput)
        metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }
    
    
    
    
    fileprivate func setupSession() {
        captureSession = AVCaptureSession()
        configurationSesion()
        layoutViews()
        state = .standard
        captureSession.startRunning()
    }
    
    @objc func fadeOut() {
        captureSession.stopRunning()
        dismiss(animated: true, completion: nil)
    }
    
    
    fileprivate func layoutViews() {
        layoutVideoPreview()
        layoutMessageLbl()
        layoutFocusView()
        layoutCloseButton()
    }
    
    fileprivate func layoutCloseButton() {
        let widthOfClosebtn:CGFloat = 32.0
        let closeBtn = UIButton(frame: CGRect(x: 22.0, y: widthOfClosebtn * 1.5, width: widthOfClosebtn, height: widthOfClosebtn))
        closeBtn.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        closeBtn.layer.cornerRadius = widthOfClosebtn/2
        closeBtn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        closeBtn.addTarget(self, action: #selector(fadeOut), for: .touchUpInside)
        view.addSubview(closeBtn)
    }
    
    fileprivate func layoutFocusView() {
        let width = view.bounds.width/1.5
        qrCodeView.frame = CGRect(x: view.bounds.midX - width/2, y: view.bounds.midY - width/2, width: width, height: width)
        
        greenLayer.path = UIBezierPath(rect: qrCodeView.bounds).cgPath
        let w = qrCodeView.bounds.width/2
        lineView.frame = CGRect(x:qrCodeView.bounds.midX - w/2, y: qrCodeView.bounds.midY - 0.5, width: w, height: 1.0)
        qrCodeView.addSubview(lineView)
        qrCodeView.bringSubview(toFront: lineView)
        qrCodeView.layer.addSublayer(greenLayer)
        view.addSubview(qrCodeView)
        view.bringSubview(toFront: qrCodeView)
    }
    
    fileprivate func layoutMessageLbl() {
        messageLabel.frame.size = CGSize(width: view.bounds.width/1.5, height:80.0)
        messageLabel.frame.origin = CGPoint(x: view.bounds.midX - messageLabel.bounds.width/2, y: view.bounds.maxY - 90.0)
        view.addSubview(messageLabel)
        view.bringSubview(toFront: messageLabel)
    }
    
    fileprivate func layoutVideoPreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            state = .standard
            return
        }
        guard let metaDataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            state = .error
            return }
        if metaDataObject.type == AVMetadataObject.ObjectType.qr {
            state = .success
            if let str = metaDataObject.stringValue {
                if str.count == 64 || str.prefix(2) == "0x" || str.hasPrefix("ethereum:") {
                    state = .success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.delegate?.didScan(str)
                        self.dismiss(animated: true, completion: {
                            self.captureSession.stopRunning()
                        })
                    }
                }else {
                    state = .error
                }
            }else {
                state = .error
            }
        }
    }
}
