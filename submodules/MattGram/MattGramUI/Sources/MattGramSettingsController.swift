import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext
import MGSettings

// MARK: - Действия

private enum MGAction: Equatable {
    case none
    case openSection(Int)
    case openDevLogs
    case exportBackup
    case importBackup
    case resetAll
    case copyLog
    case shareLog
    case clearLog
    case toggleDevLog
    case testError
}

private final class MGArguments {
    let toggle: (Int, Bool) -> Void
    let action: (MGAction) -> Void

    init(toggle: @escaping (Int, Bool) -> Void, action: @escaping (MGAction) -> Void) {
        self.toggle = toggle
        self.action = action
    }
}

// MARK: - Строки списка

private enum MGEntry: ItemListNodeEntry {
    case brand(stable: Int32, build: String)
    case note(stable: Int32, section: Int32, text: String)
    case header(stable: Int32, section: Int32, text: String)
    case link(stable: Int32, section: Int32, title: String, label: String, action: MGAction)
    case toggle(stable: Int32, section: Int32, featureId: Int, title: String, subtitle: String, value: Bool)
    case button(stable: Int32, section: Int32, title: String, destructive: Bool, action: MGAction)
    case switchRow(stable: Int32, section: Int32, title: String, subtitle: String, value: Bool, action: MGAction)

    var stableId: Int32 {
        switch self {
        case let .brand(stable, _), let .note(stable, _, _), let .header(stable, _, _), let .link(stable, _, _, _, _),
             let .toggle(stable, _, _, _, _, _), let .button(stable, _, _, _, _), let .switchRow(stable, _, _, _, _, _):
            return stable
        }
    }

    var section: ItemListSectionId {
        switch self {
        case .brand:
            return 0
        case let .note(_, section, _), let .header(_, section, _), let .link(_, section, _, _, _),
             let .toggle(_, section, _, _, _, _), let .button(_, section, _, _, _), let .switchRow(_, section, _, _, _, _):
            return section
        }
    }

    static func <(lhs: MGEntry, rhs: MGEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! MGArguments
        switch self {
        case let .brand(_, build):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: UIImage(bundleImageName: "Components/MattGramLogo"), title: "MattGram", label: build, sectionId: self.section, style: .blocks, disclosureStyle: .none, action: nil)
        case let .note(_, _, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .header(_, _, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .link(_, _, title, label, action):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: title, label: label, sectionId: self.section, style: .blocks, action: {
                arguments.action(action)
            })
        case let .toggle(_, _, featureId, title, subtitle, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, text: subtitle.isEmpty ? nil : subtitle, value: value, maximumNumberOfLines: 4, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggle(featureId, value)
            })
        case let .button(_, _, title, destructive, action):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: title, kind: destructive ? .destructive : .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.action(action)
            })
        case let .switchRow(_, _, title, subtitle, value, action):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, text: subtitle.isEmpty ? nil : subtitle, value: value, maximumNumberOfLines: 4, sectionId: self.section, style: .blocks, updated: { _ in
                arguments.action(action)
            })
        }
    }
}

// MARK: - Помощники

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

private func mgEnabledCount(_ section: MGCatalogSection) -> Int {
    var count = 0
    for item in section.items {
        if MGSettings.shared.isEnabled(feature: item.id, default: item.isSystem) {
            count += 1
        }
    }
    return count
}

private func mgNavigationState(presentationData: PresentationData, title: String) -> ItemListControllerState {
    return ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(title), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
}

// MARK: - Главный экран «MattGram»

public func mattgramSettingsController(context: AccountContext) -> ViewController {
    let refresh = ValuePromise<Int>(0, ignoreRepeated: false)
    var refreshCounter = 0
    var controllerRef: (() -> ViewController?)?

    func bump() {
        refreshCounter += 1
        refresh.set(refreshCounter)
    }

    let arguments = MGArguments(toggle: { id, value in
        MGSettings.shared.setEnabled(feature: id, value)
        MGDevLog.shared.log("функция \(id) = \(value)", tag: "settings")
        bump()
    }, action: { action in
        switch action {
        case let .openSection(index):
            guard index >= 0 && index < mgCatalog.count else {
                return
            }
            controllerRef?()?.push(mattgramSectionController(context: context, sectionIndex: index))
        case .openDevLogs:
            controllerRef?()?.push(mattgramDevLogsController(context: context))
        case .exportBackup:
            mgShare(text: MGSettings.shared.exportJSON(), fileName: "mattgram-settings.json")
        case .importBackup:
            let text = UIPasteboard.general.string ?? ""
            let count = MGSettings.shared.importJSON(text)
            MGDevLog.showText(title: "Импорт настроек", text: count > 0 ? "Загружено параметров: \(count)" : "В буфере обмена нет JSON с настройками MattGram. Скопируй файл бэкапа как текст и повтори.")
            bump()
        case .resetAll:
            MGSettings.shared.resetAll()
            bump()
        default:
            break
        }
    })

    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, refresh.get())
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var entries: [MGEntry] = []
        entries.append(.brand(stable: 0, build: "сборка \(MGSettings.shared.buildNumber)"))
        entries.append(.note(stable: 1, section: 0, text: "Версия \(MGSettings.shared.versionString) (\(MGSettings.shared.buildNumber)). Включай и выключай функции — логика добавляется постепенно, выключатели уже сохраняются."))

        entries.append(.header(stable: 2, section: 1, text: "РАЗДЕЛЫ"))
        for (index, section) in mgCatalog.enumerated() {
            entries.append(.link(stable: Int32(100 + index), section: 1, title: section.title, label: "\(mgEnabledCount(section))/\(section.items.count)", action: .openSection(index)))
        }

        entries.append(.header(stable: 400, section: 2, text: "ИНСТРУМЕНТЫ"))
        entries.append(.link(stable: 401, section: 2, title: "Dev-логи", label: MGDevLog.shared.isEnabled ? "вкл" : "выкл", action: .openDevLogs))
        entries.append(.button(stable: 402, section: 2, title: "Экспорт настроек (JSON)", destructive: false, action: .exportBackup))
        entries.append(.button(stable: 403, section: 2, title: "Импорт настроек из буфера обмена", destructive: false, action: .importBackup))
        entries.append(.button(stable: 404, section: 2, title: "Сбросить все настройки MattGram", destructive: true, action: .resetAll))

        let controllerState = mgNavigationState(presentationData: presentationData, title: "MattGram (\(MGSettings.shared.buildNumber))")
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks, animateChanges: false)
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    controllerRef = { [weak controller] in
        return controller
    }
    return controller
}

