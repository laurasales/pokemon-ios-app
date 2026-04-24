//
//  ErrorAlertModifier.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import SwiftUI

private struct ErrorAlertModifier: ViewModifier {
    let errorMessage: String?
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .alert("Something went wrong", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { onDismiss() } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
    }
}

extension View {
    func errorAlert(message: String?, onDismiss: @escaping () -> Void) -> some View {
        modifier(ErrorAlertModifier(errorMessage: message, onDismiss: onDismiss))
    }
}
