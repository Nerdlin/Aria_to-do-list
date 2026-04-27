# 🌟 Aria Productivity App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**Aria** — это современное и элегантное приложение для управления задачами и повышения продуктивности, созданное на Flutter. Дизайн вдохновлён мягким неоморфизмом (Glassmorphism-lite), предлагая пользователю плавный и интуитивно понятный интерфейс с умными AI-подсказками и статистикой.

---

## ✨ Ключевые возможности

* 🔐 **Безопасная аутентификация**: Интеграция с **Firebase Authentication** (Вход и регистрация по Email/Паролю).
* ☁️ **Облачная синхронизация**: Все задачи сохраняются и синхронизируются в реальном времени с помощью **Google Cloud Firestore**.
* 🎨 **Pixel-Perfect UI**: Исключительно красивый интерфейс, вдохновленный передовыми макетами из Figma (Плавные градиенты, карточки, закругления).
* 🤖 **AI Помощник**: Интеграция с OpenRouter API (Nvidia Nemotron 120B) для умных рекомендаций и анализа задач.
* 💡 **AI Анализ приоритетов**: Автоматические рекомендации по приоритизации задач с учетом контекста.
* 📝 **Разбивка задач**: AI помогает разделить сложные задачи на простые выполнимые шаги.
* 📊 **Аналитика и статистика**: Отслеживание фокус-времени, завершенных задач и "стриков" (ежедневной активности).
* 🌍 **Мультиязычность**: Поддержка английского и русского языков.
* 🔐 **Безопасность**: API ключи не попадают в Git; для production рекомендуется backend-proxy для AI запросов.
* 📱 **Кроссплатформенность**: Готово к запуску на Android и iOS из единой кодовой базы.
* 🔔 **Напоминания**: Уведомления о задачах и событиях.
* 👤 **Управление профилем**: Изменение имени и аватара пользователя.

---

## 📸 Экраны приложения (из Figma Make)

|              Экран              |                                      Реализовано                                      |
| :-----------------------------------: | :-----------------------------------------------------------------------------------------------: |
|        **Splash Screen**        |                          ✅ Градиент, автонавигация                          |
| **Onboarding (3 слайда)** |           ✅ Анимации, Smart Planning, Priority Intelligence, Time Optimization           |
|         **Auth Screen**         |                           ✅ Firebase Auth, красивые формы                           |
|     **Registration Screen**     |                        ✅ Firebase Auth, валидация, ошибки                        |
|         **Home Screen**         |        ✅ AI Insight, Quick Stats, Schedule, Priority Tasks, Weekly Progress, Focus Timer        |
|        **Tasks Screen**        |         ✅ Поиск, фильтры (All/Today/High/AI Pick), toggle completion, delete         |
|       **Add Task Screen**       |          ✅ AI Suggestions, AI Priority Analysis, 6 категорий, date/time picker          |
|     **AI Assistant Screen**     |             ✅ Productivity Insights, Smart Scheduling, Task Breakdown, Quick Actions             |
|      **Analytics Screen**      | ✅ Score Ring с анимацией, 4 stat cards, Weekly Chart, Category Breakdown, Achievements |
|       **Settings Screen**       |            ✅ Profile card, AI Features, Notifications, Appearance, Account, Sign Out            |

### Особенности реализации:

