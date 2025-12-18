//
//  Localization.swift
//  External Device Manager
//
//  Basit, kod içi localization / dil yönetimi.
//

import Foundation // Temel Swift tipleri için Foundation import edilir.

/// Uygulamanın desteklediği diller. // Dil seçeneklerini temsil eden enum.
enum AppLanguage: String, CaseIterable, Identifiable { // String raw value ve Identifiable protokolleri ile enum.
    case turkish = "tr" // Türkçe dili için case.
    case english = "en" // İngilizce dili için case.

    var id: String { rawValue } // Identifiable gereği benzersiz id olarak rawValue kullanılır.

    /// Kullanıcıya gösterilecek dil adı. // UI'da görünen dil etiketi.
    var displayName: String { // Dil adını döndüren hesaplanmış property.
        switch self { // Dil türüne göre ayrım yapılır.
        case .turkish: return "Türkçe" // Türkçe metin.
        case .english: return "English" // İngilizce metin.
        }
    }
}

/// Tüm kullanıcıya dönük metinler için basit bir helper yapı. // UI metinlerini merkezi yönetmek için struct.
struct L10n { // Localization kısaltması için L10n ismi kullanıldı.

    /// Sistem diline göre uygulama dilini hesaplar. // macOS'in tercih ettiği dile uygun AppLanguage döner.
    static func currentLanguage() -> AppLanguage { // Statik yardımcı fonksiyon.
        let preferred = Locale.preferredLanguages.first ?? "tr" // Kullanıcının tercih ettiği ilk dil, yoksa "tr".
        if preferred.hasPrefix("tr") { // Dil kodu "tr" ile başlıyorsa.
            return .turkish // Türkçe olarak ayarla.
        } else { // Diğer tüm diller için varsayılan.
            return .english // İngilizce kullan.
        }
    }

    /// Başlık: "Bağlı Harici Aygıtlar" / "Connected External Devices" // Menü başlığı metni.
    static func devicesTitle(_ lang: AppLanguage) -> String { // Dil parametresine göre başlık döndürür.
        switch lang { // Dil seçeneğine göre ayrım yapılır.
        case .turkish: return "Bağlı Harici Aygıtlar" // Türkçe başlık.
        case .english: return "Connected External Devices" // İngilizce başlık.
        }
    }

    /// Boş liste mesajı. // Harici aygıt yokken gösterilen mesaj.
    static func noDevices(_ lang: AppLanguage) -> String { // Dil parametresine göre metin döndürür.
        switch lang { // Dil seçimine göre.
        case .turkish: return "Harici aygıt bulunamadı" // Türkçe mesaj.
        case .english: return "No external devices found" // İngilizce mesaj.
        }
    }

    /// Eject buton etiketi. // Eject butonundaki kısa metin.
    static func eject(_ lang: AppLanguage) -> String { // Dil seçimine göre metin.
        switch lang { // Dil ayrımı.
        case .turkish: return "Eject" // Türkçe için yine "Eject" kullanılıyor.
        case .english: return "Eject" // İngilizce metin.
        }
    }

    /// Quit buton etiketi. // Quit butonunda görülen metin.
    static func quit(_ lang: AppLanguage) -> String { // Dil parametresi alan fonksiyon.
        switch lang { // Dil ayrımı.
        case .turkish: return "Quit" // Türkçe için kısa ve yaygın "Quit" kullanıldı.
        case .english: return "Quit" // İngilizce metin.
        }
    }

    /// Eject hata mesajı prefix'i. // Hata açıklaması öncesi sabit kısım.
    static func ejectErrorPrefix(_ lang: AppLanguage) -> String { // Metin prefix'i.
        switch lang { // Dil ayrımı.
        case .turkish: return "Eject işlemi başarısız" // Türkçe hata prefix'i.
        case .english: return "Eject failed" // İngilizce hata prefix'i.
        }
    }

    /// Dil ayarı satırı başlığı. // UI'da dil satırı metni.
    static func languageRowTitle(_ lang: AppLanguage) -> String { // Dil satırı başlığı.
        switch lang { // Dil ayrımı.
        case .turkish: return "Dil" // Türkçe satır başlığı.
        case .english: return "Language" // İngilizce satır başlığı.
        }
    }
}


