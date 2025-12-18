//
//  ExternalDevice.swift
//  External Device Manager
//
//  Basit aygıt modeli.
//

import Foundation

/// Menüde gösterilen harici aygıt / volume modeli.
struct ExternalDevice: Identifiable, Equatable {
    let id: URL
    let name: String
    let detail: String?
    let url: URL
}


