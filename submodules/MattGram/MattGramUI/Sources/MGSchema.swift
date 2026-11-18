// Файл создан скриптом tools/gen_schema.py из сайта-копии настроек Nextgram — вручную не править.
import Foundation

public enum MGRow: Equatable {
    case header(String)
    case toggle(id: String, title: String, foot: String, def: Bool)
    case slider(id: String, title: String, min: Int, max: Int, step: Int, def: Int, unit: String)
    case color(id: String, title: String, def: String)
    case link(title: String, screen: String, foot: String)
    case picker(id: String, title: String, options: [String], def: String, foot: String)
    case action(title: String, act: String, foot: String, danger: Bool)
    case preview(kind: String)
    case note(String)
}

public struct MGScreen {
    public let id: String
    public let title: String
    public let rows: [MGRow]
}

public struct MGHubRow {
    public let id: String
    public let title: String
    public let sub: String
    public let icon: String
    public let isSearch: Bool
}

private let mgRows_glass: [MGRow] = [
    .header("LIQUID GLASS"),
    .toggle(id: "gMsg", title: "Сделать интерфейс\nсообщений Liquid Glass", foot: "Отображает сообщения как отражающие окружающий интерфейс поверхности Liquid Glass.", def: false),
    .toggle(id: "gBtn", title: "Сделать интерфейс\nинлайн-кнопок\nLiquid Glass", foot: "Применяет материал Liquid Glass к кнопкам, прикреплённым под сообщениями.", def: false),
    .toggle(id: "gDark", title: "Сделать Liquid Glass\nболее тёмным", foot: "Добавляет стеклу тёмный оттенок, повышая контраст и приглушая блики.", def: false),
    .link(title: "Настройки Liquid Glass", screen: "lgset", foot: ""),
    .header("РЕЖИМ СТЕКЛА"),
    .toggle(id: "mIce", title: "Заменить Liquid Glass\nна иней", foot: "Холодное стекло MattGram: матовый иней с кристаллами по краям, который можно стирать пальцем.", def: false),
    .toggle(id: "mBlur", title: "Заменить Liquid Glass\nна обычный блюр", foot: "Использует во всём интерфейсе простое размытие фона вместо отражающего стекла.", def: false),
    .toggle(id: "mColor", title: "Заменить Liquid Glass\nна цвет интерфейса Telegram", foot: "Заменяет полупрозрачное стекло сплошным цветом выбранной темы Telegram.", def: false),
    .header("СООБЩЕНИЯ"),
    .toggle(id: "bOut", title: "Включить светлую\nобводку на сообщения", foot: "Добавляет светлый край, который аккуратно отделяет сообщения от фона чата.", def: false),
    .toggle(id: "bTr", title: "Сделать сообщения\nпрозрачными", foot: "Убирает сплошную заливку сообщений, чтобы сквозь них был виден фон чата.", def: false),
    .toggle(id: "bSemi", title: "Сделать сообщения\nполупрозрачными", foot: "Смягчает заливку сообщений, сохраняя текст хорошо читаемым.", def: false),
    .toggle(id: "bIce", title: "Заменить интерфейс\nсообщений на\nиней", foot: "Делает сообщения холодным стеклом с инеем, который можно стирать пальцем.", def: false),
    .toggle(id: "bBlur", title: "Заменить интерфейс\nсообщений на\nобычный блюр", foot: "Заменяет заливку сообщений нейтральным размытием расположенного под ними фона.", def: false),
]

private let mgRows_lgset: [MGRow] = [
    .preview(kind: "tab"),
    .note("Так выглядит нижняя панель с выбранным режимом стекла."),
]

