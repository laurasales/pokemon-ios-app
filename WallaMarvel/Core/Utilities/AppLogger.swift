//
//  AppLogger.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation
import os

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "WallaMarvel"

    static let network = Logger(subsystem: subsystem, category: "network")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
}
