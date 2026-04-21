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
*   🤖 **AI Подсказки**: Предиктивные советы для расписания и умные предложения при добавлении новых задач.
*   📊 **Аналитика и статистика**: Отслеживание фокус-времени, завершенных задач и "стриков" (ежедневной активности).
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
| **Add Task Screen** | ✅ AI Suggestions, 6 категорий, date/time picker |
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

## 🚀 Быстрый запуск (Одна команда!)

### Windows
```bash
.\run_mobile.bat
```

### Mac/Linux
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
├── screens/            # Экраны приложения (Home, Tasks, Auth, Onboarding и др.)
├── services/           # Бизнес-логика и API (TaskService для Firestore, AuthService)
├── widgets/            # Переиспользуемые компоненты (AppShell, кастомные карточки)
└── main.dart           # Точка входа в приложение и инициализация Firebase
```

---

## 🛠️ Используемые технологии

*   **Фреймворк:** [Flutter](https://flutter.dev/)
*   **Язык:** [Dart](https://dart.dev/)
*   **База Данных:** [Cloud Firestore](https://firebase.google.com/products/firestore) (`cloud_firestore`)
*   **Аутентификация:** [Firebase Auth](https://firebase.google.com/products/auth) (`firebase_auth`)
*   **Форматирование дат:** `intl`

---

*Сделано с ❤️ для максимальной продуктивности.*