private let mgRows_profile: [MGRow] = [
    .header("ПРОФИЛЬ"),
    .toggle(id: "pId", title: "Отображать ID аккаунта\nв профиле", foot: "Добавляет в профиль числовой идентификатор аккаунта, который можно скопировать нажатием.", def: false),
    .toggle(id: "pDc", title: "Отображать DC\n(дата-центр) аккаунта\nв профиле", foot: "Показывает дата-центр Telegram, где хранится аккаунт, и при наличии страну номера.", def: false),
    .toggle(id: "pPhone", title: "Скрыть номер телефона", foot: "Скрывать номер телефона и в настройках, и в профиле.", def: false),
    .toggle(id: "pGifts", title: "Скрыть вкладку «Подарки»", foot: "", def: false),
    .toggle(id: "pMut", title: "Отображать в профиле\nсобеседника значок,\nчто вы оба в контактах", foot: "Добавляет значок взаимного контакта, если вы и собеседник сохранили друг друга.", def: false),
    .toggle(id: "pCre", title: "Отображать дату\nсоздания чата\nв профиле", foot: "Добавляет в профиль дату создания чата, группы или канала.", def: false),
    .toggle(id: "pSeen", title: "Отображать точное время\nзахода в сеть", foot: "Дополняет относительный статус последнего посещения точным временем с секундами.", def: false),
    .header("МУЗЫКА"),
    .toggle(id: "pMusic", title: "Обновлённый вид\nприкреплённой музыки\nв профиле", foot: "Показывает прикреплённую музыку большой анимированной карточкой с обложкой или чёрно-белым фоном.", def: false),
]

private let mgRows_tabbar: [MGRow] = [
    .header("ВКЛАДКИ"),
    .toggle(id: "tHide", title: "Скрыть панель вкладок", foot: "Скрыть всю панель вкладок (может понадобиться перезапуск).", def: false),
    .toggle(id: "tCont", title: "Скрыть вкладку\n«Контакты»", foot: "Убирает «Контакты» из нижнего таббара, не затрагивая адресную книгу.", def: false),
    .toggle(id: "tCall", title: "Скрыть вкладку\n«Звонки»", foot: "Убирает «Звонки» из нижнего таббара, сохраняя историю звонков в других разделах.", def: false),
    .toggle(id: "tSrch", title: "Показывать кнопку поиска\nрядом с нижним таббаром", foot: "Добавляет отдельную кнопку поиска рядом с нижним таббаром для быстрого доступа.", def: false),
    .header("РАЗМЕР"),
    .slider(id: "tH", title: "Высота панели", min: 50, max: 100, step: 1, def: 100, unit: "%"),
    .slider(id: "tW", title: "Ширина панели", min: 50, max: 100, step: 1, def: 100, unit: "%"),
]

private let mgRows_folders: [MGRow] = [
    .header("ПАПКИ"),
    .toggle(id: "fBot", title: "Переместить список папок\nк нижнему таббару", foot: "Переносит выбор папок чатов к нижним элементам управления для удобства одной рукой.", def: false),
    .toggle(id: "fAll", title: "Скрыть папку «Все чаты»", foot: "Убрать вкладку «Все чаты» из панели папок.", def: false),
    .toggle(id: "fLast", title: "Открывать последнюю\nвыбранную папку при входе", foot: "Возвращает последнюю выбранную папку вместо постоянного открытия «Все чаты».", def: false),
]

