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

    @AppStorage("selectedLanguage") private var languageCode: String = AppLanguage.turkish.rawValue // Seçilen dili UserDefaults üzerinden saklayan property.

    private var language: AppLanguage { // Seçilen dili enum tipine çeviren hesaplanmış property.
        AppLanguage(rawValue: languageCode) ?? .turkish // Geçersiz değer olursa Türkçe'ye geri düşülür.
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
                    HStack { // Yatay hizalamalı satır.
                        VStack(alignment: .leading, spacing: 2) { // Aygıt adı ve detayları için dikey stack.
                            Text(device.name) // Aygıt adı.
                                .font(.body) // Varsayılan gövde fontu.
                            if let detail = device.detail, !detail.isEmpty { // Opsiyonel detay varsa.
                                Text(detail) // Örneğin mount path bilgisi.
                                    .font(.caption) // Küçük font.
                                    .foregroundColor(.secondary) // İkincil renk.
                            }
                        }
                        Spacer() // Metin ile buton arasına esnek boşluk.
                        Button(L10n.eject(language)) { // Dil'e göre "Eject" butonu.
                            viewModel.eject(device: device) // İlgili aygıt için eject işlemini tetikler.
                        }
                        .buttonStyle(.bordered) // Kenarlıklı, kompakt buton stili.
                    }
                    .padding(.vertical, 2) // Satırın üst-alt boşluğu.
                }
            }

            // Hata mesajı (varsa).
            if let errorMessage = viewModel.errorMessage { // ViewModel hata mesajı içeriyorsa.
                Text("\(L10n.ejectErrorPrefix(language)): \(errorMessage)") // Dil'e göre prefix + orijinal hata.
                    .font(.caption) // Küçük font.
                    .foregroundColor(.red) // Kırmızı renk ile vurgulama.
                    .padding(.top, 4) // Üstten küçük boşluk.
            }

            Divider() // Liste ile alt kısım (dil/quit satırları) arasında ayırıcı.

            // Dil seçimi satırı.
            HStack { // Yatay hizalı satır.
                Text(L10n.languageRowTitle(language)) // "Dil" / "Language" metni.
                    .font(.subheadline) // Biraz küçük başlık fontu.
                Spacer() // Metin ile picker arasına esnek boşluk.
                Picker("", selection: $languageCode) { // Boş label'lı picker, seçili dili saklar.
                    Text(AppLanguage.turkish.displayName).tag(AppLanguage.turkish.rawValue) // Türkçe seçeneği.
                    Text(AppLanguage.english.displayName).tag(AppLanguage.english.rawValue) // İngilizce seçeneği.
                }
                .pickerStyle(.segmented) // Segment kontrolü (iki butonlu görünüm).
                .frame(width: 150) // Genişliği sınırlı tutulur.
            }

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
}
