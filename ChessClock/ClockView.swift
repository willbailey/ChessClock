import UIKit

class ClockView : UIView {
    
    var pieces : Pieces!
    var textView : UILabel!
    var totalTime : CFTimeInterval = 0
    var remainingTime : CFTimeInterval = 0
    var active = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(pieces: Pieces) {
        self.init(frame: .zero)
        self.pieces = pieces
        setupView()
    }
    
    func setTotalTime(_ totalTime : CFTimeInterval) {
        self.totalTime = totalTime
        setNeedsDisplay()
    }
    
    func setRemainingTime(_ remainingTime : CFTimeInterval) {
        self.remainingTime = remainingTime
        let time = formatTime(remainingTime)
        textView.text = time
        setNeedsDisplay()
    }
    
    func setActive(_ active : Bool) {
        self.active = active
        updateTextColor()
        setNeedsDisplay()
    }
    
    func formatTime(_ time : CFTimeInterval) -> String {
        if (time <= 0) {
            return "0:00"
        }
        let minutes = Int(ceil(time)) / 60
        let remainingSeconds = Int(ceil(time)) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    func setupView() {
        textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.monospacedDigitSystemFont(ofSize: 70, weight: UIFont.Weight.bold)
        updateTextColor()

        textView.textAlignment  = NSTextAlignment.center
        textView.backgroundColor = UIColor.clear
        textView.text = " "
        textView.sizeToFit()
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalTo: self.widthAnchor),
            textView.heightAnchor.constraint(equalToConstant: textView.frame.height),
            textView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func updateTextColor() {
        if (self.active) {
            textView.textColor = UIColor.red
        } else {
            textView.textColor = pieces == Pieces.white ? UIColor.black : UIColor.white
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bg = UIBezierPath(rect: rect)
        (pieces == Pieces.white ? UIColor.white : UIColor.black).setFill()
        bg.fill()
        
        let trackColor = UIColor.init(white: pieces == Pieces.white ? 0.0 : 1.0, alpha: 0.2)
        circle(rect: rect, progress: 1.0, color: trackColor, thickness: 1.0)
        
        let progressColor = self.active ? UIColor.red : (self.pieces == Pieces.white ? UIColor.black : UIColor.white)
        circle(rect: rect, progress: CGFloat(remainingTime / totalTime), color: progressColor, thickness: 2.5)
    }
    
    func circle(rect : CGRect, progress : CGFloat, color : UIColor, thickness : CGFloat) {
        let dim = min(rect.width, rect.height) * 0.75
        var path : UIBezierPath
        color.setStroke()
        if progress == 1.0 {
            let ovalRect = CGRect(origin: CGPoint(x: rect.midX - dim / 2, y: rect.midY - dim / 2), size: CGSize(width: dim, height: dim))
            path = UIBezierPath(ovalIn: ovalRect)
            path.lineWidth = thickness
            path.lineCapStyle = CGLineCap.round
            path.stroke()
        } else if progress > 0 {
            let start = deg2rad(270)
            let end = deg2rad(progress * 360 - 90)
            path = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY),
                                radius: (dim / 2),
                                startAngle: start,
                                endAngle: end,
                                clockwise: true)
            path.lineWidth = thickness
            path.lineCapStyle = CGLineCap.round
            path.stroke()
        }
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
}
