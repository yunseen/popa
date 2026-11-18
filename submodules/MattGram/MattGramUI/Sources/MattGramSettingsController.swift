import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext
import AppBundle
import MGSettings

// MARK: - Нажатия

private enum MGTap: Equatable {
    case none
    case screen(String)
    case picker(String)
    case search
}

// MARK: - Аргументы

private final class MGArguments {
    let toggle: (String, Bool) -> Void
    let slider: (String, Int, Int, Int, CGFloat) -> Void
    let color: (String) -> Void
    let tap: (MGTap) -> Void
    let action: (String) -> Void
    let searchText: (String) -> Void

    init(toggle: @escaping (String, Bool) -> Void, slider: @escaping (String, Int, Int, Int, CGFloat) -> Void, color: @escaping (String) -> Void, tap: @escaping (MGTap) -> Void, action: @escaping (String) -> Void, searchText: @escaping (String) -> Void) {
        self.toggle = toggle
        self.slider = slider
        self.color = color
        self.tap = tap
        self.action = action
        self.searchText = searchText
    }
}

// MARK: - Строки списка

private enum MGEntry: ItemListNodeEntry {
    case brand(stable: Int32, version: String)
    case header(stable: Int32, section: Int32, text: String)
    case toggle(stable: Int32, section: Int32, id: String, title: String, value: Bool)
    case slider(stable: Int32, section: Int32, id: String, title: String, value: Int, min: Int, max: Int, step: Int, unit: String)
    case color(stable: Int32, section: Int32, id: String, title: String, hex: String)
    case disclosure(stable: Int32, section: Int32, title: String, subtitle: String, value: String, icon: String, tap: MGTap)
    case action(stable: Int32, section: Int32, title: String, danger: Bool, act: String)
    case footer(stable: Int32, section: Int32, text: String)
    case input(stable: Int32, section: Int32, text: String)

    var stableId: Int32 {
        switch self {
        case let .brand(stable, _):
            return stable
        case let .header(stable, _, _):
            return stable
        case let .toggle(stable, _, _, _, _):
            return stable
        case let .slider(stable, _, _, _, _, _, _, _, _):
            return stable
        case let .color(stable, _, _, _, _):
            return stable
        case let .disclosure(stable, _, _, _, _, _, _):
            return stable
        case let .action(stable, _, _, _, _):
            return stable
        case let .footer(stable, _, _):
            return stable
        case let .input(stable, _, _):
            return stable
        }
    }

    var section: ItemListSectionId {
        switch self {
        case .brand:
            return 0
        case let .header(_, section, _):
            return section
        case let .toggle(_, section, _, _, _):
            return section
        case let .slider(_, section, _, _, _, _, _, _, _):
            return section
        case let .color(_, section, _, _, _):
            return section
        case let .disclosure(_, section, _, _, _, _, _):
            return section
        case let .action(_, section, _, _, _):
            return section
        case let .footer(_, section, _):
            return section
        case let .input(_, section, _):
            return section
        }
    }

    static func <(lhs: MGEntry, rhs: MGEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! MGArguments
        switch self {
        case let .brand(_, version):
            return MGBrandItem(theme: presentationData.theme, version: version, sectionId: self.section)
        case let .header(_, _, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .toggle(_, _, id, title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, maximumNumberOfLines: 4, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggle(id, value)
            })
        case let .slider(_, _, id, title, value, minValue, maxValue, step, unit):
            let span = CGFloat(max(1, maxValue - minValue))
            let fraction = CGFloat(value - minValue) / span
            return MGSliderItem(theme: presentationData.theme, title: title, valueText: "\(value)\(unit)", fraction: fraction, sectionId: self.section, updated: { fraction in
                arguments.slider(id, minValue, maxValue, step, fraction)
            })
        case let .color(_, _, id, title, hex):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: title, label: "", labelStyle: .color(mgColor(hex)), sectionId: self.section, style: .blocks, disclosureStyle: .none, action: {
                arguments.color(id)
            })
        case let .disclosure(_, _, title, subtitle, value, icon, tap):
            let image: UIImage? = icon.isEmpty ? nil : mgIcon(icon, color: presentationData.theme.list.itemPrimaryTextColor)
            if subtitle.isEmpty {
                return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: image, title: title, label: value, sectionId: self.section, style: .blocks, action: {
                    arguments.tap(tap)
                })
            } else {
                return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: image, title: title, label: subtitle, labelStyle: .detailText, sectionId: self.section, style: .blocks, action: {
                    arguments.tap(tap)
                })
            }
        case let .action(_, _, title, danger, act):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: title, kind: danger ? .destructive : .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.action(act)
            })
        case let .footer(_, _, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .input(_, _, text):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: ""), text: text, placeholder: "Найти опцию MattGram", clearType: .always, sectionId: self.section, textUpdated: { text in
                arguments.searchText(text)
            }, action: {
            })
        }
    }
}