// MARK: - Экран раздела

private func mattgramSectionController(context: AccountContext, sectionIndex: Int) -> ViewController {
    let section = mgCatalog[sectionIndex]
    let refresh = ValuePromise<Int>(0, ignoreRepeated: false)
    var refreshCounter = 0

    let arguments = MGArguments(toggle: { id, value in
        MGSettings.shared.setEnabled(feature: id, value)
        MGDevLog.shared.log("функция \(id) = \(value)", tag: "settings")
        refreshCounter += 1
        refresh.set(refreshCounter)
    }, action: { _ in
    })

    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, refresh.get())
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var entries: [MGEntry] = []
        for item in section.items {
            let value = MGSettings.shared.isEnabled(feature: item.id, default: item.isSystem)
            let subtitle = item.subtitle + (item.isSystem ? " (системная, по умолчанию включена)" : "")
            entries.append(.toggle(stable: Int32(1000 + item.id), section: 1, featureId: item.id, title: "\(item.id). \(item.title)", subtitle: subtitle, value: value))
        }
        let controllerState = mgNavigationState(presentationData: presentationData, title: section.title)
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks, animateChanges: false)
        return (controllerState, (listState, arguments))
    }
    return ItemListController(context: context, state: signal)
}

// MARK: - Dev-логи

private func mattgramDevLogsController(context: AccountContext) -> ViewController {
    let refresh = ValuePromise<Int>(0, ignoreRepeated: false)
    var refreshCounter = 0

    func bump() {
        refreshCounter += 1
        refresh.set(refreshCounter)
    }

    let arguments = MGArguments(toggle: { _, _ in
    }, action: { action in
        switch action {
        case .copyLog:
            UIPasteboard.general.string = MGDevLog.shared.readLog()
        case .shareLog:
            mgShare(text: MGDevLog.shared.readLog(), fileName: "mattgram-devlog.txt")
        case .clearLog:
            MGDevLog.shared.clear()
            bump()
        case .toggleDevLog:
            MGDevLog.shared.isEnabled = !MGDevLog.shared.isEnabled
            bump()
        case .testError:
            MGDevLog.shared.error("тестовая запись (кнопка в Dev-логах)", tag: "test")
            bump()
        default:
            break
        }
    })

    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, refresh.get())
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var entries: [MGEntry] = []
        entries.append(.switchRow(stable: 0, section: 1, title: "Записывать логи", subtitle: "Логи и ошибки сохраняются в файл и остаются после перезапуска. После вылета при следующем запуске покажется точная ошибка.", value: MGDevLog.shared.isEnabled, action: .toggleDevLog))
        entries.append(.button(stable: 1, section: 2, title: "Копировать весь лог", destructive: false, action: .copyLog))
        entries.append(.button(stable: 2, section: 2, title: "Поделиться логом (файл)", destructive: false, action: .shareLog))
        entries.append(.button(stable: 3, section: 2, title: "Записать тестовую ошибку", destructive: false, action: .testError))
        entries.append(.button(stable: 4, section: 2, title: "Очистить лог", destructive: true, action: .clearLog))

        let log = MGDevLog.shared.readLog()
        let tail = String(log.suffix(4000))
        entries.append(.header(stable: 10, section: 3, text: "ПОСЛЕДНИЕ ЗАПИСИ"))
        entries.append(.note(stable: 11, section: 3, text: tail.isEmpty ? "Пока пусто." : tail))

        let controllerState = mgNavigationState(presentationData: presentationData, title: "Dev-логи")
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks, animateChanges: false)
        return (controllerState, (listState, arguments))
    }
    return ItemListController(context: context, state: signal)
}
