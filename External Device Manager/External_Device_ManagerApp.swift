//
//  External_Device_ManagerApp.swift
//  External Device Manager
//
//  Created by Onur Akyüz on 18.12.2025.
//

import SwiftUI
import AppKit

/// Ana uygulama giriş noktası.
/// Sadece menü çubuğunda `MenuBarExtra` olarak çalışır; pencere açmaz.
@main
struct External_Device_ManagerApp: App {

    /// macOS tarafında Dock / Cmd+Tab görünürlüğünü kontrol etmek için AppDelegate kullanıyoruz.
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("External Device Manager", systemImage: "externaldrive") {
            ContentView()
        }
        // Sadece menü çubuğunda küçük bir ikon ile çalışması için ideal.
        .menuBarExtraStyle(.window)
    }
}

/// Dock ve Cmd+Tab listesinden saklanmak için `NSApplication` politikasını ayarlar.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // `.accessory` → Dock ve Cmd+Tab'ta görünmez, menü çubuğunda ikon kalır.
        NSApp.setActivationPolicy(.accessory)
    }
}
