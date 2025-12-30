import Cocoa
import Carbon

// MARK: - Localization
struct L10n {
    static let lang = Locale.current.language.languageCode?.identifier ?? "en"
    
    static var lockKeyboard: String {
        switch lang {
        case "ko": return "🔒 키보드 잠금 (⌘L)"
        case "ja": return "🔒 キーボードをロック (⌘L)"
        case "zh": return "🔒 锁定键盘 (⌘L)"
        case "es": return "🔒 Bloquear teclado (⌘L)"
        case "fr": return "🔒 Verrouiller le clavier (⌘L)"
        case "de": return "🔒 Tastatur sperren (⌘L)"
        case "pt": return "🔒 Bloquear teclado (⌘L)"
        case "ru": return "🔒 Заблокировать клавиатуру (⌘L)"
        default: return "🔒 Lock Keyboard (⌘L)"
        }
    }
    
    static var unlockKeyboard: String {
        switch lang {
        case "ko": return "🔓 키보드 잠금 해제"
        case "ja": return "🔓 キーボードのロックを解除"
        case "zh": return "🔓 解锁键盘"
        case "es": return "🔓 Desbloquear teclado"
        case "fr": return "🔓 Déverrouiller le clavier"
        case "de": return "🔓 Tastatur entsperren"
        case "pt": return "🔓 Desbloquear teclado"
        case "ru": return "🔓 Разблокировать клавиатуру"
        default: return "🔓 Unlock Keyboard"
        }
    }
    
    static var quit: String {
        switch lang {
        case "ko": return "종료"
        case "ja": return "終了"
        case "zh": return "退出"
        case "es": return "Salir"
        case "fr": return "Quitter"
        case "de": return "Beenden"
        case "pt": return "Sair"
        case "ru": return "Выход"
        default: return "Quit"
        }
    }
    
    static var permissionRequired: String {
        switch lang {
        case "ko": return "권한 필요"
        case "ja": return "権限が必要です"
        case "zh": return "需要权限"
        case "es": return "Permiso requerido"
        case "fr": return "Autorisation requise"
        case "de": return "Berechtigung erforderlich"
        case "pt": return "Permissão necessária"
        case "ru": return "Требуется разрешение"
        default: return "Permission Required"
        }
    }
    
    static var permissionMessage: String {
        switch lang {
        case "ko": return "시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용에서 이 앱을 허용해주세요."
        case "ja": return "システム設定 → プライバシーとセキュリティ → アクセシビリティでこのアプリを許可してください。"
        case "zh": return "请在系统设置 → 隐私与安全 → 辅助功能中启用此应用。"
        case "es": return "Habilite esta app en Configuración del Sistema → Privacidad y Seguridad → Accesibilidad."
        case "fr": return "Activez cette app dans Réglages Système → Confidentialité et sécurité → Accessibilité."
        case "de": return "Aktivieren Sie diese App in Systemeinstellungen → Datenschutz & Sicherheit → Bedienungshilfen."
        case "pt": return "Ative este app em Configurações do Sistema → Privacidade e Segurança → Acessibilidade."
        case "ru": return "Включите это приложение в Системные настройки → Конфиденциальность и безопасность → Универсальный доступ."
        default: return "Please enable this app in System Settings → Privacy & Security → Accessibility."
        }
    }
    
    static var openSettings: String {
        switch lang {
        case "ko": return "설정 열기"
        case "ja": return "設定を開く"
        case "zh": return "打开设置"
        case "es": return "Abrir Configuración"
        case "fr": return "Ouvrir les Réglages"
        case "de": return "Einstellungen öffnen"
        case "pt": return "Abrir Configurações"
        case "ru": return "Открыть настройки"
        default: return "Open Settings"
        }
    }
    
    static var cancel: String {
        switch lang {
        case "ko": return "취소"
        case "ja": return "キャンセル"
        case "zh": return "取消"
        case "es": return "Cancelar"
        case "fr": return "Annuler"
        case "de": return "Abbrechen"
        case "pt": return "Cancelar"
        case "ru": return "Отмена"
        default: return "Cancel"
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var isLocked = false
    var eventTap: CFMachPort?
    var runLoopSource: CFRunLoopSource?
    var hotKeyRef: EventHotKeyRef?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupHotKey()
    }
    
    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem.button else { return }
        button.title = "⌨️"
        
        updateMenu()
    }
    
    func updateMenu() {
        let menu = NSMenu()
        
        if isLocked {
            let unlockItem = NSMenuItem(title: L10n.unlockKeyboard, action: #selector(unlockKeyboard), keyEquivalent: "")
            unlockItem.target = self
            menu.addItem(unlockItem)
            statusItem.button?.title = "🔒"
        } else {
            let lockItem = NSMenuItem(title: L10n.lockKeyboard, action: #selector(lockKeyboard), keyEquivalent: "")
            lockItem.target = self
            menu.addItem(lockItem)
            statusItem.button?.title = "⌨️"
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: L10n.quit, action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    func setupHotKey() {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4B4C434B) // "KLCK"
        hotKeyID.id = 1
        
        let status = RegisterEventHotKey(
            UInt32(37),
            UInt32(cmdKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Hotkey registration failed: \(status)")
            return
        }
        
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userData!).takeUnretainedValue()
                if !appDelegate.isLocked {
                    appDelegate.lockKeyboard()
                }
                return noErr
            },
            1,
            &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
        
        print("Hotkey registered: ⌘L (lock only)")
    }
    
    @objc func lockKeyboard() {
        if isLocked { return }
        
        let eventMask = (1 << CGEventType.keyDown.rawValue) | 
                        (1 << CGEventType.keyUp.rawValue) | 
                        (1 << CGEventType.flagsChanged.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                return nil
            },
            userInfo: nil
        ) else {
            showPermissionAlert()
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        isLocked = true
        updateMenu()
        print("🔒 Keyboard locked")
    }
    
    @objc func unlockKeyboard() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
        
        isLocked = false
        updateMenu()
        print("🔓 Keyboard unlocked")
    }
    
    func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = L10n.permissionRequired
        alert.informativeText = L10n.permissionMessage
        alert.alertStyle = .warning
        alert.addButton(withTitle: L10n.openSettings)
        alert.addButton(withTitle: L10n.cancel)
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    @objc func quitApp() {
        if isLocked { unlockKeyboard() }
        if let hotKey = hotKeyRef {
            UnregisterEventHotKey(hotKey)
        }
        NSApplication.shared.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
