import UIKit
import AVFoundation

class MainViewController : UIViewController {
    static let defaultTime = CFTimeInterval(10 * 60);
    
    var timer : Timer!
    var whiteClock : ClockView!
    var blackClock : ClockView!
    var activePieces = Pieces.black
    var player: AVAudioPlayer?

    var lastTime : CFTimeInterval = 0
    var totalTime = defaultTime
    var whiteRemainingTime = defaultTime
    var blackRemainingTime = defaultTime
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func loadView() {
        view = UIView()
        
        whiteClock = ClockView(pieces: Pieces.white)
        whiteClock.translatesAutoresizingMaskIntoConstraints = false
        whiteClock.transform = whiteClock.transform.rotated(by: deg2rad(180))
        view.addSubview(whiteClock)
        NSLayoutConstraint.activate([
            whiteClock.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            whiteClock.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5),
            whiteClock.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        let whiteTap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.tapWhiteClock(_:)))
        whiteClock.addGestureRecognizer(whiteTap)

        blackClock = ClockView(pieces: Pieces.black)
        blackClock.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blackClock)
        NSLayoutConstraint.activate([
            blackClock.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            blackClock.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5),
            blackClock.topAnchor.constraint(equalTo: whiteClock.bottomAnchor),
            blackClock.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        let blackTap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.tapBlackClock(_:)))
        blackTap.numberOfTapsRequired = 1
        blackClock.addGestureRecognizer(blackTap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MainViewController.longPress(_:)))
        view.addGestureRecognizer(longPress)

        resetTimer()
        self.view = view
        self.view.backgroundColor = UIColor.blue
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func longPress(_ sender: UITapGestureRecognizer) {
        let optionMenu = UIAlertController(title: "Restart", message: nil, preferredStyle: .alert)
        optionMenu.addAction(
            UIAlertAction(title: "30 Minute", style: .default) {
                UIAlertAction in
                self.totalTime = 30 * 60
                self.stopTimer()
                self.resetTimer()
        })
        optionMenu.addAction(
            UIAlertAction(title: "15 Minute", style: .default) {
                UIAlertAction in
                self.totalTime = 15 * 60
                self.stopTimer()
                self.resetTimer()
        })
        optionMenu.addAction(
            UIAlertAction(title: "10 Minute", style: .default) {
                UIAlertAction in
                self.totalTime = 10 * 60
                self.stopTimer()
                self.resetTimer()
        })
        optionMenu.addAction(
            UIAlertAction(title: "5 Minutes", style: .default) {
                UIAlertAction in
                self.totalTime = 5 * 60
                self.stopTimer()
                self.resetTimer()
        })
        optionMenu.addAction(
            UIAlertAction(title: "1 Minute", style: .default) {
                UIAlertAction in
                self.totalTime = 1 * 60
                self.stopTimer()
                self.resetTimer()
        })
        optionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func tapWhiteClock(_ sender: UITapGestureRecognizer) {
        if (!expired() && activePieces == Pieces.white) {
            activePieces = Pieces.black
            whiteClock.setActive(false)
            blackClock.setActive(true)
            stopTimer()
            startTimer()
        }
    }
    
    @objc func tapBlackClock(_ sender: UITapGestureRecognizer) {
        if (!expired() && activePieces == Pieces.black) {
            activePieces = Pieces.white
            whiteClock.setActive(true)
            blackClock.setActive(false)
            stopTimer()
            startTimer()
        }
    }
    
    func expired() -> Bool {
        return whiteRemainingTime <= 0 || blackRemainingTime <= 0
    }

    func resetTimer() {
        stopTimer()
        whiteRemainingTime = totalTime
        blackRemainingTime = totalTime
        
        blackClock.setTotalTime(totalTime)
        whiteClock.setTotalTime(totalTime)
        blackClock.setRemainingTime(totalTime)
        whiteClock.setRemainingTime(totalTime)
        whiteClock.setActive(false)
        blackClock.setActive(false)
        activePieces = Pieces.black
    }
    
    func stopTimer() {
        if (timer != nil) {
            timer.invalidate()
            timer = nil
        }
    }
    
    func startTimer() {
        if (timer != nil || expired()) {
            return
        }
        lastTime = CACurrentMediaTime()
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { timer in
            self.updateTime()
        })
        playSound(activePieces == Pieces.white ? "snap1" : "snap2")
    }
    
    func updateTime() {
        let now = CACurrentMediaTime()
        let elapsed = now - lastTime
        lastTime = now
        
        if (activePieces == Pieces.white) {
            whiteRemainingTime -= elapsed
            whiteClock.setRemainingTime(whiteRemainingTime)
        } else {
            blackRemainingTime -= elapsed
            blackClock.setRemainingTime(blackRemainingTime)
        }
        
        if (whiteRemainingTime <= 0 || blackRemainingTime <= 0) {
            playSound("ticktock")
            stopTimer()
        }
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }

    func playSound(_ soundName : String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

