# 🌟 Aria Productivity App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) 
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black) 
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**Aria** — это современное и элегантное приложение для управления задачами и повышения продуктивности, созданное на Flutter. Дизайн вдохновлён мягким неоморфизмом (Glassmorphism-lite), предлагая пользователю плавный и интуитивно понятный интерфейс с умными AI-подсказками и статистикой.

---

## ✨ Ключевые возможности

*   🔐 **Безопасная аутентификация**: Интеграция с **Firebase Authentication** (Вход и регистрация по Email/Паролю).
*   ☁️ **Облачная синхронизация**: Все задачи сохраняются и синхронизируются в реальном времени с помощью **Google Cloud Firestore**.
*   🎨 **Pixel-Perfect UI**: Исключительно красивый интерфейс, вдохновленный передовыми макетами из Figma (Плавные градиенты, карточки, закругления).
*   🤖 **AI Помощник**: Интеграция с OpenRouter API (Nvidia Nemotron 120B) для умных рекомендаций и анализа задач.
*   💡 **AI Анализ приоритетов**: Автоматические рекомендации по приоритизации задач с учетом контекста.
*   📝 **Разбивка задач**: AI помогает разделить сложные задачи на простые выполнимые шаги.
*   📊 **Аналитика и статистика**: Отслеживание фокус-времени, завершенных задач и "стриков" (ежедневной активности).
*   🌍 **Мультиязычность**: Поддержка английского и русского языков.
*   🔐 **Безопасность**: API ключи хранятся в .env файле и не попадают в Git.
*   📱 **Кроссплатформенность**: Готово к запуску на Android и iOS из единой кодовой базы.

---

## 📸 Экраны приложения (из Figma Make)

| Экран | Реализовано |
| :---: | :---: |
| **Splash Screen** | ✅ Градиент, автонавигация |
| **Onboarding (3 слайда)** | ✅ Анимации, Smart Planning, Priority Intelligence, Time Optimization |
| **Auth Screen** | ✅ Firebase Auth, красивые формы |
| **Home Screen** | ✅ AI Insight, Quick Stats, Schedule, Priority Tasks, Weekly Progress, Focus Timer |
| **Tasks Screen** | ✅ Поиск, фильтры (All/Today/High/AI Pick), toggle completion, delete |
| **Add Task Screen** | ✅ AI Suggestions, AI Priority Analysis, 6 категорий, date/time picker |
| **AI Assistant Screen** | ✅ Productivity Insights, Smart Scheduling, Task Breakdown, Quick Actions |
| **Analytics Screen** | ✅ Score Ring с анимацией, 4 stat cards, Weekly Chart, Category Breakdown, Achievements |
| **Settings Screen** | ✅ Profile card, AI Features, Notifications, Appearance, Account, Sign Out |

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

# Получите бесплатный API ключ на https://openrouter.ai/keys
# Откройте .env и добавьте ваш ключ:
OPENROUTER_API_KEY=sk-or-v1-ваш_ключ_здесь
AI_MODEL=nvidia/nemotron-3-super-120b-a12b:free
```

**Рекомендуемые бесплатные модели:**
- `nvidia/nemotron-3-super-120b-a12b:free` (120B параметров, очень умная)
- `meta-llama/llama-3.2-3b-instruct:free` (быстрая)
- `google/gemma-2-9b-it:free` (сбалансированная)

Подробнее: [ENV_SETUP.md](ENV_SETUP.md)

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
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (версия >= 3.41.7)
*   [Android Studio](https://developer.android.com/studio) (для Android SDK и эмуляторов)

### 2. Установка зависимостей
```bash
flutter pub get
```

### 3. Настройка Firebase
Файл `google-services.json` уже настроен в `android/app/`. 

Если нужно использовать свой Firebase проект:
1. Создайте проект в [Firebase Console](https://console.firebase.google.com/)
2. Включите **Authentication** (Email/Password)
3. Включите **Firestore Database** (Test Mode)
4. Скачайте `google-services.json` и замените в `android/app/`

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
│   ├── home_screen.dart
│   ├── tasks_screen.dart
│   ├── ai_assistant_screen.dart    # 🤖 AI-помощник
│   ├── analytics_screen.dart
│   ├── settings_screen.dart
│   └── add_task_screen.dart
├── services/           # Бизнес-логика и API
│   ├── ai_service.dart             # 🤖 OpenRouter API интеграция
│   ├── task_service.dart           # Firestore задачи
│   ├── auth_service.dart           # Firebase Auth
│   └── task_metrics.dart           # Аналитика
├── widgets/            # Переиспользуемые компоненты
│   └── app_shell.dart              # Навигация (5 вкладок)
├── utils/              # Утилиты
│   └── translations.dart           # Мультиязычность (EN/RU)
└── main.dart           # Точка входа
```

---

## 🛠️ Используемые технологии

*   **Фреймворк:** [Flutter](https://flutter.dev/) 3.41.7
*   **Язык:** [Dart](https://dart.dev/)
*   **База Данных:** [Cloud Firestore](https://firebase.google.com/products/firestore)
*   **Аутентификация:** [Firebase Auth](https://firebase.google.com/products/auth)
*   **AI API:** [OpenRouter](https://openrouter.ai/) (Nvidia Nemotron 120B, LLaMA, Gemma)
*   **Форматирование дат:** `intl`
*   **Environment Variables:** `flutter_dotenv`
*   **HTTP клиент:** `http`

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
- 📁 **22** Dart файлов
- 📝 **~2000+** строк кода
- 🎨 **8** основных экранов
- 🔧 **7** сервисов
- 🤖 **AI-интеграция** с OpenRouter (бесплатно)
- 🌍 **2 языка** (EN/RU)

---

## 🔐 Безопасность

- ✅ API ключи в `.env` (не коммитятся в Git)
- ✅ Firebase credentials защищены
- ✅ `.gitignore` настроен правильно
- ✅ Автоматический fallback между AI провайдерами
- ✅ Локальные fallback-рекомендации при недоступности API

---

## 📝 Последние обновления (2026-04-22)

### ✨ Добавлено:
- 🤖 **OpenRouter интеграция** - поддержка множества бесплатных AI моделей
- 🧠 **Nvidia Nemotron 120B** - мощная бесплатная модель по умолчанию
- 💡 **AI-анализ приоритетов** - кнопка "Analyze" при создании задач
- 📝 **Разбивка задач** - AI разделяет сложные задачи на шаги
- 📊 **Инсайты продуктивности** - персонализированные рекомендации
- 📅 **Умное планирование** - оптимальное расписание задач
- 🌍 **Мультиязычность** - поддержка русского и английского
- 🔐 **Безопасность** - API ключи вынесены в .env

### 🔧 Улучшено:
- ✅ Проверка проекта на баги (0 критических ошибок)
- ✅ Исправлены ошибки с неизменяемыми списками
- ✅ Оптимизирована навигация (5 вкладок с адаптивными размерами)
- ✅ Обновлена документация (ENV_SETUP.md)
- ✅ .gitignore для защиты секретов
- ✅ Fallback система для AI запросов

### 🐛 Исправлено:
- ✅ UI overflow в нижней навигации
- ✅ Дублирующиеся ключи в переводах
- ✅ Ошибки доступа к themeModeName
- ✅ Сортировка неизменяемых списков в analytics

---

*Сделано с ❤️ и AI для максимальной продуктивности.*
