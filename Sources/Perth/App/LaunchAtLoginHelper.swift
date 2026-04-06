import ServiceManagement

enum LaunchAtLoginHelper {
    static func set(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("[Perth] Launch at login error: \(error)")
            }
        }
    }
}