private let mgRows_look: [MGRow] = [
    .header("ВНЕШНИЙ ВИД"),
    .toggle(id: "cSq", title: "Сделать аватарки\nквадратными", foot: "Меняет круглые аватарки в списке чатов на квадраты с мягкими углами.", def: false),
    .toggle(id: "cCmp", title: "Сделать список чатов\nболее компактным", foot: "Уменьшает высоту строк, чтобы на экране одновременно помещалось больше чатов.", def: false),
    .toggle(id: "cNew", title: "Обновлённый вид\nсписка чатов", foot: "Применяет к списку диалогов обновлённую компоновку и оформление MattGram.", def: false),
    .toggle(id: "cTitle", title: "Убрать надпись «Чаты»\nв списке чатов", foot: "Скрывает крупный заголовок «Чаты», освобождая место над списком диалогов.", def: false),
    .toggle(id: "cRam", title: "Отображать потребление\nОЗУ под часами", foot: "Показывает текущее потребление памяти приложением под часами в статус-баре.", def: false),
    .toggle(id: "cPrem", title: "Отображать Premium-значок\nв списке чатов", foot: "Показывает ваш значок Premium в верхней части списка чатов.", def: false),
    .toggle(id: "cAcc", title: "Добавить удобное\nпереключение аккаунтов\nв списке чатов", foot: "Добавляет быстрый переход между аккаунтами без открытия настроек.", def: false),
    .toggle(id: "cStory", title: "Включить свайп\nдля записи истории\nв списке чатов", foot: "Открывает камеру историй свайпом вверх из списка чатов.", def: false),
    .toggle(id: "cBiz", title: "Скрыть панель\nбизнес-бота в чате", foot: "Скрывает верхнюю панель управления бизнес-ботом в чате.", def: false),
    .header("ФОН СПИСКА ЧАТОВ"),
    .toggle(id: "bgOn", title: "Свой фон списка чатов", foot: "Добавляет под список чатов тёмную основу и два мягких цветных градиентных пятна.", def: false),
    .preview(kind: "pal"),
    .color(id: "bgMain", title: "Основной фон", def: "#0b0d14"),
    .color(id: "bgL", title: "Левое градиентное пятно", def: "#2b6df0"),
    .color(id: "bgR", title: "Правое градиентное пятно", def: "#d4488f"),
    .action(title: "Сбросить цвета", act: "resetColors", foot: "Возвращает исходную палитру MattGram.", danger: false),
]

private let mgRows_swipes: [MGRow] = [
    .header("СВАЙП-ДЕЙСТВИЯ"),
    .toggle(id: "sOn", title: "Включить свайпы для чатов\nв списке чатов", foot: "Открывает быстрые действия — отключение звука, архив и закрепление — при свайпе по чату.", def: false),
    .toggle(id: "sDel", title: "Удаление свайпом", foot: "Показывать действие «Удалить» среди свайп-действий.", def: false),
]

private let mgRows_rec: [MGRow] = [
    .header("ИСТОРИИ"),
    .toggle(id: "rDraw", title: "Скрыть шторку историй\nв списке чатов", foot: "Убирает раскрывающуюся шторку историй над списком чатов.", def: false),
    .toggle(id: "rRepost", title: "Репост в историю", foot: "Показывать «Репост в историю» в меню шаринга.", def: false),
]

private let mgRows_time: [MGRow] = [
    .header("СООБЩЕНИЯ"),
    .toggle(id: "xSec", title: "Отображать секунды\nво времени сообщений", foot: "Добавляет секунды ко времени сообщений и их превью в списке чатов.", def: false),
    .toggle(id: "xDbl", title: "Двойной тап для правки", foot: "Двойной тап по своему сообщению открывает правку.", def: false),
    .toggle(id: "xStk", title: "Отображать время\nна стикерах", foot: "Показывает время отправки непосредственно рядом со стикерами.", def: false),
    .toggle(id: "xReact", title: "Скрыть все реакции", foot: "Скрывать реакции на сообщениях и в контекстном меню.", def: false),
    .toggle(id: "xWide", title: "Широкие посты в каналах", foot: "", def: false),
    .toggle(id: "xBtn", title: "Скрыть нижние кнопки канала", foot: "", def: false),
    .toggle(id: "xView", title: "Полные просмотры на постах", foot: "", def: false),
    .toggle(id: "xSvc", title: "Время у системных сообщений", foot: "", def: false),
    .toggle(id: "xDelAn", title: "Убрать анимацию при удалении", foot: "", def: false),
    .toggle(id: "xAs", title: "Кнопка «Отправить как»", foot: "Показывать кнопку отправки сообщений от другого имени.", def: false),
    .toggle(id: "xType", title: "Анимация печати", foot: "Показывает каждое новое входящее и исходящее сообщение с красивым появлением по символам.", def: false),
    .header("ПРОКРУТКА"),
    .toggle(id: "xCh", title: "Прокрутка к след. каналу", foot: "Продолжайте тянуть внизу, чтобы открыть следующий непрочитанный канал.", def: false),
    .toggle(id: "xTp", title: "Прокрутка к след. топику", foot: "Продолжайте тянуть внизу, чтобы открыть следующий непрочитанный топик.", def: false),
    .toggle(id: "xScr", title: "Анимация прокрутки чата", foot: "Добавляет пузырям сообщений плавную глубину и инерцию в стиле iMessage при прокрутке.", def: false),
]

