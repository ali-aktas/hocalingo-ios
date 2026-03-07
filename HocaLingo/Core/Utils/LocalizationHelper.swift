//
//  LocalizationHelper.swift
//  HocaLingo
//
//  Runtime-safe localization helper.
//  Use L("key") instead of NSLocalizedString for reactive language switching.
//  Location: Core/Utils/LocalizationHelper.swift
//

import Foundation

/// Reads from the correct .lproj bundle at runtime.
/// Unlike NSLocalizedString, this respects runtime language changes immediately.
func L(_ key: String) -> String {
    let code = UserDefaults.standard.string(forKey: "app_language") ?? "en"
    guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
          let bundle = Bundle(path: path) else {
        return NSLocalizedString(key, comment: "")
    }
    return bundle.localizedString(forKey: key, value: key, table: "Localizable")
}

/// Format variant — use for strings with %d / %@ arguments
func L(_ key: String, _ args: CVarArg...) -> String {
    return String(format: L(key), arguments: args)
}
