import Foundation

class GreenhouseState {
    
    private let subscribedTopics = [MQTTInfo.Topics.all]
    
    private var temperatureOuside: String
    private var pressureOutside: String
    
    private var insideTemperature: String
    private var insideHumidity: String
    private var soilMoisture: String
    private var soilTemperature: String
    
    private var manualMode: Bool
    private var enoughWater: Bool
    private var watering: Bool
    
    private var light: Bool
    
    init() {
        
        self.temperatureOuside = "0.0"
        self.pressureOutside = "0.0"
        
        self.manualMode = false
        self.enoughWater = true
        self.watering = false
        
        self.insideTemperature = "0.0"
        self.insideHumidity = "0.0"
        self.soilMoisture = "0.0"
        self.soilTemperature = "0.0"
        
        self.light = false

        
        for topic in subscribedTopics {
            NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_:)), name: NSNotification.Name(rawValue: topic), object: nil)
        }
    }
    
    @objc func notificationReceived(_ notification: NSNotification) {
        
        if let topic = notification.userInfo?["topic"] as? String {
            switch topic {
                
                case MQTTInfo.Topics.outTemperature :
                    self.temperatureOuside = notification.userInfo?["message"] as! String
                
                case MQTTInfo.Topics.outPressure:
                    self.pressureOutside = notification.userInfo?["message"] as! String
                
                case MQTTInfo.Topics.inTemperature:
                    self.insideTemperature = notification.userInfo?["message"] as! String
                
                case MQTTInfo.Topics.inHumidity:
                    self.insideHumidity = notification.userInfo?["message"] as! String
                
                case MQTTInfo.Topics.inSoilTemperature:
                    self.soilTemperature = notification.userInfo?["message"] as! String
                
                case MQTTInfo.Topics.inSoilMoisture:
                    self.soilMoisture = notification.userInfo?["message"] as! String
                
                case MQTTInfo.Topics.outWaterLevel:
                    let isEnough = notification.userInfo?["message"] as? String
                    if (isEnough == "1") {
                        self.enoughWater = true
                    } else {
                        self.enoughWater = false
                    }
                
                case MQTTInfo.Topics.outManualMode:
                    let manualMode = notification.userInfo?["message"] as? String
                    if (manualMode == "1") {
                        self.manualMode = true
                    } else {
                        self.manualMode = false
                    }
                
                case MQTTInfo.Topics.outIsWatering:
                    let watering = notification.userInfo?["message"] as? String
                    if (watering == "1") {
                        self.watering = true
                    } else {
                        self.watering = false
                    }
                
                case MQTTInfo.Topics.inIsLight:
                    let light = notification.userInfo?["message"] as? String
                    if (light == "1") {
                        self.light = true
                    } else {
                        self.light = false
                    }
        
                default :
                    break
            }
        }
    }
    
    public func getOutTemperature() -> String {
        return self.temperatureOuside
    }
    
    public func getOutPressure() -> String {
        return self.pressureOutside
    }
    
    public func getInTemperature() -> String {
        return self.insideTemperature
    }
    
    public func getInHumidity() -> String {
        return self.insideHumidity
    }
    
    public func getSoilTemperature() -> String {
        return self.soilTemperature
    }
    
    public func getSoilMoisture() -> String {
        return self.soilMoisture
    }
    
    public func isLight() -> Bool {
        return self.light
    }
    
    public func isManualMode() -> Bool {
        return self.manualMode
    }
    
    public func isEnoughWater() -> Bool {
        return self.enoughWater
    }
    
    public func isWatering() -> Bool {
        return self.watering
    }
}
