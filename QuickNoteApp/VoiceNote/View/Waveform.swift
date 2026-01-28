import UIKit

class WaveformLineView: UIView {
    
    var barWidth: CGFloat = 3.0
    var barGap: CGFloat = 3.0
    var barColor: UIColor = .white
    private var levels: [CGFloat] = []
    
    func reset() {
        levels.removeAll()
        setNeedsDisplay()
    }
    
    func setLevels(_ levels: [CGFloat]) {
        self.levels = levels
        setNeedsDisplay()
    }
    
    func addLevel(_ level: CGFloat) {
        let value = max(0.1, min(1.0, level))
        levels.append(value)
        
        let totalBarWidth = barWidth + barGap
        let maxBars = Int(bounds.width / totalBarWidth)
        if levels.count > maxBars && maxBars > 0 {
            levels.removeFirst()
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !levels.isEmpty else { return }
        
        let centerY = rect.height / 2
        let totalBarWidth = barWidth + barGap
        
        context.setFillColor(barColor.cgColor)
        
        // Calculate start position to center the waveform if it's short
        let totalContentWidth = CGFloat(levels.count) * totalBarWidth
        var xOffset: CGFloat = 0
        if totalContentWidth < rect.width {
            xOffset = (rect.width - totalContentWidth) / 2
        }
        
        for (i, level) in levels.enumerated() {
            let x = xOffset + CGFloat(i) * totalBarWidth
            let height = (rect.height * 0.8) * level // 80% of view height
            let y = centerY - (height / 2)
            
            let barRect = CGRect(x: x, y: y, width: barWidth, height: height)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 2)
            path.fill()
        }
    }
}
