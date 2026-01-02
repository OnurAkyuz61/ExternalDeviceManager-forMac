//
//  LaunchAtLoginManager.swift
//  External Device Manager
//
//  Created by Onur Akyüz on 18.12.2025.
//

import Foundation
import ServiceManagement

/// Uygulamanın otomatik başlatılmasını yöneten sınıf.
final class LaunchAtLoginManager {
    
    /// Uygulamanın Login Items'a eklenip eklenmediğini kontrol eder.
    static var isEnabled: Bool {
        return SMAppService.mainApp.status == .enabled
    }
    
    /// Otomatik başlatmayı etkinleştirir veya devre dışı bırakır.
    static func setEnabled(_ enabled: Bool) -> Bool {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            return true
        } catch {
            print("LaunchAtLogin hatası: \(error.localizedDescription)")
            return false
        }
    }
}

