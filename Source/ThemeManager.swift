//
//  ThemeManager.swift
//  SwiftTheme
//
//  Created by Gesen on 16/1/22.
//  Copyright © 2016年 Gesen. All rights reserved.
//

import UIKit

let ThemeUpdateNotification = "ThemeUpdateNotification"

enum ThemePath {
    
    case MainBundle
    case Sandbox(NSURL)
    
    var URL: NSURL? {
        switch self {
        case .MainBundle        : return nil
        case .Sandbox(let path) : return path
        }
    }
    
    func plistPathByName(name: String) -> String? {
        switch self {
        case .MainBundle:        return NSBundle.mainBundle().pathForResource(name, ofType: "plist")
        case .Sandbox(let path): return NSURL(string: name + ".plist", relativeToURL: path)?.path
        }
    }
}

public class ThemeManager: NSObject {
    
    static var animationDuration = 0.3
    
    private(set) static var currentTheme     : NSDictionary?
    private(set) static var currentThemePath : ThemePath?
    
    class func setTheme(plistName: String, path: ThemePath) {
        guard let plistPath = path.plistPathByName(plistName)         else { return }
        guard let plistDict = NSDictionary(contentsOfFile: plistPath) else { return }
        self.setTheme(plistDict, path: path)
    }
    
    class func setTheme(dict: NSDictionary, path: ThemePath) {
        currentTheme = dict
        currentThemePath = path
        setupPromiseKeyPath()
        NSNotificationCenter.defaultCenter().postNotificationName(ThemeUpdateNotification, object: nil)
    }
    
    private class func setupPromiseKeyPath() {
        if let statusBarStyle = stringForKeyPath("UIStatusBarStyle") {
            switch statusBarStyle {
            case "UIStatusBarStyleDefault":
                UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
            case "UIStatusBarStyleLightContent":
                UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
            default: break
            }
        }
    }
    
}

extension ThemeManager {
    
    class func stringForKeyPath(keyPath: String) -> String? {
        guard let string = currentTheme?.valueForKeyPath(keyPath) as? String else {
            print("WARNING: Not found string key path: \(keyPath)")
            return nil
        }
        return string
    }
    
    class func numberForKeyPath(keyPath: String) -> NSNumber? {
        guard let number = currentTheme?.valueForKeyPath(keyPath) as? NSNumber else {
            print("WARNING: Not found number key path: \(keyPath)")
            return nil
        }
        return number
    }
    
    class func colorForKeyPath(keyPath: String) -> UIColor? {
        guard let rgba = stringForKeyPath(keyPath) else { return nil }
        guard let color = try? UIColor(rgba_throws: rgba) else {
            print("WARNING: Not found color rgba: \(rgba)")
            return nil
        }
        return color
    }
    
    class func imageForKeyPath(keyPath: String) -> UIImage? {
        guard let imageName = stringForKeyPath(keyPath) else { return nil }
        if let filePath = currentThemePath?.URL?.URLByAppendingPathComponent(imageName).path {
            guard let image = UIImage(contentsOfFile: filePath) else {
                print("WARNING: Not found image at file path: \(filePath)")
                return nil
            }
            return image
        } else {
            guard let image = UIImage(named: imageName) else {
                print("WARNING: Not found image name at main bundle: \(imageName)")
                return nil
            }
            return image
        }
    }
    
}