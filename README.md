## External Device Manager (macOS Menu Bar App)

Küçük ve modern bir macOS menü çubuğu uygulaması.  
Mac’e bağlı **harici diskleri (USB, harici HDD/SSD)** listeler ve güvenli şekilde **Eject (Çıkar)** işlemi yapar.

### Özellikler

- **Sadece menü çubuğunda çalışır**
  - Dock’ta görünmez
  - Cmd + Tab listesinde görünmez
- **MenuBarExtra** tabanlı SwiftUI arayüz
- Sadece **eject edilebilir** ve **dahili olmayan** volume’lar listelenir
- Her aygıt için:
  - Disk adı
  - İsteğe bağlı detay (mount path)
  - **Eject** butonu
- Eject sonrası liste otomatik yenilenir
- Harici aygıt takıldığında / çıkarıldığında liste **otomatik güncellenir**

### Teknik Detaylar

- **Dil**: Swift
- **UI**: SwiftUI
- **Hedef platform**: macOS 13+
- **Mimari**: Basit MVVM
  - `ExternalDevice` → aygıt modeli
  - `DeviceManager` → harici volume tespiti ve eject işlemleri
  - `DeviceListViewModel` → SwiftUI için durum yönetimi
  - `ContentView` → menü popover arayüzü
  - `External_Device_ManagerApp` + `AppDelegate` → sadece menü çubuğu uygulaması olarak çalışma

### Dosya Yapısı (Önemli Dosyalar)

- `External_Device_ManagerApp.swift`
  - `MenuBarExtra` tanımı
  - Dock/Cmd+Tab görünürlüğünü gizleyen `AppDelegate`
- `ContentView.swift`
  - “Bağlı Harici Aygıtlar” başlığı
  - Aygıt listesi + “Eject” butonları
  - “Harici aygıt bulunamadı” boş durum mesajı
  - “Quit” butonu
- `ExternalDevice.swift`
  - Menüde gösterilen aygıt modeli (id, name, detail, url)
- `DeviceManager.swift`
  - `FileManager.mountedVolumeURLs` + `URLResourceValues` ile harici aygıt tespiti
  - `NSWorkspace.unmountAndEjectDevice` ile güvenli eject
- `DeviceListViewModel.swift`
  - Aygıt listesini ve hata mesajlarını yönetir
  - `NSWorkspace.didMountNotification` ve `didUnmountNotification` dinleyerek gerçek zamanlı güncelleme yapar

### Kurulum ve Çalıştırma

1. Bu projeyi Xcode ile açın:
   - `External Device Manager.xcodeproj`
2. Hedef platformun **macOS 13+** olduğundan emin olun.
3. `External Device Manager` hedefini seçin.
4. `Run` (⌘R) ile çalıştırın.
5. Uygulama çalıştığında:
   - Dock’ta ikon görünmez
   - Menü çubuğunda yeni bir disk ikonu (`externaldrive`) belirir
   - Bu ikona tıklayarak harici aygıt listesini ve “Eject” butonlarını görebilirsiniz.

### Notlar

- Uygulama sadece eject edilebilir ve dahili olmayan diskleri listeler.
- Eject işlemi sırasında hata oluşursa, menü içinde kısa bir kırmızı hata mesajı gösterilir.
- Kod sade, okunabilir ve ek bağımlılık kullanmadan macOS standart framework’lerine dayanır.


