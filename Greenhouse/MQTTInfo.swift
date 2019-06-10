import Foundation

struct MQTTInfo {
    
    struct Topics {
        static let all = "greenhouse/#"
        static let outTemperature = "greenhouse/outside/temperature"
        static let outPressure = "greenhouse/outside/pressure"
        static let outManualMode = "greenhouse/water/manualMode"
        static let outWaterLevel = "greenhouse/water/criticalLevel"
        static let outIsWatering = "greenhouse/water/isWatering"
        static let inTemperature = "greenhouse/inside/temperature"
        static let inHumidity = "greenhouse/inside/humidity"
        static let inSoilTemperature = "greenhouse/inside/soil/temperature"
        static let inSoilMoisture = "greenhouse/inside/soil/moisture"
        static let inIsLight = "greenhouse/inside/light"
    }
    
    struct server {
        static let host = "greenhouse.redirectme.net"
        static let port: Int32 = 1883
    }
}

