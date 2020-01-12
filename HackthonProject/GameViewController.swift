//
//  ViewController.swift
//  HackthonProject
//
//  Created by Rahul Narayanan on 1/11/20.
//  Copyright © 2020 Rahul Narayanan. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVKit


class GameViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet var timeVisualView: UIVisualEffectView!
    @IBOutlet var timeLabel: UILabel!
    
    var level: Level!
    
    var timer: Timer?
    var timeLeft = 300 {
        didSet {
            timeLabel.text = "Time: \(timeLeft)"
        }
    }
    
    var currentFlower = ""
    
    let captureSession = AVCaptureSession()
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var cardViewController:CardViewController!
    var visualEffectView:UIVisualEffectView!
    
    let cardHeight:CGFloat = 350
    let cardHandleAreaHeight:CGFloat = 95
    
    var cardVisible = false {
        didSet {
            if cardVisible == true {
                UIView.animate(withDuration: 0.2) {
                    self.cardViewController.challengeLabel.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.cardViewController.challengeLabel.alpha = 1
                }
            }
        }
    }
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.view.bringSubviewToFront(visualView)
        
        timeVisualView.layer.cornerRadius = 6.0
        
        self.navigationController?.navigationBar.tintColor = .yellow
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.title = level.name
        
        
        switch level.gameMode {
        case .seek:
            timeVisualView.isHidden = false
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(secondsDown), userInfo: nil, repeats: true)
        default:
            timeVisualView.isHidden = true
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupCaptureSession()
        self.setupCard()
        
        self.view.bringSubviewToFront(timeVisualView)

        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    @objc func secondsDown(){
        
        timeLeft -= 1
        
        if timeLeft <= 0 {
            timer!.invalidate()
            timer = nil
            
            let alert = UIAlertController(title: "You ran out of time!", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Back to home", style: .cancel, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func setupCard() {
        visualEffectView = UIVisualEffectView()
            visualEffectView.frame = self.view.frame
            self.view.addSubview(visualEffectView)
            
            cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
            cardViewController.level = self.level
            self.addChild(cardViewController)
            self.view.addSubview(cardViewController.view)
            
            cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
            
            cardViewController.view.clipsToBounds = true
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.handleCardTap(recognzier:)))
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.handleCardPan(recognizer:)))
            
            cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
            cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
            

    }
    
    @objc
       func handleCardTap(recognzier:UITapGestureRecognizer) {
           switch recognzier.state {
           case .ended:
               animateTransitionIfNeeded(state: nextState, duration: 0.9)
           default:
               break
           }
       }
       
       @objc
       func handleCardPan (recognizer:UIPanGestureRecognizer) {
           switch recognizer.state {
           case .began:
               startInteractiveTransition(state: nextState, duration: 0.9)
           case .changed:
               let translation = recognizer.translation(in: self.cardViewController.handleArea)
               var fractionComplete = translation.y / cardHeight
               fractionComplete = cardVisible ? fractionComplete : -fractionComplete
               updateInteractiveTransition(fractionCompleted: fractionComplete)
           case .ended:
               continueInteractiveTransition()
           default:
               break
           }
           
       }
       
       func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
           if runningAnimations.isEmpty {
               let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                   switch state {
                   case .expanded:
                       self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                   case .collapsed:
                       self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                   }
               }
               
               frameAnimator.addCompletion { _ in
                   self.cardVisible = !self.cardVisible
                   self.runningAnimations.removeAll()
               }
               
               frameAnimator.startAnimation()
               runningAnimations.append(frameAnimator)
               
               
               let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                   switch state {
                   case .expanded:
                       self.cardViewController.view.layer.cornerRadius = 12
                   case .collapsed:
                       self.cardViewController.view.layer.cornerRadius = 0
                   }
               }
               
               cornerRadiusAnimator.startAnimation()
               runningAnimations.append(cornerRadiusAnimator)
               
               let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                   switch state {
                   case .expanded:
                       self.visualEffectView.effect = UIBlurEffect(style: .dark)
                   case .collapsed:
                       self.visualEffectView.effect = nil
                   }
               }
               
               blurAnimator.startAnimation()
               runningAnimations.append(blurAnimator)
               
           }
       }
       
       func startInteractiveTransition(state:CardState, duration:TimeInterval) {
           if runningAnimations.isEmpty {
               animateTransitionIfNeeded(state: state, duration: duration)
           }
           for animator in runningAnimations {
               animator.pauseAnimation()
               animationProgressWhenInterrupted = animator.fractionComplete
           }
       }
       
       func updateInteractiveTransition(fractionCompleted:CGFloat) {
           for animator in runningAnimations {
               animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
           }
       }
       
       func continueInteractiveTransition (){
           for animator in runningAnimations {
               animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
           }
       }
    
    func setupCaptureSession() {
        
        captureSession.sessionPreset = .hd1920x1080
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier_1().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            //                        print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            let flowerName = firstObservation.identifier.capitalized
            
            DispatchQueue.main.async {
                
                switch self.level.gameMode {
                case .explore:
                    if firstObservation.confidence > 0.9 {
                        self.cardViewController.itemLabel.text = flowerName
                        self.cardViewController.descriptionLabel.text = flowerDescriptions[flowers.firstIndex(of: flowerName) ?? 0]
                    } else {
                        self.cardViewController.itemLabel.text = "----"
                    }
                case .seek:
                    if firstObservation.confidence > 0.95 {
                        self.cardViewController.itemLabel.text = flowerName
                        self.currentFlower = flowerName
                    } else {
                        self.cardViewController.itemLabel.text = "----"
                    }
                case .learn:
                    if firstObservation.confidence > 0.97 {
                        self.cardViewController.currentFlower = flowerName
                        self.captureSession.stopRunning()
                        self.cardViewController.itemLabel.text = "Test Your Knowledge"
                        self.animateTransitionIfNeeded(state: self.nextState, duration: 0.9)
                        
                    }
                }
                
                
//                if firstObservation.confidence > 0.95 {
//                    self.cardViewController.itemLabel.text = firstObservation.identifier
//                } else {
//                    self.cardViewController.itemLabel.text = "Try a different angle"
//                }
                
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }


}

extension GameViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if level.gameMode == .seek {
            
            let guessFlower = level.flowers!.first
            
            if currentFlower == guessFlower {
                
                let alert = UIAlertController(title: "Congrats!", message: nil, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Back to home", style: .cancel, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                
                self.present(alert, animated:true)
                
                
                
            }
        }
        
    }
    
}

