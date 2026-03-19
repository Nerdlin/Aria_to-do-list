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

## 📸 Экраны приложения

| Описание | Экран |
| :---: | :---: |
| **Главный экран (Home)** | Приветствие, AI-инсайты, расписание дня и красивая плавающая кнопка. |
| **Мои задачи (Tasks)** | Список задач с фильтрами, приоритетами и возможностью отмечать выполненное. |
| **Новая задача (Add Task)** | Умное добавление задачи с AI-предложениями и выбором категорий. |
| **Статистика (Analytics)** | Просмотр еженедельной оценки эффективности и выполненных дел. |
| **Настройки (Settings)** | Настройка уведомлений, умных напоминаний и управление аккаунтом. |

---

## 🚀 Установка и запуск

Для запуска приложения на вашем локальном устройстве или эмуляторе, выполните следующие шаги:

### 1. Предварительные требования
Убедитесь, что у вас установлены:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (версия >= 3.0.0)
*   [Android Studio](https://developer.android.com/studio) или VS Code

### 2. Клонирование репозитория
```bash
git clone https://github.com/your-username/aria_flutter_app.git
cd aria_flutter_app
```

### 3. Установка зависимостей
```bash
flutter pub get
```

### 4. Настройка Firebase
Приложение использует Firebase. Убедитесь, что вы создали проект в [Firebase Console](https://console.firebase.google.com/):
1. Включите **Authentication** (Email/Password).
2. Включите **Firestore Database** (создайте базу данных в *Test Mode*).
3. Скачайте файл `google-services.json` для Android и положите его в папку `android/app/`.

### 5. Запуск
```bash
flutter run
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