private let mgRows_video: [MGRow] = [
    .header("ВИДЕО"),
    .toggle(id: "vPip", title: "Картинка в картинке", foot: "Свайп видео вверх для перехода в режим PiP.", def: false),
    .header("КАМЕРА"),
    .toggle(id: "vRear", title: "Кружок с задней камеры", foot: "Начинать запись видеосообщений с задней камеры.", def: false),
    .toggle(id: "vGal", title: "Камера в галерее", foot: "Показывать ячейку камеры в медиа-галерее.", def: false),
    .link(title: "Управление камерой", screen: "cam", foot: "Разрешение, FPS и настройки объектива."),
    .header("ФОТО"),
    .toggle(id: "vHd", title: "Отправлять фото в HD качестве", foot: "Отправлять фото как более крупные изображения высокого качества.", def: false),
    .toggle(id: "vHd2", title: "Всегда отправлять в HD", foot: "", def: false),
    .toggle(id: "vMeta", title: "Очищать метаданные", foot: "", def: false),
    .slider(id: "vJpg", title: "Качество JPEG", min: 50, max: 100, step: 1, def: 85, unit: "%"),
]

private let mgRows_cam: [MGRow] = [
    .toggle(id: "kTg", title: "Использовать настройки Telegram", foot: "Использовать стандартные разрешение и FPS камеры Telegram. Кружки сохраняют естественный вид. Выключите, чтобы управлять камерой вручную ниже.", def: true),
    .header("ЗАДНЯЯ КАМЕРА"),
    .picker(id: "kBr", title: "Разрешение", options: ["720p", "1080p", "4K"], def: "1080p", foot: ""),
    .picker(id: "kBf", title: "FPS", options: ["24", "30", "60"], def: "30", foot: ""),
    .header("ФРОНТАЛЬНАЯ КАМЕРА"),
    .picker(id: "kFr", title: "Разрешение", options: ["720p", "1080p"], def: "1080p", foot: ""),
    .picker(id: "kFf", title: "FPS", options: ["24", "30", "60"], def: "30", foot: ""),
    .header(""),
    .toggle(id: "kWide", title: "0,5× для видеосообщений", foot: "", def: false),
    .toggle(id: "kRem", title: "Запоминать последнюю камеру", foot: "", def: false),
    .toggle(id: "kZoom", title: "Статичный зум", foot: "", def: false),
]

private let mgRows_kb: [MGRow] = [
    .header("ЭМОДЗИ"),
    .toggle(id: "eFirst", title: "Сначала вкладка эмодзи", foot: "Всегда открывать вкладку эмодзи в клавиатуре стикеров.", def: false),
    .toggle(id: "eDef", title: "Обычные эмодзи первыми", foot: "Показывать группу обычных эмодзи перед кастомными.", def: false),
    .header("ВВОД"),
    .toggle(id: "iEnter", title: "Отправка сообщений по Enter", foot: "Нажмите Enter, чтобы отправить сообщение.", def: false),
    .toggle(id: "iCt", title: "Счётчик символов при вводе", foot: "", def: false),
    .toggle(id: "iCc", title: "Счётчик символов в чате", foot: "Показывать счётчик символов у текста сообщения.", def: false),
    .toggle(id: "iTool", title: "Включить панель удобного\nформатирования текста", foot: "Добавляет над клавиатурой панель для быстрого применения жирного шрифта, курсива, подчёркивания, зачёркивания, моноширинного текста, спойлера, цитаты и ссылок.", def: false),
    .toggle(id: "iAuto", title: "Автоформатирование текста", foot: "", def: false),
    .toggle(id: "iZal", title: "Zalgo-фильтр", foot: "", def: false),
    .toggle(id: "iTr", title: "Кнопка «Перевести»", foot: "", def: false),
]

