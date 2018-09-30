//
//  ViewController.swift
//  AnimalPokedex
//
//  Created by Graeme Cox on 2018-09-30.
//  Copyright © 2018 Graeme Cox. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var label_text: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        setup camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice =
            AVCaptureDevice.default(for: .video) else {return }
        guard let input = try? AVCaptureDeviceInput(device:
            captureDevice) else {return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        // want to fill view layer with out capture preview
        let previewLayer = AVCaptureVideoPreviewLayer(session:
            captureSession) // so we can see output
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        // want to start looking at video output
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue:
            DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput) //want to monitor what happens each time camera grabs a frame
    }
//
//    /*
//     Every time our camera captures a frame, we are going to run it through the model
//
//     */
    func captureOutput(_ output: AVCaptureOutput, didOutput
        sampleBuffer: CMSampleBuffer, from connection:
        AVCaptureConnection) {
        //        print("Camera captured a frame", Date())
        //
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return }

        //        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {return}
        guard let model = try? VNCoreMLModel(for:
            Inceptionv3().model) else {return}
        let request = VNCoreMLRequest(model: model)
        { (finishedReq, err) in
            // perhaps check the err

            //            print(finishedReq.results)
            guard let results = finishedReq.results as?
                [VNClassificationObservation] else { return }

            guard let firstObservation = results.first else
            { return }
//            print(firstObservation.identifier,
//                firstObservation.confidence)
            //self.drawVisionRequestResults(results)
            if (firstObservation.confidence > 0.70){ //only print results if over 70% sure
                print(firstObservation.identifier,
                      firstObservation.confidence)
                DispatchQueue.main.async{
                    self.label_text.text = firstObservation.identifier + " = " + String(firstObservation.confidence) + "%"
                }
            }

        }
        try?VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                  options: [:]).perform([request]) // will execute request, then tell us what the object is
    }

}

