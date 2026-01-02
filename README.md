## External Device Manager for macOS

<div align="center">

![App Icon](External%20Device%20Manager/Assets.xcassets/AppIcon.appiconset/ExternalDeviceManager-macOS-Default-256x256@1x.png)

</div>

Modern ve hafif bir **macOS menü çubuğu uygulaması**.  
Mac'inize bağlı **harici diskleri (USB, harici HDD/SSD)** otomatik olarak algılar, listeler ve güvenli şekilde **Eject (Çıkar)** etmenizi sağlar.

Repo: [OnurAkyuz61/ExternalDeviceManager-forMac](https://github.com/OnurAkyuz61/ExternalDeviceManager-forMac)

---

### Uygulama Özeti

- **Tamamen menü çubuğunda yaşar**  
  - Dock'ta görünmez  
  - Cmd + Tab listesinde görünmez  
- macOS stiline uygun, sade ve **developer-friendly** bir arayüz  
- Sistem dili Türkçe ise UI Türkçe, diğer durumlarda İngilizce  
- **Desteklenen aygıt türleri:**
  - Harici diskler (USB, harici HDD/SSD)
  - DMG dosyaları (açıldığında mount edilen disk görüntüleri)
  - Klasör mount'ları (bağlanan klasörler)
- Her aygıt için:
  - Aygıt adı ve ikon
  - **Eject** butonu
- Eject sonrası liste otomatik yenilenir  
- Harici aygıt takıldığında / çıkarıldığında liste **gerçek zamanlı** güncellenir
- **Hızlı açılış** - menü anında açılır, aygıtlar arka planda yüklenir
- **Otomatik başlatma** - Bilgisayar açıldığında veya yeniden başlatıldığında uygulama otomatik olarak başlar (ayarlanabilir)

Uygulama ikonu olarak macOS SF Symbols içindeki `externaldrive` simgesi kullanılır; status bar’da tek bir disk ikonu olarak görünür.

---

### Teknik Stack

- **Dil**: Swift
- **UI**: SwiftUI (`MenuBarExtra`, reactive view yapısı)
- **Hedef platform**: macOS 13+
- **Mimari**: Basit MVVM
  - `ExternalDevice` → aygıt modeli
  - `DeviceManager` → harici volume tespiti ve eject işlemleri
  - `DeviceListViewModel` → SwiftUI için durum yönetimi + NSWorkspace bildirimleri
  - `ContentView` → menü popover UI
  - `External_Device_ManagerApp` + `AppDelegate` → sadece menü çubuğu uygulaması
- **Frameworkler**
  - `SwiftUI` – UI
  - `AppKit` – `NSApplication`, `NSWorkspace`
  - `Combine` – `ObservableObject`, `@Published`
  - `Foundation` – dosya sistemi ve temel tipler
  - `ServiceManagement` – otomatik başlatma (`SMAppService`)

---

### Öne Çıkan Davranışlar

- **Dock ve Cmd+Tab’te gizli çalışma**
  - `NSApp.setActivationPolicy(.accessory)` ile sağlanır
- **Harici aygıt tespiti**
  - `FileManager.mountedVolumeURLs(includingResourceValuesForKeys:options:)`
  - `URLResourceValues.volumeIsEjectable`
  - `URLResourceValues.volumeIsInternal`
  - **Harici diskler**, **DMG mount'ları** ve **klasör mount'ları** listelenir
  - `/Volumes` dizinindeki tüm mount edilmiş volume'lar dahil edilir
- **Güvenli eject**
  - `NSWorkspace.shared.unmountAndEjectDevice(at:)` ile güvenli unmount/eject
  - Arka planda asenkron çalışır, UI donmaz
  - Hata olduğunda menü içinde kısa kırmızı hata mesajı
- **Performans optimizasyonu**
  - Aygıt listesi arka planda asenkron yüklenir
  - Menü açılırken donma olmaz, anında açılır
- **Gerçek zamanlı güncelleme**
  - `NSWorkspace.didMountNotification`
  - `NSWorkspace.didUnmountNotification`
  - Her mount/unmount sonrasında liste otomatik yenilenir
- **Otomatik dil seçimi**
  - `Locale.preferredLanguages` üzerinden sistem diline bakılır  
  - `tr` → Türkçe, diğer tüm diller → İngilizce
- **Otomatik başlatma desteği**
  - `SMAppService.mainApp` API'si ile Login Items yönetimi
  - Kullanıcı menüden toggle ile açıp kapatabilir
  - Bilgisayar açıldığında veya yeniden başlatıldığında uygulama otomatik başlar

---

### Önemli Dosyalar

- `External_Device_ManagerApp.swift`  
  - `@main` App giriş noktası  
  - `MenuBarExtra` tanımı  
  - Dock / Cmd+Tab gizleme (`AppDelegate` + `NSApp.setActivationPolicy(.accessory)`)

- `ContentView.swift`  
  - Menü popover arayüzü  
  - "Bağlı Harici Aygıtlar" / "Connected External Devices" başlığı  
  - Harici aygıt listesi (ikon + isim) + her satırda **Eject** butonu  
  - Boş durumda "Harici aygıt bulunamadı" / "No external devices found" mesajı  
  - Dil otomatik seçimi (sistem diline göre)  
  - **Otomatik başlatma** toggle butonu (bilgisayar açıldığında otomatik başlat)
  - En altta **Quit** butonu

- `ExternalDevice.swift`  
  - Menüde gösterilen aygıt modeli (id, name, detail, url)

- `DeviceManager.swift`  
  - Dosya sistemi üzerinden harici volume tespiti  
  - Klasör mount'ları ve DMG'leri de algılar
  - Arka planda güvenli eject (`unmountAndEjectDevice`)
  - Swift 6 strict concurrency uyumlu (`nonisolated` fonksiyonlar)

- `DeviceListViewModel.swift`  
  - `ObservableObject` tabanlı ViewModel  
  - Aygıt listesini ve hata mesajlarını yönetir  
  - Mount / unmount bildirimlerini dinler, listeyi yeniler
  - Asenkron aygıt yükleme ile performans optimizasyonu

- `Localization.swift`  
  - Basit `AppLanguage` enum'u (`tr` / `en`)  
  - Tüm kullanıcıya dönük metinler için `L10n` helper'ı  
  - `currentLanguage()` ile sistem diline göre otomatik seçim

- `LaunchAtLoginManager.swift`  
  - Otomatik başlatma yönetimi  
  - macOS 13+ için `SMAppService` API'si kullanır  
  - Login Items'a ekleme/çıkarma işlemlerini yönetir

---

### Geliştirici İçin Hızlı Başlangıç

1. Repoyu klonla:
   ```bash
   git clone https://github.com/OnurAkyuz61/ExternalDeviceManager-forMac.git
   cd ExternalDeviceManager-forMac
   ```
2. Xcode ile aç:
   - `External Device Manager.xcodeproj`
3. Hedef platformun **macOS 26+** olduğundan emin ol.
4. `External Device Manager` target’ını seç.
5. Çalıştır (`⌘R`).
6. Uygulama çalıştığında:
   - Dock’ta ikon görünmez  
   - Menü çubuğunda `externaldrive` ikonunu görürsün  
   - İkona tıkladığında harici disk listesini ve **Eject** butonlarını görürsün.

---

### Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır.  
Detaylar için `LICENSE` dosyasına bakabilirsiniz.



