import UIKit

class WateringVC: UIViewController {
    
    let green = UIColor(red: 85, green: 188, blue: 159, alpha: 1)
    let red = UIColor(red: 178, green: 42, blue: 90, alpha: 1)
    
    let subscribedTopics = [MQTTInfo.Topics.inSoilTemperature, MQTTInfo.Topics.inSoilMoisture, MQTTInfo.Topics.outWaterLevel, MQTTInfo.Topics.outIsWatering, MQTTInfo.Topics.outManualMode]

    @IBOutlet weak var soilTemperature: UILabel!
    @IBOutlet weak var soilMoisture: UILabel!
    
    @IBOutlet weak var manualModeSwitcher: UISwitch!
    @IBOutlet weak var wateringSwitcher: UISwitch!
    
    @IBOutlet weak var waterIndicator: UILabel!
    
    var greenhouse = GreenhouseState()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        waterIndicator.layer.cornerRadius = 10
        waterIndicator.clipsToBounds = true
        
        for topic in subscribedTopics {
            NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_:)), name: NSNotification.Name(rawValue: topic), object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        self.soilTemperature.text = GreenhouseState.shared.getSoilTemperature()
//        self.soilMoisture.text = GreenhouseState.shared.getSoilMoisture()
//
//        manualModeSwitcher.setOn(GreenhouseState.shared.isManualMode(), animated: true)
//        wateringSwitcher.setOn(GreenhouseState.shared.isWatering(), animated: true)
        
        self.soilTemperature.text = greenhouse.getSoilTemperature()
        self.soilMoisture.text = greenhouse.getSoilMoisture()
        
        manualModeSwitcher.setOn(greenhouse.isManualMode(), animated: true)
        wateringSwitcher.setOn(greenhouse.isWatering(), animated: true)

    }
        
    @objc func notificationReceived(_ notification: NSNotification) {
        
        if let topic = notification.userInfo?["topic"] as? String {
            
            switch topic {
                
                case MQTTInfo.Topics.inSoilTemperature:
                    self.soilTemperature.text = notification.userInfo?["message"] as! String
                
                case MQTTInfo.Topics.inSoilMoisture:
                    self.soilMoisture.text = notification.userInfo?["message"] as! String
                
                case MQTTInfo.Topics.outManualMode:
                    let manualMode = notification.userInfo?["message"] as! String
                    if manualMode == "1" {
                        self.manualModeSwitcher.setOn(true, animated: true)
                    } else {
                        self.manualModeSwitcher.setOn(false, animated: true)
                    }
                
                case MQTTInfo.Topics.outIsWatering:
                    let manualMode = notification.userInfo?["message"] as! String
                    if manualMode == "1" {
                        self.wateringSwitcher.setOn(true, animated: true)
                    } else {
                        self.wateringSwitcher.setOn(false, animated: true)
                    }
                
                case MQTTInfo.Topics.outWaterLevel:
                    let manualMode = notification.userInfo?["message"] as! String
                    if manualMode == "1" {
                        self.waterIndicator.backgroundColor = green
                    } else {
                        self.waterIndicator.backgroundColor = red
                    }
                
                default :
                    break
            }
        }
    }
    
    
    @IBAction func manualModeSwitcherHandler(_ sender: Any) {
        if manualModeSwitcher.isOn {
            MQTTManager.shared.publishMessage(topic: MQTTInfo.Topics.outManualMode, message: "1")
        } else {
            MQTTManager.shared.publishMessage(topic: MQTTInfo.Topics.inIsLight, message: "0")
        }
    }
    
    @IBAction func wateringSwitcherHandler(_ sender: Any) {
        if manualModeSwitcher.isOn {
            if wateringSwitcher.isOn {
                MQTTManager.shared.publishMessage(topic: MQTTInfo.Topics.outIsWatering, message: "1")
            } else {
                MQTTManager.shared.publishMessage(topic: MQTTInfo.Topics.outIsWatering, message: "0")
            }
        }
    }
}
