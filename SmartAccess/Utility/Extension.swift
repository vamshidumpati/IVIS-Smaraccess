//
//  Extension.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 03/04/25.
//

import Foundation
import UIKit

extension UIViewController {
    func displayAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title ?? "title", message:message ?? "Message", preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style:.default, handler: nil)
        alert.overrideUserInterfaceStyle = .light
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showConfirmationAlert(on controller: UIViewController,
                                     title: String?,
                                     message: String?,
                                     yesTitle: String = "Yes",
                                     noTitle: String = "No",
                                     yesStyle: UIAlertAction.Style = .default,
                                     completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: yesTitle, style: .default) { _ in
            completion(true)
        }
        
        let noAction = UIAlertAction(title: noTitle, style: .destructive) { _ in
            completion(false)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        controller.present(alert, animated: true)
    }
    
    func forceOrientation(to orientation:UIInterfaceOrientation) {
        let value = orientation.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    
    var isOnScreen: Bool{
        return self.isViewLoaded && view.window != nil
    }
}

extension String {
    func toImage() -> UIImage? {
         if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
             return UIImage(data: data)
         }
         return nil
     }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        let passRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passPred = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passPred.evaluate(with: self)
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = self.data(using: .unicode) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.unicode.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func percentEncoded() -> String? {
        self.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
    
    var localize:String{
        return NSLocalizedString(self, comment: "")
    }
}

extension UIView {
    func addBottomBorder(color: UIColor = .lightGray, height: CGFloat = 0.7) {
        let border = CALayer()
        border.name = "BottomBorder"
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
    
    func addShadow(
        color: UIColor = .black,
        opacity: Float = 0.2,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 4
    ) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    /// Call this after layout to apply both
    func applyBottomBorderAndShadow() {
        self.addBottomBorder()
        self.addShadow()
    }
}

extension UINavigationController {
    func popToViewController<T: UIViewController>(ofClass: T.Type, animated: Bool = true) {
        if let vc = viewControllers.first(where: { $0 is T }) {
            popToViewController(vc, animated: animated)
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted.removeFirst()
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIImage {
    func compress(toMaxSizeKB maxSizeKB: Int = 450) -> Data? {
        let maxBytes = maxSizeKB * 1024
        var compression: CGFloat = 1.0
        let minCompression: CGFloat = 0.05
        guard var imageData = self.jpegData(compressionQuality: compression) else { return nil }

        while imageData.count > maxBytes && compression > minCompression {
            compression -= 0.05
            if let data = self.jpegData(compressionQuality: compression) {
                imageData = data
            } else {
                break
            }
        }

        return imageData.count <= maxBytes ? imageData : nil
    }
}

extension UserDefaults {
    enum Keys {
        static let customerId = "customer-id"
        static let customerName = "customer-name"
        static let loginId = "login-id"
        static let tenantId = "tenant-id"
        static let siteId = "site-id"
        static let siteGroupId = "sitegroup-id"
        static let token = "Authorization"
    }
    
    // MARK: - Getters
    
    var customerId: String? {
        string(forKey: Keys.customerId)
    }
    
    var customerName: String? {
        string(forKey: Keys.customerName)
    }
    
    var loginId: String? {
        string(forKey: Keys.loginId)
    }
    
    var tenantId: String? {
        string(forKey: Keys.tenantId)
    }
    
    var siteId: String? {
        string(forKey: Keys.siteId)
    }
    
    var siteGroupId: String? {
        string(forKey: Keys.siteGroupId)
    }
    
    var authToken: String? {
        string(forKey: Keys.token)
    }
    
    // MARK: - Setters
    
    func setCustomerId(_ value: String) {
        set(value, forKey: Keys.customerId)
    }
    
    func setCustomerName(_ value: String) {
        set(value, forKey: Keys.customerName)
    }
    
    // ... add setters for other properties following the same pattern
}