// MARK: - Помощники

private func mgColor(_ hex: String) -> UIColor {
    var string = hex
    if string.hasPrefix("#") {
        string.removeFirst()
    }
    var value: UInt64 = 0
    Scanner(string: string).scanHexInt64(&value)
    return UIColor(red: CGFloat((value >> 16) & 255) / 255.0, green: CGFloat((value >> 8) & 255) / 255.0, blue: CGFloat(value & 255) / 255.0, alpha: 1.0)
}

private func mgHex(_ color: UIColor) -> String {
    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    var a: CGFloat = 0.0
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    return String(format: "#%02X%02X%02X", Int(round(r * 255.0)), Int(round(g * 255.0)), Int(round(b * 255.0)))
}

private func mgIcon(_ name: String, color: UIColor) -> UIImage? {
    let configuration = UIImage.SymbolConfiguration(pointSize: 21.0, weight: .regular)
    guard let base = UIImage(systemName: name, withConfiguration: configuration)?.withTintColor(color, renderingMode: .alwaysOriginal) else {
        return nil
    }
    let size = CGSize(width: 30.0, height: 30.0)
    return UIGraphicsImageRenderer(size: size).image { _ in
        base.draw(in: CGRect(x: (size.width - base.size.width) / 2.0, y: (size.height - base.size.height) / 2.0, width: base.size.width, height: base.size.height))
    }
}

private func mgAlert(_ title: String, _ text: String) {
    guard let top = MGDevLog.topViewController() else {
        return
    }
    let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
    top.present(alert, animated: true)
}

private func mgShare(text: String, fileName: String) {
    guard let top = MGDevLog.topViewController() else {
        return
    }
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    var items: [Any] = [text]
    if (try? text.write(to: url, atomically: true, encoding: .utf8)) != nil {
        items = [url]
    }
    let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
    controller.popoverPresentationController?.sourceView = top.view
    controller.popoverPresentationController?.sourceRect = CGRect(x: top.view.bounds.midX, y: top.view.bounds.midY, width: 1, height: 1)
    top.present(controller, animated: true)
}

private final class MGColorDelegate: NSObject, UIColorPickerViewControllerDelegate {
    static var current: MGColorDelegate?

    let changed: (UIColor) -> Void

    init(changed: @escaping (UIColor) -> Void) {
        self.changed = changed
        super.init()
    }

    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        self.changed(color)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        MGColorDelegate.current = nil
    }
}

// MARK: - Данные схемы

private let mgBandNames: [String] = ["32 Гц", "64 Гц", "125 Гц", "250 Гц", "500 Гц", "1 кГц", "2 кГц", "4 кГц", "8 кГц", "16 кГц"]

