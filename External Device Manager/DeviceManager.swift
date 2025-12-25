//
//  DeviceManager.swift
//  External Device Manager
//
//  Harici aygıtları listelemek ve eject etmek için sorumlu sınıf.
//

import Foundation
import AppKit

/// Harici volume / aygıt yönetiminden sorumlu yardımcı sınıf.
/// - Harici aygıtları, DMG mount'larını ve klasör mount'larını listeler.
final class DeviceManager {

    /// Mevcut harici aygıtları senkron olarak listeler.
    nonisolated func fetchExternalDevices() -> [ExternalDevice] {
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

                let isInternal = values.volumeIsInternal ?? false
                let isEjectable = values.volumeIsEjectable ?? false

                // Root volume'u (/) hariç tut
                if url.path == "/" {
                    continue
                }

                // /Volumes dizinindeki tüm volume'ları dahil et (klasör mount'ları ve DMG'ler)
                let isInVolumes = url.path.hasPrefix("/Volumes/")
                
                // Dahili olmayan volume'ları göster
                // Veya /Volumes dizinindeki volume'ları göster (klasör mount'ları için)
                // Veya ejectable olan volume'ları göster (DMG'ler için)
                if isInternal && !isEjectable && !isInVolumes {
                    continue
                }

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
    /// - Parameter completion: Başarı durumunda `nil`, hata durumunda `Error` döner.
    func eject(device: ExternalDevice, completion: @escaping (Error?) -> Void) {
        Task.detached {
            do {
                try NSWorkspace.shared.unmountAndEjectDevice(at: device.url)
                await MainActor.run {
                    completion(nil)
                }
            } catch {
                await MainActor.run {
                    completion(error)
                }
            }
        }
    }
}


