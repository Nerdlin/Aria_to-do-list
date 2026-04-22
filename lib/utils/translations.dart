import '../services/app_controller.dart';

String tr(String text, {Map<String, String>? namedArgs}) {
  final lang = AppController.instance.profile?.languageCode ?? 'en';
  String result = text;
  if (lang == 'ru') {
    result = _ru[text] ?? text;
  }
  
  if (namedArgs != null) {
    namedArgs.forEach((key, value) {
      result = result.replaceAll('{}', value); // simple replacement
    });
  }
  return result;
}

const _ru = {
  // Navigation
  'Home': 'Главная',
  'Tasks': 'Задачи',
  'AI': 'ИИ',
  'Stats': 'Статистика',
  'Settings': 'Настройки',

  // Add Task Screen
  'New Task': 'Новая задача',
  'Save': 'Сохранить',
  'Task Details': 'Детали задачи',
  'Task title': 'Название задачи',
  'Notes (optional)': 'Заметки (необязательно)',
  'AI Suggestions': 'AI Рекомендации',
  'Category': 'Категория',
  'Work': 'Работа',
  'Personal': 'Личное',
  'Health': 'Здоровье',
  'Clean up task backlog': 'Разобрать старые задачи',
  'Read 20 pages of your course': 'Прочитать 20 страниц курса',
  'Refine onboarding checklist': 'Улучшить чеклист онбординга',
  'Please enter a title': 'Пожалуйста, введите название',
  
  // Tasks Screen
  'My Tasks': 'Мои задачи',
  'Search tasks...': 'Поиск задач...',
  'All': 'Все',
  'No tasks today. Add some!': 'На сегодня задач нет. Добавьте новые!',
  'Try another filter or create a new task from the center button.': 'Попробуйте другой фильтр или создайте новую задачу.',
  
  // Home Screen
  'Good morning,': 'Доброе утро,',
  'Good afternoon,': 'Добрый день,',
  'Good evening,': 'Добрый вечер,',
  'AI Assistant': 'AI Ассистент',
  'Analyze your tasks to optimize your day': 'Анализ задач для оптимизации дня',
  'Get Insights': 'Получить инсайты',
  'Weekly Progress': 'Прогресс за неделю',
  'Tasks completed': 'Задач выполнено',
  'Productivity Score': 'Оценка продуктивности',
  'Excellent': 'Отлично',
  'Today\'s Schedule': 'Расписание на сегодня',
  'See All': 'Все',
  
  // Settings Screen
  'Profile': 'Профиль',
  'Edit Profile': 'Редактировать профиль',
  'Preferences': 'Настройки',
  'Theme': 'Тема',
  'Language': 'Язык',
  'Light': 'Светлая',
  'Dark': 'Темная',
  'System': 'Системная',
  'English': 'Английский',
  'Russian': 'Русский',
  'Sign Out': 'Выйти',
  'Features': 'Функции',
  'AI Auto-Planning': 'AI Авто-планирование',
  'Smart Prioritization': 'Умная приоритизация',
  'Smart Reminders': 'Умные напоминания',
  'Focus Mode': 'Режим фокусировки',
  'Notifications': 'Уведомления',
  'Push Notifications': 'Push-уведомления',
  'Daily Digest': 'Ежедневная сводка',
  'Weekly Report': 'Еженедельный отчет',
  'Choose theme': 'Выберите тему',
  'Choose language': 'Выберите язык',
  'Current UI language': 'Текущий язык интерфейса',

  // Misc / Other
  'Get smart insights and recommendations': 'Умные инсайты и рекомендации',
  'Insights': 'Инсайты',
  'Schedule': 'Расписание',
  'Breakdown': 'Структура',
  'Quick Actions': 'Быстрые действия',
  'Analyze My Productivity': 'Проанализировать мою продуктивность',
  'Suggest Optimal Schedule': 'Предложить оптимальное расписание',

  // Extras
  'Analyze': 'Анализ',
  'Low': 'Низкий',
  'Medium': 'Средний',
  'High': 'Высокий',
  'min': 'мин',
  'Estimated focus time': 'Примерное время фокуса',
  'Mark as AI recommended': 'Отметить как рекомендовано ИИ',
  'Helps Home and Analytics highlight this task.': 'Помогает выделить задачу на главной',
  'Task added successfully!': 'Задача успешно добавлена!',
  'Today': 'Сегодня',
  'High Priority': 'Высокий приоритет',
  'AI Pick': 'Выбор ИИ',
  'Completed': 'Завершено',
  'Smart queue': 'Умная очередь',
  'Tap a task to mark it done. Delete the ones you no longer need.': 'Нажмите на задачу для выполнения. Удалите те, что больше не нужны.',
  'No tasks match the selected filter.': 'Нет задач, подходящих под фильтр.',

  // Settings
  'APPEARANCE': 'ВНЕШНИЙ ВИД',
  'ACCOUNT': 'АККАУНТ',
  'AI FEATURES': 'ФУНКЦИИ ИИ',
  'NOTIFICATIONS': 'УВЕДОМЛЕНИЯ',
  'Let Aria suggest your next move': 'Пусть Aria предложит ваш следующий шаг',
  'Rank tasks by impact and urgency': 'Ранжируйте задачи по важности и срочности',
  'Keep nudges useful instead of noisy': 'Делаем напоминания полезными, а не шумными',
  'Protect deep work sessions': 'Защитите сессии глубокой работы',
  'AI Focus Mode': 'AI Режим фокуса',
  'Task reminders and quick updates': 'Напоминания о задачах и быстрые обновления',
  'Morning summary of your day': 'Утренняя сводка вашего дня',
  'Progress snapshot every week': 'Еженедельный срез прогресса',
  'Profile & Account': 'Профиль и аккаунт',
  'Update your name, photo, and email': 'Обновите имя, фото и email',
  'Privacy & Security': 'Конфиденциальность и безопасность',
  'Password reset and account safety': 'Сброс пароля и защита аккаунта',
  'Subscription': 'Подписка',
  'Help & Support': 'Помощь и поддержка',
  'FAQ, support email, and feedback': 'FAQ, почта поддержки и отзывы',
  'Signed in as {}': 'Вы вошли как {}',
  'unknown email': 'неизвестный email',
  'Send password reset email': 'Отправить письмо для сброса пароля',
  'Password reset email sent to {}': 'Письмо для сброса отправлено на {}',
  'Your personal data and task collection are scoped to your account in Firestore.': 'Ваши личные данные и задачи привязаны только к вашему аккаунту в Firestore.',
  'Aria Pro is currently represented as an in-app profile tier. Billing is not wired to a payment provider in this project yet, but the settings page now opens plan details instead of doing nothing.': 'Aria Pro пока что представляет собой локальный статус аккаунта. Биллинг еще не подключен.',
  'FAQ': 'Частые вопросы',
  'Tap profile photo to edit your account. Tap tasks to complete them.': 'Нажмите на фото, чтобы изменить профиль. Нажмите на задачу, чтобы выполнить её.',
  'Support email': 'Почта поддержки',
  'Copy': 'Копировать',
  'Support email copied.': 'Почта поддержки скопирована.',
  'Feedback': 'Отзывы',
  'Use your task notes or profile editor to capture feedback for now.': 'Пока можете использовать заметки задач для записи отзывов.',
  '{} Plan': 'План {}',
  '{}-day streak': '{} дней подряд',
  'Aria User': 'Пользователь Aria',
  'No email available': 'Нет email',
  '{} plan details': 'детали плана {}',
};
