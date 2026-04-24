import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'app_controller.dart';
import 'task_service.dart';

class AiService {
  static const String _openRouterUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  String get _apiKey {
    final genericKey = dotenv.env['AI_API_KEY'];
    if (_isUsableKey(genericKey)) {
      return genericKey!.trim();
    }

    final omniRouteKey = dotenv.env['OMNIROUTE_API_KEY'];
    if (_isUsableKey(omniRouteKey)) {
      return omniRouteKey!.trim();
    }

    final openRouterKey = dotenv.env['OPENROUTER_API_KEY'];
    if (_isUsableKey(openRouterKey)) {
      return openRouterKey!.trim();
    }

    final groqKey = dotenv.env['GROQ_API_KEY'];
    if (_isUsableKey(groqKey)) {
      return groqKey!.trim();
    }

    return '';
  }

  String get _apiUrl {
    final customBaseUrl =
        dotenv.env['AI_BASE_URL'] ?? dotenv.env['OMNIROUTE_BASE_URL'];
    if (customBaseUrl != null && customBaseUrl.trim().isNotEmpty) {
      return _completionEndpoint(customBaseUrl);
    }

    if (_isUsableKey(dotenv.env['OPENROUTER_API_KEY'])) {
      return _openRouterUrl;
    }

    return _groqUrl;
  }

  String get _model {
    final customModel = dotenv.env['AI_MODEL'];
    if (customModel != null && customModel.trim().isNotEmpty) {
      return customModel.trim();
    }

    if (_apiUrl.contains('localhost:20128') ||
        _apiUrl.contains('127.0.0.1:20128')) {
      return 'kr/claude-sonnet-4.5';
    }

    return _apiUrl == _openRouterUrl
        ? 'nvidia/nemotron-3-super-120b-a12b:free'
        : 'llama-3.3-70b-versatile';
  }

  bool get _isRussian => AppController.instance.languageCode == 'ru';

  String get _responseLanguage => _isRussian ? 'Russian' : 'English';

  Future<String> analyzeTaskPriority({
    required String title,
    required String category,
    required DateTime dueDate,
    String? note,
  }) async {
    try {
      final prompt = '''
Analyze this task and provide priority recommendation:
Title: $title
Category: $category
Due Date: ${dueDate.toIso8601String()}
${note != null && note.isNotEmpty ? 'Note: $note' : ''}

Respond in $_responseLanguage.
Provide a brief analysis on:
1. Recommended priority (High/Medium/Low)
2. Why this priority is suggested
3. One actionable tip for completing it efficiently
''';

      return await _makeRequest(prompt);
    } catch (error) {
      if (kDebugMode) {
        print('AI analysis error: $error');
      }
      return _getFallbackPriorityAnalysis(title, category, dueDate);
    }
  }

  Future<String> suggestTaskBreakdown(String taskTitle) async {
    try {
      final prompt = '''
Break down this task into 3-5 actionable subtasks:
Task: $taskTitle

Respond in $_responseLanguage.
Provide a numbered list of concrete steps to complete this task.
Keep each step clear and actionable.
''';

      return await _makeRequest(prompt);
    } catch (error) {
      if (kDebugMode) {
        print('AI breakdown error: $error');
      }
      return _getFallbackBreakdown(taskTitle);
    }
  }

  Future<String> generateProductivityInsights(List<TaskItem> tasks) async {
    if (tasks.isEmpty) {
      return _isRussian
          ? 'Добавьте несколько задач, чтобы получить персональные инсайты.'
          : 'Add some tasks to get personalized insights!';
    }

    try {
      final completed = tasks.where((task) => task.isCompleted).length;
      final pending = tasks.length - completed;
      final categories = <String>{};
      for (final task in tasks) {
        categories.add(task.category);
      }

      final prompt = '''
Analyze this productivity data and provide 3 actionable insights:
- Total tasks: ${tasks.length}
- Completed: $completed
- Pending: $pending
- Categories: ${categories.join(', ')}

Respond in $_responseLanguage.
Provide brief, motivating insights about:
1. Productivity patterns
2. Areas for improvement
3. One specific recommendation
''';

      return await _makeRequest(prompt);
    } catch (error) {
      if (kDebugMode) {
        print('AI insights error: $error');
      }
      return _getFallbackInsights(tasks);
    }
  }

