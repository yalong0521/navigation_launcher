import Flutter
import UIKit
import MapKit

public class NavigationLauncherPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "navigation_launcher", binaryMessenger: registrar.messenger())
        let instance = NavigationLauncherPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getInstalledMaps":
            var list = [String]()
            for app in MapApp.allCases {
                if isInstalled(url: app.url) {
                    list.append(app.value)
                }
            }
            result(list)
        case "launchNavigation":
            let args = call.arguments as! [String: Any]
            let app = MapApp.allCases.first(where: {a in a.value == args["app"] as! String})
            if(app == nil){
                result(FlutterError(code: "unknown_app", message: "不支持的地图", details: nil))
            } else if !isInstalled(url: app!.url) {
                result(FlutterError(code: app!.value, message: "未安装\(app!.desc)地图", details: nil))
            }else{
                let point = args["point"] as! [Double]
                let name = args["name"] as! String
                switch app!{
                case MapApp.gaode:
                    navigateGaode(latitude: point[1], longitude: point[0], destinationName: name)
                case MapApp.baidu:
                    navigateBaidu(latitude: point[1], longitude: point[0], destinationName: name)
                case MapApp.tencent:
                    navigateTencent(latitude: point[1], longitude: point[0], destinationName: name)
                case MapApp.google:
                    navigateGoogle(latitude: point[1], longitude: point[0], destinationName: name)
                case MapApp.apple:
                    navigateApple(latitude: point[1], longitude: point[0], destinationName: name)
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func isInstalled(url: String) -> Bool{
        return UIApplication.shared.canOpenURL(URL(string: url)!)
    }
    
    func navigateApple(latitude: Double, longitude: Double, destinationName: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let destinationPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = destinationName
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem.openMaps(with: [destinationMapItem], launchOptions: launchOptions)
    }
    
    func navigateGoogle(latitude: Double, longitude: Double, destinationName: String) {
        let urlString = "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving"
        UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
    }
    
    func navigateGaode(latitude: Double, longitude: Double, destinationName: String) {
        let urlString = "iosamap://path?dlat=\(latitude)&dlon=\(longitude)&dname=\(destinationName)&dev=1&t=0"
        UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
    }
    
    func navigateBaidu(latitude: Double, longitude: Double, destinationName: String) {
        let urlString = "baidumap://map/direction?destination=\(latitude),\(longitude)&coord_type=wgs84&mode=driving&src=\(String(describing: Bundle.main.bundleIdentifier))"
        UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
    }
    
    func navigateTencent(latitude: Double, longitude: Double, destinationName: String) {
        let urlString = "qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&to=\(destinationName)&tocoord=\(latitude),\(longitude)"
        UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
    }
}

enum MapApp :CaseIterable{
    case gaode
    case baidu
    case tencent
    case google
    case apple

    var value: String {
        switch self {
        case .gaode:
            return "gaode"
        case .baidu:
            return "baidu"
        case .tencent:
            return "tencent"
        case .google:
            return "google"
        case .apple:
            return "apple"
        }
    }

    var url: String {
        switch self {
        case .gaode:
            return "iosamap://"
        case .baidu:
            return "baidumap://"
        case .tencent:
            return "qqmap://"
        case .google:
            return "comgooglemaps://"
        case .apple:
            return "maps://"
        }
    }

    var desc: String {
        switch self {
        case .gaode:
            return "高德"
        case .baidu:
            return "百度"
        case .tencent:
            return "腾讯"
        case .google:
            return "谷歌"
        case .apple:
            return "苹果"
        }
    }
}