private let mgRows_mic: [MGRow] = [
    .header("ГОЛОСОВЫЕ"),
    .toggle(id: "mBi", title: "Использовать встроенный\nмикрофон устройства", foot: "Записывает голосовые через микрофон устройства даже при подключённой гарнитуре.", def: false),
    .toggle(id: "mNx", title: "Не прослушивать\nследующее голосовое", foot: "Останавливает воспроизведение после текущего голосового, не запуская следующее автоматически.", def: false),
    .toggle(id: "mHide", title: "Скрыть кнопку записи в чате", foot: "", def: false),
    .toggle(id: "mOnce", title: "Записи сразу одноразовые", foot: "", def: false),
    .toggle(id: "mApple", title: "Транскрибировать голосовые\nчерез Apple Speech", foot: "Переводит голосовые сообщения и кружки в текст без ограничений и не требует Telegram Premium.", def: false),
]

private let mgRows_changer: [MGRow] = [
    .header("ЭФФЕКТ ГОЛОСА"),
    .toggle(id: "cEn", title: "Включить смену голоса", foot: "Применять выбранный эффект к новым голосовым сообщениям и кружкам.", def: false),
    .picker(id: "cPre", title: "Смена голоса", options: ["Не выбрано", "Взрослый", "Инопланетянин"], def: "Не выбрано", foot: ""),
    .header("СВОЙ ГОЛОС"),
    .slider(id: "cP", title: "Тон", min: -12, max: 12, step: 1, def: 0, unit: ""),
    .slider(id: "cT", title: "Тембр", min: -50, max: 50, step: 1, def: 0, unit: ""),
    .slider(id: "cE", title: "Эхо", min: 0, max: 100, step: 1, def: 0, unit: "%"),
    .slider(id: "cC", title: "Ясность", min: 0, max: 100, step: 1, def: 50, unit: "%"),
    .note("Эффект записывается непосредственно в новое сообщение. Уже отправленные записи не изменяются."),
]

private let mgRows_callconf: [MGRow] = [
    .header("ЗВОНКИ"),
    .toggle(id: "qAsk", title: "Спросить перед звонком", foot: "Спрашивать подтверждение перед началом звонка.", def: false),
    .toggle(id: "qTcp", title: "Использовать TCP", foot: "Принудительно использовать TCP для звонков.", def: false),
]

private let mgRows_player: [MGRow] = [
    .header("ПЛЕЕР"),
    .toggle(id: "plX", title: "Кроссфейд", foot: "Плавно переключать треки.", def: false),
    .slider(id: "plD", title: "Длительность кроссфейда", min: 1, max: 12, step: 1, def: 4, unit: " с"),
    .header("ЭКВАЛАЙЗЕР"),
    .toggle(id: "eqOn", title: "Эквалайзер", foot: "", def: false),
    .link(title: "Настройки эквалайзера", screen: "eq", foot: ""),
]

private let mgRows_accel: [MGRow] = [
    .header("ПЕРЕДАЧА ДАННЫХ"),
    .picker(id: "aUp", title: "Ускорение отправки", options: ["Выкл", "8 потоков", "16 потоков", "Максимум"], def: "Выкл", foot: ""),
    .picker(id: "aDn", title: "Ускорение загрузки", options: ["Выкл", "8 потоков", "16 потоков", "Максимум"], def: "Выкл", foot: ""),
]

