import Foundation
import UIKit
import Darwin

/// Dev-логи MattGram: пишутся в файл, переживают перезапуск, ловят краши.
/// После вылета при следующем запуске показывается окно с точной ошибкой и кнопкой «Копировать».
public final class MGDevLog {
    public static let shared = MGDevLog()

    private let queue = DispatchQueue(label: "mattgram.devlog")
    private let logPath: String
    private let crashFilePath: String
    private static var crashPathC: UnsafeMutablePointer<CChar>? = nil
    private static var started = false

    private init() {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSTemporaryDirectory()
        let folder = (dir as NSString).appendingPathComponent("MattGramLogs")
        try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
        self.logPath = (folder as NSString).appendingPathComponent("devlog.txt")
        self.crashFilePath = (folder as NSString).appendingPathComponent("last_crash.txt")
    }

    public var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: "mg_devlog_enabled") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "mg_devlog_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "mg_devlog_enabled")
        }
    }

    // MARK: Запись

    public func log(_ message: String, tag: String = "app") {
        guard self.isEnabled else {
            return
        }
        let line = "[\(MGDevLog.timestamp())] [\(tag)] \(message)\n"
        self.queue.async {
            self.append(line)
        }
    }

    public func error(_ message: String, tag: String = "error") {
        let stack = Thread.callStackSymbols.prefix(12).joined(separator: "\n    ")
        self.log("ОШИБКА: \(message)\n    \(stack)", tag: tag)
    }

    private func append(_ line: String) {
        if let data = line.data(using: .utf8) {
            if let handle = FileHandle(forWritingAtPath: self.logPath) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            } else {
                try? data.write(to: URL(fileURLWithPath: self.logPath))
            }
        }
        if let size = (try? FileManager.default.attributesOfItem(atPath: self.logPath))?[.size] as? Int, size > 1_500_000,
           let text = try? String(contentsOfFile: self.logPath, encoding: .utf8) {
            try? String(text.suffix(600_000)).write(toFile: self.logPath, atomically: true, encoding: .utf8)
        }
    }

    public func readLog() -> String {
        return self.queue.sync {
            return (try? String(contentsOfFile: self.logPath, encoding: .utf8)) ?? ""
        }
    }

    public func readLastCrash() -> String? {
        return try? String(contentsOfFile: self.crashFilePath, encoding: .utf8)
    }

    public func clear() {
        self.queue.sync {
            try? FileManager.default.removeItem(atPath: self.logPath)
            try? FileManager.default.removeItem(atPath: self.crashFilePath)
        }
    }

    private static func timestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return f.string(from: Date())
    }

    // MARK: Старт и перехват падений

    public func start() {
        if MGDevLog.started {
            return
        }
        MGDevLog.started = true
        self.log("Запуск MattGram \(MGSettings.shared.versionString) (\(MGSettings.shared.buildNumber)), iOS \(UIDevice.current.systemVersion), \(UIDevice.current.model), bundle \(Bundle.main.bundleIdentifier ?? "?")", tag: "start")

        MGDevLog.crashPathC = strdup(self.crashFilePath)

        NSSetUncaughtExceptionHandler { exception in
            let text = "Необработанное исключение: \(exception.name.rawValue)\n\(exception.reason ?? "")\n\(exception.callStackSymbols.joined(separator: "\n"))\n"
            MGDevLog.writeCrash(text)
        }
        let signals: [Int32] = [SIGABRT, SIGILL, SIGSEGV, SIGBUS, SIGFPE, SIGTRAP]
        for sig in signals {
            signal(sig) { s in
                MGDevLog.writeCrashSignal(s)
            }
        }
    }

    private static func writeCrash(_ text: String) {
        let full = "[\(timestamp())] ВЫЛЕТ\n" + text
        if let p = crashPathC {
            try? full.write(toFile: String(cString: p), atomically: true, encoding: .utf8)
        }
    }

    private static func writeCrashSignal(_ sig: Int32) {
        if let p = crashPathC {
            let fd = open(p, O_WRONLY | O_CREAT | O_TRUNC, 0o644)
            if fd >= 0 {
                var head: StaticString
                switch sig {
                case SIGABRT:
                    head = "ВЫЛЕТ: SIGABRT (abort, assert, необработанная ошибка)\nСтек:\n"
                case SIGILL:
                    head = "ВЫЛЕТ: SIGILL (ошибка Swift runtime)\nСтек:\n"
                case SIGSEGV:
                    head = "ВЫЛЕТ: SIGSEGV (обращение к памяти)\nСтек:\n"
                case SIGBUS:
                    head = "ВЫЛЕТ: SIGBUS\nСтек:\n"
                case SIGFPE:
                    head = "ВЫЛЕТ: SIGFPE\nСтек:\n"
                default:
                    head = "ВЫЛЕТ: SIGTRAP (Swift fatal error, force unwrap, выход за границы)\nСтек:\n"
                }
                _ = write(fd, head.utf8Start, head.utf8CodeUnitCount)
                var frames = [UnsafeMutableRawPointer?](repeating: nil, count: 64)
                let n = backtrace(&frames, 64)
                backtrace_symbols_fd(&frames, n, fd)
                close(fd)
            }
        }
        signal(sig, SIG_DFL)
        raise(sig)
    }

    // MARK: Показ после вылета

    /// Вызвать после запуска интерфейса: если был вылет — покажет окно с ошибкой.
    public func presentPreviousCrashIfNeeded() {
        guard let crash = self.readLastCrash(), !crash.isEmpty else {
            return
        }
        self.append("[\(MGDevLog.timestamp())] [crash] Прошлый запуск завершился вылетом:\n\(crash)\n")
        try? FileManager.default.removeItem(atPath: self.crashFilePath)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            MGDevLog.showText(title: "Прошлый запуск завершился ошибкой", text: crash)
        }
    }

    public static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap { $0.windows }.first(where: { $0.isKeyWindow })
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    public static func showText(title: String, text: String) {
        guard let top = topViewController() else {
            return
        }
        let alert = UIAlertController(title: title, message: String(text.prefix(1500)), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Копировать всё", style: .default, handler: { _ in
            UIPasteboard.general.string = text
        }))
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
        top.present(alert, animated: true)
    }
}