- 🎨 **Pixel-perfect** - полное соответствие Figma дизайну
- 🔥 **No hardcoded data** - все данные из Firebase в реальном времени
- ✨ **Анимации** - score ring, progress bars, transitions
- 🎯 **Градиенты** - точные цвета из Figma (#8B5CF6, #6366F1, etc.)
- 📊 **Графики** - Weekly Progress, Category Breakdown
- 🏆 **Achievements** - badges с unlock состояниями

---

## 🚀 Быстрый запуск

### 1. Установка зависимостей

```bash
flutter pub get
```

### 2. Настройка API ключей (Важно!)

```bash
# Скопируйте шаблон
cp .env.example .env

# Откройте .env и добавьте ваши ключи:
AI_BASE_URL=https://your-ai-endpoint.com
AI_API_KEY=your-api-key-here
AI_MODEL=nvidia/nemotron-3-super-120b-a12b:free
INITIAL_PASSWORD=your-initial-password

# Windows-скрипт run_mobile.bat подхватит эти значения автоматически.
# Для ручного запуска используйте:
flutter run --dart-define=AI_BASE_URL=https://your-ai-endpoint.com --dart-define=AI_API_KEY=your-api-key-here --dart-define=AI_MODEL=nvidia/nemotron-3-super-120b-a12b:free
```

**Рекомендуемые бесплатные модели:**

- `nvidia/nemotron-3-super-120b-a12b:free` (120B параметров, очень умная)
- `meta-llama/llama-3.2-3b-instruct:free` (быстрая)
- `google/gemma-2-9b-it:free` (сбалансированная)

### 3. Автоматический запуск

#### Windows

```bash
.\run_mobile.bat
```

#### Mac/Linux

```bash
chmod +x run_mobile.sh
./run_mobile.sh
```

Скрипт автоматически:

1. Проверяет, запущен ли эмулятор
2. Запускает Android эмулятор (если нужно)
3. Ждет загрузки (~45 сек)
4. Запускает приложение

---

## 📱 Ручная установка

### 1. Предварительные требования

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (версия >= 3.41.7)
* [Android Studio](https://developer.android.com/studio) (для Android SDK и эмуляторов)

### 2. Установка зависимостей

```bash
flutter pub get
```

### 3. Настройка Firebase

Firebase инициализируется через `lib/firebase_options.dart`, поэтому Android debug-сборка не зависит от `android/app/google-services.json`.

Если нужно использовать свой Firebase проект:

1. Создайте проект в [Firebase Console](https://console.firebase.google.com/)
2. Включите **Authentication** (Email/Password)
3. Включите **Firestore Database** (Test Mode)
4. Перегенерируйте `lib/firebase_options.dart` через FlutterFire CLI или обновите значения вручную

### 4. Запуск эмулятора

```bash
flutter emulators --launch Medium_Phone_API_36.1
```

### 5. Запуск приложения

```bash
flutter run -d emulator-5554
```

---

## 📂 Структура проекта

```text
lib/
├── screens/            # Экраны приложения
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth_screen.dart
│   ├── registration_screen.dart
│   ├── home_screen.dart
│   ├── tasks_screen.dart
│   ├── add_task_screen.dart
│   ├── ai_assistant_screen.dart       # 🤖 AI-помощник
│   ├── analytics_screen.dart
│   ├── settings_screen.dart
│   ├── edit_profile_screen.dart
│   └── subscription_screen.dart
├── services/           # Бизнес-логика и API
│   ├── ai_service.dart                  # 🤖 OpenRouter API интеграция
│   ├── task_service.dart                # Firestore задачи
│   ├── auth_service.dart                # Firebase Auth
│   ├── auth_error_mapper.dart           # Обработка ошибок auth
│   ├── profile_service.dart             # Профиль пользователя
│   ├── subscription_service.dart        # Подписки
│   ├── notification_service.dart        # Уведомления
│   ├── update_service.dart              # Обновления приложения
│   ├── app_controller.dart              # Контроллер приложения
│   └── task_metrics.dart                # Аналитика
├── widgets/            # Переиспользуемые компоненты
│   ├── app_shell.dart                   # Навигация (5 вкладок)
│   ├── focus_timer_sheet.dart           # Focus Timer
│   └── profile_avatar.dart              # Аватар профиля
├── models/             # Модели данных
│   └── user_profile.dart
├── utils/              # Утилиты
│   ├── app_colors.dart                   # Цветовая палитра
│   └── translations.dart               # Мультиязычность (EN/RU)
├── firebase_options.dart
└── main.dart            # Точка входа
```

---

## 🛠️ Используемые технологии

* **Фреймворк:** [Flutter](https://flutter.dev/) 3.41.7
* **Язык:** [Dart](https://dart.dev/)
* **База Данных:** [Cloud Firestore](https://firebase.google.com/products/firestore)
* **Аутентификация:** [Firebase Auth](https://firebase.google.com/products/auth)
* **AI API:** [OpenRouter](https://openrouter.ai/) (Nvidia Nemotron 120B, LLaMA, Gemma)
* **Форматирование дат:** `intl`
* **Environment Variables:** `flutter_dotenv`
* **HTTP клиент:** `http`
* **Локальное хранилище:** `shared_preferences`
* **Выбор изображений:** `image_picker`
* **Иконки:** `cupertino_icons`

---

## 🤖 AI Провайдеры

### OpenRouter (Рекомендуется)

- **Модель по умолчанию:** Nvidia Nemotron 3 Super 120B
- **Бесплатные альтернативы:** Meta LLaMA, Google Gemma, Mistral
- **Преимущества:** Множество моделей, щедрые лимиты
- **Регистрация:** https://openrouter.ai/keys

### Groq (Fallback)

- **Модель:** LLaMA 3.3 70B
- **Лимит:** 60 запросов/минуту
- **Автоматическое переключение** если OpenRouter недоступен

---

## 📊 Статистика проекта

- ✅ **0 ошибок** анализа кода
- 📁 **30** Dart файлов
- 📝 **~3500+** строк кода
- 🎨 **12** основных экранов
- 🔧 **10** сервисов
- 🤖 **AI-интеграция** с OpenRouter (бесплатно)
- 🌍 **2 языка** (EN/RU)
- 📦 **Версия:** 1.0.3+3

---

## 🔐 Безопасность

- ✅ API ключи в `.env` только для локального скрипта запуска; в Flutter assets `.env` больше не включается
- ⚠️ Для production AI ключи нужно держать на backend/proxy, так как любой клиентский конфиг может быть извлечен из сборки
- ✅ Firebase credentials защищены
- ✅ `.gitignore` настроен правильно
- ✅ Автоматический fallback между AI провайдерами
- ✅ Локальные fallback-рекомендации при недоступности API

---

## 🔄 Автоуведомление об обновлении

Приложение проверяет Firestore-документ `config/app_version` при запуске, на onboarding/login и после входа. Если в Firestore версия или build выше установленной сборки, пользователь увидит окно обновления.

Минимальный документ:

```json
{
  "latestVersion": "1.0.2",
  "latestBuildNumber": 3,
  "downloadUrl": "https://your-domain.com/aria-app-release.apk",
  "releaseNotes": "Исправлена адаптивность и улучшены обновления.",
  "isMandatory": false
}
```

Важно: Android не разрешает тихо установить APK в обход пользователя. Для sideload APK приложение может показать уведомление и открыть ссылку на скачивание; пользователь подтверждает установку сам. Чтобы проверка работала у всех, задеплойте правила Firestore: `firebase deploy --only firestore:rules`.

---

## 📝 Последние обновления (26.04.2026)

### ✨ Добавлено:

- 📊 **Автогенерация презентаций** - добавлен скрипт `presentation/build_deck.mjs` для автоматического создания презентаций с актуальными метриками проекта.
- 📦 **Новые библиотеки** - `package_info_plus` (получение версии) и `url_launcher` (открытие ссылок для авто-обновлений).
- ⚙️ **Структура** - добавлены директории `photo` и `presentation` для медиа-материалов и генерации отчетов.
- 📱 **Экран подписки** - управление Premium подпиской
- 👤 **Редактирование профиля** - изменение имени и аватара
- 📝 **Регистрация** - отдельный экран регистрации
- 🔔 **Уведомления** - сервис для напоминаний о задачах
- 👤 **Профиль пользователя** - модель и сервис профиля
- 🤖 **OpenRouter интеграция** - поддержка множества бесплатных AI моделей
- 🧠 **Nvidia Nemotron 120B** - мощная бесплатная модель по умолчанию
- 💡 **AI-анализ приоритетов** - кнопка "Analyze" при создании задач
- 📝 **Разбивка задач** - AI разделяет сложные задачи на шаги
- 📊 **Инсайты продуктивности** - персонализированные рекомендации
- 📅 **Умное планирование** - оптимальное расписание задач
- 🌍 **Мультиязычность** - поддержка русского и английского
- 🔐 **Безопасность** - AI конфиг передается через `--dart-define`, `.env` не включается в assets

### 🔧 Улучшено:

- ✅ Проверка проекта на баги (0 критических ошибок)
- ✅ Исправлены ошибки с неизменяемыми списками
- ✅ Оптимизирована навигация (5 вкладок с адаптивными размерами)
- ✅ Обновлена документация (ENV_SETUP.md)
- ✅ .gitignore для защиты секретов
- ✅ Fallback система для AI запросов
- ⏱️ **Focus Timer** - таймер для фокусирования

### 🐛 Исправлено:

- ✅ UI overflow в нижней навигации
- ✅ Дублирующиеся ключи в переводах
- ✅ Ошибки доступа к themeModeName
- ✅ Сортировка неизменяемых списков в analytics

---

*Сделано с ❤️ и AI для максимальной продуктивности.*
