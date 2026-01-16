import UIKit

class WaveformLineView: UIView {
    
    // MARK: - Configuration
    var barWidth: CGFloat = 4.0
    var barGap: CGFloat = 5.0
    var barColor: UIColor = .white
//    var cursorColor: UIColor = UIColor(red: 238/255, green: 162/255, blue: 120/255, alpha: 1.0)
    
    // ADD THIS PROPERTY
//    var showCursor: Bool = true
    
    // MARK: - Data
    private var levels: [CGFloat] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    private func setup() {
        // DO NOT USE .white here. Use .clear
        self.backgroundColor = .clear
        self.isOpaque = false // This helps the GPU render transitions better
        self.contentMode = .redraw
    }
    
    func reset() {
        levels.removeAll()
        setNeedsDisplay()
    }
    
    // ADD THIS METHOD (For Core Data support)
    func setLevels(_ newLevels: [CGFloat]) {
        self.levels = newLevels
        setNeedsDisplay()
    }
    
    func addLevel(_ level: CGFloat) {
        let value = max(0.1, min(1.0, level))
        levels.append(value)
        
        let totalBarWidth = barWidth + barGap
        if bounds.width > 0 {
            let maxBars = Int(bounds.width / totalBarWidth)
            if levels.count > maxBars {
                levels.removeFirst(levels.count - maxBars)
            }
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let centerY = rect.height / 2
        let totalBarWidth = barWidth + barGap
        
        // 1. Draw Bars
        context.setFillColor(barColor.cgColor)
        
        let totalContentWidth = CGFloat(levels.count) * totalBarWidth
        var startX: CGFloat = 0
        
        if totalContentWidth < rect.width {
            startX = (rect.width - totalContentWidth) / 2
        }
        
        for (i, level) in levels.enumerated() {
            let x = startX + CGFloat(i) * totalBarWidth
            let height = (rect.height * 0.7) * level
            let y = centerY - (height / 2)
            
            let barRect = CGRect(x: x, y: y, width: barWidth, height: height)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 2)
            path.fill()
        }
        
//        // 2. Draw Orange Cursor (Wrap this in the showCursor check)
//        if showCursor && !levels.isEmpty {
//            context.setStrokeColor(cursorColor.cgColor)
//            context.setFillColor(cursorColor.cgColor)
//            context.setLineWidth(2.0)
//            
//            let cursorX = min(startX + totalContentWidth, rect.width - 2)
//            
//            context.move(to: CGPoint(x: cursorX, y: 15))
//            context.addLine(to: CGPoint(x: cursorX, y: rect.height - 15))
//            context.strokePath()
//            
//            let topDot = CGRect(x: cursorX - 4, y: 15 - 4, width: 8, height: 8)
//            context.fillEllipse(in: topDot)
//            
//            let bottomDot = CGRect(x: cursorX - 4, y: rect.height - 15 - 4, width: 8, height: 8)
//            context.fillEllipse(in: bottomDot)
//        }
    }
}