private let mgRows_hide: [MGRow] = [
    .header("СКРЫТЬ РАЗДЕЛЫ"),
    .toggle(id: "hs0", title: "Избранное", foot: "", def: false),
    .toggle(id: "hs1", title: "Устройства", foot: "", def: false),
    .toggle(id: "hs2", title: "Папки с чатами", foot: "", def: false),
    .toggle(id: "hs3", title: "Энергосбережение", foot: "", def: false),
    .toggle(id: "hs4", title: "Язык", foot: "", def: false),
    .toggle(id: "hs5", title: "Уведомления", foot: "", def: false),
    .toggle(id: "hs6", title: "Конфиденциальность", foot: "", def: false),
    .toggle(id: "hs7", title: "Данные и память", foot: "", def: false),
    .toggle(id: "hs8", title: "Оформление", foot: "", def: false),
    .toggle(id: "hs9", title: "Прокси", foot: "", def: false),
    .toggle(id: "hs10", title: "Мой профиль", foot: "", def: false),
    .toggle(id: "hs11", title: "Недавние звонки", foot: "", def: false),
    .toggle(id: "hs12", title: "Telegram Premium", foot: "", def: false),
    .toggle(id: "hs13", title: "Мои звёзды", foot: "", def: false),
    .toggle(id: "hs14", title: "Telegram для бизнеса", foot: "", def: false),
    .toggle(id: "hs15", title: "Кошелёк", foot: "", def: false),
    .toggle(id: "hs16", title: "Поддержка", foot: "", def: false),
    .toggle(id: "hs17", title: "Вопросы и ответы", foot: "", def: false),
    .toggle(id: "hs18", title: "Советы и функции", foot: "", def: false),
    .header("КНОПКИ ПРОФИЛЯ"),
    .toggle(id: "hbG", title: "Отправить подарок", foot: "", def: false),
    .toggle(id: "hbE", title: "Установить эмодзи-статус", foot: "", def: false),
    .toggle(id: "hbC", title: "Изменить цвет профиля", foot: "", def: false),
    .toggle(id: "hbP", title: "Изменить фотографию", foot: "", def: false),
    .header("СКРЫТЬ ЭЛЕМЕНТЫ"),
    .toggle(id: "hSp", title: "Скрыть канал-спонсор", foot: "Скрывает канал-спонсор от MTProto прокси из закрепов в списке чатов.", def: false),
    .toggle(id: "hRt", title: "Скрыть рейтинг аккаунта", foot: "Убирает кнопку с иконкой щита и рейтингом в настройках и профилях людей.", def: false),
]

private let mgRows_json: [MGRow] = [
    .header("НАСТРОЙКИ"),
    .action(title: "Экспортировать в JSON", act: "expJson", foot: "", danger: false),
    .action(title: "Импортировать из JSON", act: "impJson", foot: "", danger: false),
    .action(title: "Сохранить в Keychain", act: "saveKc", foot: "", danger: false),
    .action(title: "Восстановить из Keychain", act: "restKc", foot: "", danger: false),
]

private let mgRows_misc: [MGRow] = [
    .header("ШРИФТ"),
    .toggle(id: "fOn", title: "Использовать свой шрифт", foot: "Применять выбранный шрифт ко всему интерфейсу. Текущий: системный.", def: false),
    .link(title: "Шрифты", screen: "fonts", foot: "Выбрать или добавить шрифт TTF/OTF."),
    .header("КЭШ"),
    .toggle(id: "chOn", title: "Автоочистка кэша\nпри входе в приложение", foot: "Проверяет общий размер медиакэша при каждом входе в MattGram и безопасно очищает его в фоне после достижения выбранного лимита. Чаты и сообщения сохраняются, а медиа при необходимости загрузятся повторно.", def: false),
    .slider(id: "chL", title: "Лимит автоочистки", min: 1, max: 20, step: 1, def: 5, unit: " ГБ"),
    .header("ВИБРАЦИЯ"),
    .toggle(id: "hpOn", title: "Добавить вибрацию\nпо интерфейсу", foot: "Добавляет лёгкий отклик при открытии чата, нажатии на поле ввода и кнопки в чате, а также нарастающую вибрацию при раскрытии панели вложений.", def: false),
    .header("НАГРЕВ"),
    .toggle(id: "thK", title: "При нагреве, не взаимодействовать\nс интерфейсом MattGram", foot: "По умолчанию при нагреве устройства MattGram упрощает себя: стеклянные сообщения превращаются в сплошную заливку. Включите, чтобы интерфейс оставался прежним — устройство может греться сильнее.", def: false),
]