private let mgEqPresets: [(String, [Int])] = [
    ("Нейтральный", [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
    ("Усиление баса", [7, 6, 4, 2, 0, 0, 0, 0, 0, 0]),
    ("Чистые высокие", [0, 0, 0, 0, 0, 1, 3, 5, 6, 6]),
    ("Рок", [5, 4, 2, -1, -2, 0, 3, 4, 5, 5]),
    ("Джаз", [3, 2, 1, 2, -2, -2, 0, 1, 2, 3]),
    ("Классика", [4, 3, 2, 1, -1, -1, 0, 2, 3, 4])
]

private func mgExtraScreens() -> [MGScreen] {
    var eqRows: [MGRow] = []
    eqRows.append(.header("ПОЛОСЫ"))
    for (index, name) in mgBandNames.enumerated() {
        eqRows.append(.slider(id: "eq\(index)", title: name, min: -12, max: 12, step: 1, def: 0, unit: " дБ"))
    }
    eqRows.append(.header("ПРЕСЕТЫ"))
    eqRows.append(.picker(id: "eqPre", title: "Пресет", options: mgEqPresets.map { $0.0 }, def: "Нейтральный", foot: ""))
    eqRows.append(.action(title: "Сбросить", act: "eqReset", foot: "", danger: false))

    var fontRows: [MGRow] = []
    fontRows.append(.picker(id: "fontSel", title: "Шрифт", options: ["Системный шрифт", "Unbounded", "Inter"], def: "Системный шрифт", foot: ""))
    fontRows.append(.action(title: "Добавить шрифт…", act: "addFont", foot: "Файл TTF или OTF из приложения «Файлы». После выбора откроется экран предпросмотра «TYPE LAB» с кнопкой «Установить и применить».", danger: false))

    var logRows: [MGRow] = []
    logRows.append(.header("ЛОГИ"))
    logRows.append(.toggle(id: "__devlog", title: "Записывать логи", foot: "Логи и ошибки сохраняются в файл и остаются после перезапуска. После вылета при следующем запуске покажется точная ошибка.", def: true))
    logRows.append(.action(title: "Копировать весь лог", act: "dlCopy", foot: "", danger: false))
    logRows.append(.action(title: "Поделиться логом (файл)", act: "dlShare", foot: "", danger: false))
    logRows.append(.action(title: "Записать тестовую ошибку", act: "dlTest", foot: "", danger: false))
    logRows.append(.action(title: "Очистить лог", act: "dlClear", foot: "", danger: true))

    return [
        MGScreen(id: "eq", title: "Эквалайзер", rows: eqRows),
        MGScreen(id: "fonts", title: "Шрифты", rows: fontRows),
        MGScreen(id: "devlog", title: "Dev-логи", rows: logRows)
    ]
}

private func mgAllScreens() -> [MGScreen] {
    return mgScreens + mgExtraScreens()
}

private func mgFindScreen(_ id: String) -> MGScreen? {
    for screen in mgAllScreens() {
        if screen.id == id {
            return screen
        }
    }
    return nil
}

private func mgFindPicker(_ id: String) -> (String, [String], String)? {
    for screen in mgAllScreens() {
        for row in screen.rows {
            if case let .picker(pickerId, title, options, def, _) = row, pickerId == id {
                return (title, options, def)
            }
        }
    }
    return nil
}

private func mgScreenRows(_ id: String) -> [MGRow] {
    guard let screen = mgFindScreen(id) else {
        return []
    }
    var rows = screen.rows
    if id == "misc" {
        rows.append(.link(title: "Dev-логи", screen: "devlog", foot: "Записи ошибок и вылетов для разработки."))
    }
    return rows
}

private func mgScreenTitle(_ id: String) -> String {
    return mgFindScreen(id)?.title ?? "MattGram"
}

private var mgVersionString: String {
    return "\(MGSettings.shared.versionString) (\(MGSettings.shared.buildNumber))"
}

// MARK: - Построение строк из схемы (одна карточка на группу, пояснение под карточкой)

private func mgEntries(forRows rows: [MGRow]) -> [MGEntry] {
    var entries: [MGEntry] = []
    var stable: Int32 = 100
    var section: Int32 = 1
    var pendingHeader: String? = nil
    var run: [MGRow] = []

    func nextStable() -> Int32 {
        stable += 1
        return stable
    }

    func entry(for row: MGRow, section: Int32) -> MGEntry? {
        switch row {
        case let .toggle(id, title, _, def):
            let value: Bool
            if id == "__devlog" {
                value = MGDevLog.shared.isEnabled
            } else {
                value = MGSettings.shared.bool(named: id, default: def)
            }
            return .toggle(stable: nextStable(), section: section, id: id, title: title, value: value)
        case let .slider(id, title, minValue, maxValue, step, def, unit):
            let value = MGSettings.shared.int(named: id, default: def)
            return .slider(stable: nextStable(), section: section, id: id, title: title, value: value, min: minValue, max: maxValue, step: step, unit: unit)
        case let .color(id, title, def):
            return .color(stable: nextStable(), section: section, id: id, title: title, hex: MGSettings.shared.string(named: id, default: def))
        case let .link(title, screen, _):
            return .disclosure(stable: nextStable(), section: section, title: title, subtitle: "", value: "", icon: "", tap: .screen(screen))
        case let .picker(id, title, _, def, _):
            return .disclosure(stable: nextStable(), section: section, title: title, subtitle: "", value: MGSettings.shared.string(named: id, default: def), icon: "", tap: .picker(id))
        case let .action(title, act, _, danger):
            return .action(stable: nextStable(), section: section, title: title, danger: danger, act: act)
        default:
            return nil
        }
    }

    func rowFoot(_ row: MGRow) -> String {
        switch row {
        case let .toggle(_, _, foot, _):
            return foot
        case let .link(_, _, foot):
            return foot
        case let .picker(_, _, _, _, foot):
            return foot
        case let .action(_, _, foot, _):
            return foot
        default:
            return ""
        }
    }

    func flushRun() {
        if run.isEmpty {
            return
        }
        if let header = pendingHeader {
            entries.append(.header(stable: nextStable(), section: section, text: header))
            pendingHeader = nil
        }
        for row in run {
            if let value = entry(for: row, section: section) {
                entries.append(value)
            }
        }
        run = []
        section += 1
    }

    for row in rows {
        switch row {
        case let .header(text):
            flushRun()
            pendingHeader = text
        case .preview:
            flushRun()
        case let .note(text):
            flushRun()
            entries.append(.footer(stable: nextStable(), section: section, text: text))
            section += 1
        default:
            let foot = rowFoot(row)
            if foot.isEmpty {
                run.append(row)
            } else {
                flushRun()
                if let header = pendingHeader {
                    entries.append(.header(stable: nextStable(), section: section, text: header))
                    pendingHeader = nil
                }
                if let value = entry(for: row, section: section) {
                    entries.append(value)
                }
                entries.append(.footer(stable: nextStable(), section: section, text: foot))
                section += 1
            }
        }
    }
    flushRun()
    return entries
}

// MARK: - Главный экран

private func mgHubEntries() -> [MGEntry] {
    var entries: [MGEntry] = []
    entries.append(.brand(stable: 0, version: mgVersionString))
    var stable: Int32 = 10
    for row in mgHubRows {
        stable += 1
        entries.append(.disclosure(stable: stable, section: 1, title: row.title, subtitle: row.sub, value: "", icon: row.icon, tap: row.isSearch ? .search : .screen(row.id)))
    }
    return entries
}

// MARK: - Поиск

private func mgSearchEntries(text: String) -> [MGEntry] {
    var entries: [MGEntry] = []
    entries.append(.input(stable: 0, section: 1, text: text))
    let query = text.trimmingCharacters(in: .whitespaces).lowercased()
    if query.isEmpty {
        entries.append(.footer(stable: 1, section: 2, text: "Введите название опции."))
        return entries
    }
    var titleHits: [(String, String, String)] = []
    var textHits: [(String, String, String)] = []
    for screen in mgScreens {
        if screen.title.lowercased().contains(query) {
            titleHits.append((screen.title, "Раздел", screen.id))
        }
        for row in screen.rows {
            var title = ""
            var foot = ""
            switch row {
            case let .toggle(_, rowTitle, rowFoot, _):
                title = rowTitle
                foot = rowFoot
            case let .slider(_, rowTitle, _, _, _, _, _):
                title = rowTitle
            case let .color(_, rowTitle, _):
                title = rowTitle
            case let .picker(_, rowTitle, _, _, rowFoot):
                title = rowTitle
                foot = rowFoot
            case let .action(rowTitle, _, rowFoot, _):
                title = rowTitle
                foot = rowFoot
            case let .link(rowTitle, _, rowFoot):
                title = rowTitle
                foot = rowFoot
            default:
                break
            }
            if title.isEmpty {
                continue
            }
            let flat = title.replacingOccurrences(of: "\n", with: " ")
            if flat.lowercased().contains(query) {
                titleHits.append((flat, screen.title, screen.id))
            } else if foot.lowercased().contains(query) {
                textHits.append((flat, screen.title, screen.id))
            }
        }
    }
    let hits = Array((titleHits + textHits).prefix(40))
    if hits.isEmpty {
        entries.append(.footer(stable: 1, section: 2, text: "Ничего не найдено."))
        return entries
    }
    var stable: Int32 = 10
    for hit in hits {
        stable += 1
        entries.append(.disclosure(stable: stable, section: 2, title: hit.0, subtitle: hit.1, value: "", icon: "", tap: .screen(hit.2)))
    }
    return entries
}

// MARK: - Контроллер любого экрана раздела

public func mattgramSettingsController(context: AccountContext) -> ViewController {
    return mgController(context: context, screen: "hub")
}

private func mgController(context: AccountContext, screen: String) -> ViewController {
    let refresh = ValuePromise<Int>(0, ignoreRepeated: false)
    var refreshCounter = 0
    var searchText = ""
    var controllerRef: (() -> ViewController?)?

    func bump() {
        refreshCounter += 1
        refresh.set(refreshCounter)
    }

    func open(_ id: String) {
        if id == "hub" {
            return
        }
        if id == "search" {
            controllerRef?()?.push(mgController(context: context, screen: "search"))
            return
        }
        if mgFindScreen(id) != nil {
            controllerRef?()?.push(mgController(context: context, screen: id))
        }
    }

    func presentPicker(id: String) {
        guard let (title, options, def) = mgFindPicker(id) else {
            return
        }
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        let current = MGSettings.shared.string(named: id, default: def)
        let actionSheet = ActionSheetController(presentationData: presentationData)
        var buttons: [ActionSheetItem] = []
        buttons.append(ActionSheetTextItem(title: title))
        for option in options {
            let label = option == current ? "\(option) ✓" : option
            buttons.append(ActionSheetButtonItem(title: label, color: .accent, action: { [weak actionSheet] in
                actionSheet?.dismissAnimated()
                MGSettings.shared.setString(named: id, option)
                if id == "eqPre" {
                    for (name, values) in mgEqPresets where name == option {
                        for (index, value) in values.enumerated() {
                            MGSettings.shared.setInt(named: "eq\(index)", value)
                        }
                    }
                }
                MGDevLog.shared.log("выбор \(id) = \(option)", tag: "settings")
                bump()
            }))
        }
        actionSheet.setItemGroups([
            ActionSheetItemGroup(items: buttons),
            ActionSheetItemGroup(items: [
                ActionSheetButtonItem(title: presentationData.strings.Common_Cancel, color: .accent, font: .bold, action: { [weak actionSheet] in
                    actionSheet?.dismissAnimated()
                })
            ])
        ])
        controllerRef?()?.present(actionSheet, in: .window(.root))
    }

    let arguments = MGArguments(toggle: { id, value in
        if id == "__devlog" {
            MGDevLog.shared.isEnabled = value
        } else {
            MGSettings.shared.setBool(named: id, value)
        }
        MGDevLog.shared.log("переключатель \(id) = \(value)", tag: "settings")
        bump()
    }, slider: { id, minValue, maxValue, step, fraction in
        let raw = CGFloat(minValue) + fraction * CGFloat(maxValue - minValue)
        let stepValue = CGFloat(max(1, step))
        var value = Int(round(raw / stepValue) * stepValue)
        value = max(minValue, min(maxValue, value))
        let current = MGSettings.shared.int(named: id, default: Int.min)
        if current != value {
            MGSettings.shared.setInt(named: id, value)
            bump()
        }
    }, color: { id in
        guard let top = MGDevLog.topViewController() else {
            return
        }
        let picker = UIColorPickerViewController()
        picker.supportsAlpha = false
        var fallback = "#000000"
        for row in mgScreenRows(screen) {
            if case let .color(colorId, _, def) = row, colorId == id {
                fallback = def
            }
        }
        picker.selectedColor = mgColor(MGSettings.shared.string(named: id, default: fallback))
        let delegate = MGColorDelegate(changed: { color in
            MGSettings.shared.setString(named: id, mgHex(color))
            bump()
        })
        MGColorDelegate.current = delegate
        picker.delegate = delegate
        top.present(picker, animated: true)
    }, tap: { tap in
        switch tap {
        case let .screen(id):
            open(id)
        case let .picker(id):
            presentPicker(id: id)
        case .search:
            open("search")
        case .none:
            break
        }
    }, action: { act in
        switch act {
        case "resetColors":
            for id in ["bgMain", "bgL", "bgR"] {
                MGSettings.shared.remove(named: id)
            }
            bump()
        case "expJson":
            mgShare(text: MGSettings.shared.exportJSON(), fileName: "mattgram-settings.json")
        case "impJson":
            let count = MGSettings.shared.importJSON(UIPasteboard.general.string ?? "")
            mgAlert("Импорт настроек", count > 0 ? "Загружено параметров: \(count)" : "В буфере обмена нет JSON с настройками MattGram. Скопируйте файл бэкапа как текст и повторите.")
            bump()
        case "saveKc":
            let ok = MGSettings.shared.saveToKeychain()
            mgAlert("Keychain", ok ? "Настройки сохранены в Keychain." : "Не удалось сохранить в Keychain.")
        case "restKc":
            let count = MGSettings.shared.restoreFromKeychain()
            mgAlert("Keychain", count > 0 ? "Восстановлено параметров: \(count)" : "Резервная копия в Keychain не найдена.")
            bump()
        case "eqReset":
            for index in 0 ..< 10 {
                MGSettings.shared.remove(named: "eq\(index)")
            }
            MGSettings.shared.remove(named: "eqPre")
            bump()
        case "addFont":
            mgAlert("Шрифты", "Выбор файла шрифта TTF или OTF появится в следующей сборке.")
        case "dlCopy":
            UIPasteboard.general.string = MGDevLog.shared.readLog()
        case "dlShare":
            mgShare(text: MGDevLog.shared.readLog(), fileName: "mattgram-devlog.txt")
        case "dlTest":
            MGDevLog.shared.error("тестовая запись (кнопка в Dev-логах)", tag: "test")
        case "dlClear":
            MGDevLog.shared.clear()
        default:
            break
        }
    }, searchText: { text in
        searchText = text
        bump()
    })

    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, refresh.get())
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var entries: [MGEntry]
        var title = mgScreenTitle(screen)
        switch screen {
        case "hub":
            entries = mgHubEntries()
            title = ""
        case "search":
            entries = mgSearchEntries(text: searchText)
            title = "Поиск"
        default:
            entries = mgEntries(forRows: mgScreenRows(screen))
        }
        if screen == "devlog" {
            let log = MGDevLog.shared.readLog()
            let tail = String(log.suffix(3000))
            let nextStable = Int32(entries.count + 1000)
            entries.append(.header(stable: nextStable, section: 90, text: "ПОСЛЕДНИЕ ЗАПИСИ"))
            entries.append(.footer(stable: nextStable + 1, section: 90, text: tail.isEmpty ? "Пока пусто." : tail))
        }
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(title), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks, animateChanges: false)
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    controllerRef = { [weak controller] in
        return controller
    }
    return controller
}
