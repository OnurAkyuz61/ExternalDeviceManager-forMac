//
//  DeviceListViewModel.swift
//  External Device Manager
//
//  SwiftUI tarafı için basit MVVM görünüm modeli.
//

import Foundation
import AppKit
import Combine

/// Harici aygıt listesinin durumunu yöneten ViewModel.
final class DeviceListViewModel: ObservableObject {

    @Published private(set) var devices: [ExternalDevice] = []
    @Published var errorMessage: String?

    private let deviceManager = DeviceManager()
    private var workspaceObservers: [NSObjectProtocol] = []

    deinit {
        stop()
    }

    /// Başlat: cihazları yükler ve mount/unmount bildirimlerini dinler.
    func start() {
        reloadDevices()
        startObservingWorkspaceNotifications()
    }

    /// Temizle: NotificationCenter gözlemcilerini kaldır.
    func stop() {
        let center = NSWorkspace.shared.notificationCenter
        workspaceObservers.forEach { center.removeObserver($0) }
        workspaceObservers.removeAll()
    }

    /// Harici aygıt listesini yeniler.
    func reloadDevices() {
        devices = deviceManager.fetchExternalDevices()
    }

    /// Verilen aygıt için eject işlemini tetikler.
    func eject(device: ExternalDevice) {
        errorMessage = nil
        deviceManager.eject(device: device) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Eject işlemi başarısız: \(error.localizedDescription)"
                } else {
                    self?.errorMessage = nil
                }
                // Eject sonrası listeyi yenile
                self?.reloadDevices()
            }
        }
    }

    // MARK: - Private

    private func startObservingWorkspaceNotifications() {
        let center = NSWorkspace.shared.notificationCenter

        let mountObs = center.addObserver(
            forName: NSWorkspace.didMountNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reloadDevices()
        }

        let unmountObs = center.addObserver(
            forName: NSWorkspace.didUnmountNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reloadDevices()
        }

        workspaceObservers = [mountObs, unmountObs]
    }
}