  Future<String> suggestOptimalSchedule(List<TaskItem> pendingTasks) async {
    if (pendingTasks.isEmpty) {
      return _isRussian
          ? 'Нет активных задач для планирования.'
          : 'No pending tasks to schedule!';
    }

    try {
      final taskList = pendingTasks
          .take(5)
          .map(
            (task) =>
                '- ${task.title} (${task.priority}, ${task.durationMinutes}min, ${task.category})',
          )
          .join('\n');

      final prompt = '''
Suggest an optimal order to complete these tasks:
$taskList

Respond in $_responseLanguage.
Consider priority, duration, and energy levels throughout the day.
Provide a brief schedule recommendation with reasoning.
''';

      return await _makeRequest(prompt);
    } catch (error) {
      if (kDebugMode) {
        print('AI schedule error: $error');
      }
      return _getFallbackSchedule(pendingTasks);
    }
  }

  Future<String> _makeRequest(String prompt) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final apiKey = _apiKey;
    if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    if (_apiUrl.contains('openrouter.ai')) {
      headers['HTTP-Referer'] = 'https://github.com/aria-app';
      headers['X-Title'] = 'Aria Productivity App';
    }

    final response = await http
        .post(
          Uri.parse(_apiUrl),
          headers: headers,
          body: jsonEncode({
            'model': _model,
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are a productivity assistant. Provide concise, actionable advice. Respond in $_responseLanguage.',
              },
              {
                'role': 'user',
                'content': prompt,
              },
            ],
            'temperature': 0.7,
            'max_tokens': 300,
            'stream': false,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return _extractAssistantText(response.body);
    }

