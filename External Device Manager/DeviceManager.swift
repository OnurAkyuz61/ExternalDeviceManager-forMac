//
//  DeviceManager.swift
//  External Device Manager
//
//  Harici aygıtları listelemek ve eject etmek için sorumlu sınıf.
//

import Foundation
import AppKit

/// Harici volume / aygıt yönetiminden sorumlu yardımcı sınıf.
/// - Sadece eject edilebilir ve dahili olmayan volume'ları döner.
final class DeviceManager {

    /// Mevcut harici aygıtları senkron olarak listeler.
    func fetchExternalDevices() -> [ExternalDevice] {
        let resourceKeys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeIsEjectableKey,
            .volumeIsInternalKey,
            .volumeLocalizedNameKey
        ]

        guard let urls = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: resourceKeys,
                                                               options: [.skipHiddenVolumes]) else {
            return []
        }

        var result: [ExternalDevice] = []

        for url in urls {
            do {
                let values = try url.resourceValues(forKeys: Set(resourceKeys))

                let isEjectable = values.volumeIsEjectable ?? false
                let isInternal = values.volumeIsInternal ?? false

                // Sadece eject edilebilir ve dahili olmayan volume'lar
                guard isEjectable, !isInternal else { continue }

                let displayName = values.volumeLocalizedName ??
                                  values.volumeName ??
                                  url.lastPathComponent

                let detail = url.path

                let device = ExternalDevice(
                    id: url,
                    name: displayName,
                    detail: detail,
                    url: url
                )
                result.append(device)
            } catch {
                // Bu volume okunamazsa atla, uygulamanın tamamını etkilemesin.
                continue
            }
        }

        // İsme göre sıralama
        return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    /// Verilen aygıtı güvenli şekilde eject etmeye çalışır.
    /// macOS 13+ için async/await tabanlı `unmountAndEjectDevice` kullanır.
    /// - Parameter completion: Başarı durumunda `nil`, hata durumunda `Error` döner.
    func eject(device: ExternalDevice, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await NSWorkspace.shared.unmountAndEjectDevice(at: device.url)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}


