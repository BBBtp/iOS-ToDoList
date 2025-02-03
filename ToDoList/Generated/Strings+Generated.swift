// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L {
  /// Add Task
  public static let addTask = L.tr("Localizable", "add_task", fallback: "Add Task")
  /// Localizable.strings
  ///   ToDoList
  /// 
  ///   Created by Богдан Топорин on 29.01.2025.
  public static let tasksTitle = L.tr("Localizable", "tasks_title", fallback: "Tasks")
  public static let edit = L.tr("Localizable", "edit", fallback: "Edit")
  public static let delete = L.tr("Localizable", "delete", fallback: "Delete")
  public static let share = L.tr("Localizable", "share", fallback: "Share")
  public static let back = L.tr("Localizable", "back", fallback: "Back")
  public static let search = L.tr("Localizable", "search", fallback: "Search task")
  public static let empty = L.tr("Localizable", "empty", fallback: "Tasks not found")
  public enum Task {
    /// Plural format key: "%#@VARIABLE@"
    public static func myTasks(_ p1: Int) -> String {
      return L.tr("Localizable", "task.MyTasks", p1, fallback: "Plural format key: \"%#@VARIABLE@\"")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