public let mgScreens: [MGScreen] = [
    MGScreen(id: "glass", title: "Liquid Glass", rows: mgRows_glass),
    MGScreen(id: "lgset", title: "Настройки Liquid Glass", rows: mgRows_lgset),
    MGScreen(id: "profile", title: "Профили", rows: mgRows_profile),
    MGScreen(id: "tabbar", title: "Вкладки", rows: mgRows_tabbar),
    MGScreen(id: "folders", title: "Папки", rows: mgRows_folders),
    MGScreen(id: "look", title: "Внешний вид", rows: mgRows_look),
    MGScreen(id: "swipes", title: "Список чатов", rows: mgRows_swipes),
    MGScreen(id: "rec", title: "Истории", rows: mgRows_rec),
    MGScreen(id: "time", title: "Сообщения", rows: mgRows_time),
    MGScreen(id: "video", title: "Медиа и камера", rows: mgRows_video),
    MGScreen(id: "cam", title: "Управление камерой", rows: mgRows_cam),
    MGScreen(id: "kb", title: "Ввод и эмодзи", rows: mgRows_kb),
    MGScreen(id: "mic", title: "Голосовые", rows: mgRows_mic),
    MGScreen(id: "changer", title: "Смена голоса", rows: mgRows_changer),
    MGScreen(id: "callconf", title: "Звонки", rows: mgRows_callconf),
    MGScreen(id: "player", title: "Музыка", rows: mgRows_player),
    MGScreen(id: "accel", title: "Сеть", rows: mgRows_accel),
    MGScreen(id: "hide", title: "Разделы настроек", rows: mgRows_hide),
    MGScreen(id: "json", title: "Резервная копия", rows: mgRows_json),
    MGScreen(id: "misc", title: "Прочее", rows: mgRows_misc),
]

public let mgHubRows: [MGHubRow] = [
    MGHubRow(id: "search", title: "Поиск", sub: "", icon: "magnifyingglass", isSearch: true),
    MGHubRow(id: "look", title: "Внешний вид", sub: "Стекло и эффекты", icon: "paintbrush.fill", isSearch: false),
    MGHubRow(id: "glass", title: "Liquid Glass", sub: "Стекло, блюр и сообщения", icon: "circle.hexagongrid.fill", isSearch: false),
    MGHubRow(id: "profile", title: "Профили", sub: "ID и дополнения профиля", icon: "person.crop.circle", isSearch: false),
    MGHubRow(id: "tabbar", title: "Вкладки", sub: "Панель вкладок", icon: "rectangle.bottomthird.inset.filled", isSearch: false),
    MGHubRow(id: "folders", title: "Папки", sub: "Папки чатов", icon: "folder", isSearch: false),
    MGHubRow(id: "swipes", title: "Список чатов", sub: "Свайп-действия", icon: "list.bullet", isSearch: false),
    MGHubRow(id: "rec", title: "Истории", sub: "Запись и репост", icon: "camera.circle", isSearch: false),
    MGHubRow(id: "time", title: "Сообщения", sub: "Время и прокрутка", icon: "text.bubble", isSearch: false),
    MGHubRow(id: "video", title: "Медиа и камера", sub: "Видео и фото", icon: "photo", isSearch: false),
    MGHubRow(id: "kb", title: "Ввод и эмодзи", sub: "Клавиатура и эмодзи", icon: "keyboard", isSearch: false),
    MGHubRow(id: "mic", title: "Голосовые", sub: "Микрофон", icon: "waveform", isSearch: false),
    MGHubRow(id: "changer", title: "Смена голоса", sub: "Пресеты и свой голос", icon: "waveform.badge.plus", isSearch: false),
    MGHubRow(id: "callconf", title: "Звонки", sub: "Подтверждение звонков", icon: "phone", isSearch: false),
    MGHubRow(id: "player", title: "Музыка", sub: "Плеер, кроссфейд и эквалайзер", icon: "music.note", isSearch: false),
    MGHubRow(id: "accel", title: "Сеть", sub: "Ускорение отправки и загрузки", icon: "arrow.up.arrow.down", isSearch: false),
    MGHubRow(id: "hide", title: "Разделы настроек", sub: "Скрытие стандартных разделов", icon: "eye.slash", isSearch: false),
    MGHubRow(id: "json", title: "Резервная копия", sub: "JSON и Keychain", icon: "externaldrive", isSearch: false),
    MGHubRow(id: "misc", title: "Прочее", sub: "Разное", icon: "gearshape", isSearch: false),
]
