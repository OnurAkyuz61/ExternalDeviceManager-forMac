//
//  ContentView.swift
//  External Device Manager
//
//  Created by Onur Akyüz on 18.12.2025.
//

import SwiftUI // SwiftUI arayüz bileşenleri için import edilir.

/// Menü çubuğu açıldığında görünen ana içerik. // Status bar menüsündeki ana view.
/// Harici aygıt listesini ve eject işlemlerini gösterir. // Liste + eject butonları burada.
struct ContentView: View { // Ana içerik view'i tanımı.

    @StateObject private var viewModel = DeviceListViewModel() // Harici aygıt listesini yönetecek ViewModel.
    @State private var launchAtLoginEnabled = LaunchAtLoginManager.isEnabled // Otomatik başlatma durumu.

    private var language: AppLanguage { // Sistem diline göre hesaplanan uygulama dili.
        L10n.currentLanguage() // Localization helper üzerinden otomatik seçim yapılır.
    }

    var body: some View { // View'in gövdesi.
        VStack(alignment: .leading, spacing: 8) { // Dikey hizalanmış ana stack.

            // Başlık satırı.
            Text(L10n.devicesTitle(language)) // Dil'e göre başlık metni.
                .font(.headline) // Başlık fontu.

            Divider() // Başlık ile içerik arasında ayırıcı çizgi.

            // Aygıt listesi veya boş durum mesajı.
            if viewModel.devices.isEmpty { // Eğer hiç harici aygıt yoksa.
                Text(L10n.noDevices(language)) // Dil'e göre "Harici aygıt bulunamadı" metni.
                    .foregroundColor(.secondary) // İkincil renk (daha soluk).
                    .padding(.vertical, 4) // Üst-alt küçük padding.
            } else { // En az bir harici aygıt varsa.
                ForEach(viewModel.devices) { device in // Her aygıt için satır oluşturulur.
                    HStack(spacing: 8) { // Yatay hizalamalı satır.
                        // Volume ikonu
                        Image(systemName: deviceIcon(for: device))
                            .foregroundColor(.secondary)
                            .frame(width: 16)
                        
                        VStack(alignment: .leading, spacing: 2) { // Aygıt adı için dikey stack.
                            Text(device.name) // Aygıt adı.
                                .font(.body) // Varsayılan gövde fontu.
                                .lineLimit(1) // Tek satırda göster
                        }
                        
                        Spacer() // Metin ile buton arasına esnek boşluk.
                        
                        Button(L10n.eject(language)) { // Dil'e göre "Eject" butonu.
                            viewModel.eject(device: device) // İlgili aygıt için eject işlemini tetikler.
                        }
                        .buttonStyle(.bordered) // Kenarlıklı, kompakt buton stili.
                        .controlSize(.small) // Daha küçük buton
                    }
                    .padding(.vertical, 4) // Satırın üst-alt boşluğu.
                }
            }

            // Hata mesajı (varsa).
            if let errorMessage = viewModel.errorMessage { // ViewModel hata mesajı içeriyorsa.
                Text("\(L10n.ejectErrorPrefix(language)): \(errorMessage)") // Dil'e göre prefix + orijinal hata.
                    .font(.caption) // Küçük font.
                    .foregroundColor(.red) // Kırmızı renk ile vurgulama.
                    .padding(.top, 4) // Üstten küçük boşluk.
            }

            Divider() // Liste ile ayarlar arasına ayırıcı.

            // Otomatik başlatma toggle butonu.
            Toggle(isOn: $launchAtLoginEnabled) {
                HStack { // İkon + metin hizalaması için yatay stack.
                    Image(systemName: "power") // SF Symbol ikon.
                    Text(L10n.launchAtLogin(language)) // Dil'e göre otomatik başlatma metni.
                }
            }
            .toggleStyle(.checkbox) // Checkbox stili.
            .padding(.top, 4) // Üstten küçük boşluk.
            .onChange(of: launchAtLoginEnabled) { oldValue, newValue in
                _ = LaunchAtLoginManager.setEnabled(newValue)
            }

            Divider() // Otomatik başlatma ile Quit butonu arasına ayırıcı.

            // Quit butonu satırı.
            Button(role: .destructive) { // Destructive rolünde buton (kırmızı vurgu).
                NSApplication.shared.terminate(nil) // Uygulamayı güvenli şekilde sonlandırır.
            } label: { // Buton etiket içeriği.
                HStack { // İkon + metin hizalaması için yatay stack.
                    Image(systemName: "xmark.circle") // SF Symbol ikon.
                    Text(L10n.quit(language)) // Dil'e göre "Quit" metni.
                }
            }
            .buttonStyle(.plain) // Düz buton stili (arka plan yok).
            .padding(.top, 4) // Üstten küçük boşluk.
        }
        .padding(10) // Menünün genel iç padding'i.
        .frame(minWidth: 260) // Minimum genişlik.
        .onAppear { // View ilk göründüğünde.
            viewModel.start() // ViewModel içi setup ve gözlem başlatma.
        }
    }
    
    /// Aygıt tipine göre uygun ikonu döner.
    private func deviceIcon(for device: ExternalDevice) -> String {
        let path = device.url.path
        if path.hasPrefix("/Volumes/") {
            // DMG veya klasör mount'u
            if path.contains(".dmg") || device.name.lowercased().contains("dmg") {
                return "opticaldiscdrive"
            }
            return "externaldrive"
        }
        return "externaldrive"
    }
}