    throw Exception(
      'API request failed: ${response.statusCode} ${_shortBody(response.body)}',
    );
  }

  String _extractAssistantText(String body) {
    final trimmed = body.trim();
    if (trimmed.startsWith('data:') || trimmed.contains('\ndata:')) {
      return _extractServerSentEvents(trimmed);
    }

    final data = jsonDecode(trimmed) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>? ?? const [];
    if (choices.isEmpty) {
      throw const FormatException('AI response has no choices');
    }

    final choice = choices.first as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>?;
    final content = message?['content'];
    if (content is String && content.trim().isNotEmpty) {
      return content.trim();
    }

    final text = choice['text'];
    if (text is String && text.trim().isNotEmpty) {
      return text.trim();
    }

    throw const FormatException('AI response has no text content');
  }

  String _extractServerSentEvents(String body) {
    final buffer = StringBuffer();

    for (final rawLine in const LineSplitter().convert(body)) {
      final line = rawLine.trim();
      if (!line.startsWith('data:')) {
        continue;
      }

      final payload = line.substring(5).trim();
      if (payload.isEmpty || payload == '[DONE]') {
        continue;
      }

      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>? ?? const [];
        if (choices.isEmpty) {
          continue;
        }

        final choice = choices.first as Map<String, dynamic>;
        final delta = choice['delta'] as Map<String, dynamic>?;
        final deltaContent = delta?['content'];
        if (deltaContent is String) {
          buffer.write(deltaContent);
          continue;
        }

        final message = choice['message'] as Map<String, dynamic>?;
        final messageContent = message?['content'];
        if (messageContent is String) {
          buffer.write(messageContent);
        }
      } catch (_) {
        continue;
      }
    }

    final text = buffer.toString().trim();
    if (text.isEmpty) {
      throw const FormatException('Streaming AI response has no text content');
    }
    return text;
  }

  String _completionEndpoint(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/chat/completions')) {
      return trimmed;
    }

    final withoutTrailingSlash = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;

    if (withoutTrailingSlash.endsWith('/v1')) {
      return '$withoutTrailingSlash/chat/completions';
    }

    return '$withoutTrailingSlash/v1/chat/completions';
  }

  bool _isUsableKey(String? value) {
    if (value == null) {
      return false;
    }

    final trimmed = value.trim();
    return trimmed.isNotEmpty &&
        trimmed != 'demo_key' &&
        trimmed != 'your_openrouter_api_key_here';
  }

  String _shortBody(String body) {
    if (body.length <= 240) {
      return body;
    }
    return '${body.substring(0, 240)}...';
  }

  String _getFallbackPriorityAnalysis(
    String title,
    String category,
    DateTime dueDate,
  ) {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;

    if (_isRussian) {
      if (daysUntilDue <= 1) {
        return 'Приоритет: высокий\n\nСрок уже близко. Лучше закрыть задачу сегодня и при необходимости разбить ее на шаги.';
      } else if (category == 'Work' || category == 'Finance') {
        return 'Приоритет: высокий\n\nЗадачи из категории "$category" часто имеют заметные последствия. Забронируйте отдельный слот без отвлечений.';
      } else if (daysUntilDue <= 3) {
        return 'Приоритет: средний\n\nВремя еще есть, но откладывать не стоит. Назначьте конкретный слот для выполнения.';
      }
      return 'Приоритет: средний\n\nЗадачу можно спокойно спланировать. Разбейте ее на небольшие этапы, чтобы легче отслеживать прогресс.';
    }

    if (daysUntilDue <= 1) {
      return 'Priority: High\n\nThis task is due soon. Focus on completing it today to avoid last-minute stress. Break it into smaller steps if needed.';
    } else if (category == 'Work' || category == 'Finance') {
      return 'Priority: High\n\n$category tasks often have important consequences. Schedule dedicated time for this task and minimize distractions.';
    } else if (daysUntilDue <= 3) {
      return 'Priority: Medium\n\nYou have a few days, but do not delay. Set a specific time slot to work on this task.';
    }

    return 'Priority: Medium\n\nYou have time to plan this well. Consider breaking it into smaller milestones for better progress tracking.';
  }

  String _getFallbackBreakdown(String taskTitle) {
    if (_isRussian) {
      return '''
1. Сформулируйте конкретный результат для задачи "$taskTitle"
2. Соберите нужные материалы и входные данные
3. Разбейте работу на короткие фокус-сессии
4. Выполните главный блок работы без отвлечений
5. Проверьте результат и доведите детали
''';
    }

    return '''
1. Define the specific goal and success criteria
2. Gather necessary resources and information
3. Create a step-by-step action plan
4. Execute the main work in focused sessions
5. Review and refine the results
''';
  }

  String _getFallbackInsights(List<TaskItem> tasks) {
    final completed = tasks.where((task) => task.isCompleted).length;
    final completionRate = (completed / tasks.length * 100).round();

    if (_isRussian) {
      return '''
Ваш процент выполнения: $completionRate%. ${completionRate >= 70 ? 'Отличный темп.' : 'Есть пространство для улучшения.'}

Сначала закрывайте задачи с высоким приоритетом. Большие задачи разбивайте на короткие шаги и выделяйте отдельные блоки для глубокой работы.
''';
    }

    return '''
Your completion rate is $completionRate%. ${completionRate >= 70 ? 'Great work!' : 'You can improve!'}

Focus on completing high-priority tasks first. Break large tasks into smaller, manageable chunks. Set specific time blocks for deep work.
''';
  }

  String _getFallbackSchedule(List<TaskItem> pendingTasks) {
    final highPriority =
        pendingTasks.where((task) => task.priority == 'High').toList();

    if (_isRussian) {
      if (highPriority.isNotEmpty) {
        return '''
Начните с задачи высокого приоритета: ${highPriority.first.title}

Ставьте самые сложные задачи на часы максимальной энергии, обычно утром. Похожие задачи группируйте вместе и делайте короткие паузы между блоками.
''';
      }

      return '''
Начните с задачи с ближайшим сроком. Сложную работу ставьте на часы максимальной энергии, а похожие задачи объединяйте в один блок.
''';
    }

    if (highPriority.isNotEmpty) {
      return '''
Start with high-priority tasks: ${highPriority.first.title}

Schedule demanding tasks during your peak energy hours, usually morning. Group similar tasks together to maintain focus. Take breaks between different task types.
''';
    }

    return '''
Begin with the task that has the nearest deadline. Schedule demanding work during your peak energy hours. Group similar tasks to maintain momentum.
''';
  }
}
