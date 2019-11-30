import Foundation

class Countdown {
    
    private var duration: Int
    private var secondsRemaining: Int
    private var timer: Timer?
    private let formatter = DateComponentsFormatter()
    
    private var tick: ((String?) -> ())?
    private var timeOver: (() -> ())?
    
    init(duration: Int, tick: ((String?) -> ())?, timeOver: (() -> ())?) {
        self.duration = duration
        self.secondsRemaining = duration
        self.tick = tick
        self.timeOver = timeOver
        
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
    }
    
    func start() {
        if timer != nil { print("Timer already started"); return }
        
        secondsRemaining = duration
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [unowned self] (timer) in
            if self.secondsRemaining == 0 {
                self.stop()
                self.timeOver?()
            }
            
            let secondsRemainingAsString = self.formatter.string(from: TimeInterval(self.secondsRemaining))
            self.secondsRemaining -= 1
            self.tick?(secondsRemainingAsString)
        })
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        stop()
        start()
    }
    
}
