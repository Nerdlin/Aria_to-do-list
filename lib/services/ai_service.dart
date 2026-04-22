import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'task_service.dart';

class AiService {
  // OpenRouter API (supports multiple free models)
  static const String _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // Fallback to Groq if OpenRouter key not available
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  String get _apiKey {
    final openRouterKey = dotenv.env['OPENROUTER_API_KEY'];
    if (openRouterKey != null && openRouterKey.isNotEmpty && openRouterKey != 'your_openrouter_api_key_here') {
      return openRouterKey;
    }
    return dotenv.env['GROQ_API_KEY'] ?? 'demo_key';
  }

  String get _apiUrl {
    final openRouterKey = dotenv.env['OPENROUTER_API_KEY'];
    if (openRouterKey != null && openRouterKey.isNotEmpty && openRouterKey != 'your_openrouter_api_key_here') {
      return _openRouterUrl;
    }
    return _groqUrl;
  }

  String get _model {
    final customModel = dotenv.env['AI_MODEL'];
    if (customModel != null && customModel.isNotEmpty) {
      return customModel;
    }
    // Default models based on API
    return _apiUrl == _openRouterUrl
        ? 'nvidia/nemotron-3-super-120b-a12b:free'
        : 'llama-3.3-70b-versatile';
  }

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

Provide a brief analysis (2-3 sentences) on:
1. Recommended priority (High/Medium/Low)
2. Why this priority is suggested
3. One actionable tip for completing it efficiently
''';

      final response = await _makeRequest(prompt);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('AI analysis error: $e');
      }
      return _getFallbackPriorityAnalysis(title, category, dueDate);
    }
  }

  Future<String> suggestTaskBreakdown(String taskTitle) async {
    try {
      final prompt = '''
Break down this task into 3-5 actionable subtasks:
Task: $taskTitle

Provide a numbered list of concrete steps to complete this task.
Keep each step clear and actionable.
''';

      final response = await _makeRequest(prompt);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('AI breakdown error: $e');
      }
      return _getFallbackBreakdown(taskTitle);
    }
  }

  Future<String> generateProductivityInsights(List<TaskItem> tasks) async {
    if (tasks.isEmpty) {
      return 'Add some tasks to get personalized insights!';
    }

    try {
      final completed = tasks.where((t) => t.isCompleted).length;
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

Provide brief, motivating insights about:
1. Productivity patterns
2. Areas for improvement
3. One specific recommendation
''';

      final response = await _makeRequest(prompt);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('AI insights error: $e');
      }
      return _getFallbackInsights(tasks);
    }
  }

  Future<String> suggestOptimalSchedule(List<TaskItem> pendingTasks) async {
    if (pendingTasks.isEmpty) {
      return 'No pending tasks to schedule!';
    }

    try {
      final taskList = pendingTasks.take(5).map((t) =>
        '- ${t.title} (${t.priority}, ${t.durationMinutes}min, ${t.category})'
      ).join('\n');

      final prompt = '''
Suggest an optimal order to complete these tasks:
$taskList

Consider priority, duration, and energy levels throughout the day.
Provide a brief schedule recommendation with reasoning.
''';

      final response = await _makeRequest(prompt);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('AI schedule error: $e');
      }
      return _getFallbackSchedule(pendingTasks);
    }
  }

  Future<String> _makeRequest(String prompt) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    // Add OpenRouter-specific headers
    if (_apiUrl == _openRouterUrl) {
      headers['HTTP-Referer'] = 'https://github.com/aria-app';
      headers['X-Title'] = 'Aria Productivity App';
    }

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: headers,
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a productivity assistant. Provide concise, actionable advice.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 300,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('API request failed: ${response.statusCode}');
    }
  }

  String _getFallbackPriorityAnalysis(String title, String category, DateTime dueDate) {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;

    if (daysUntilDue <= 1) {
      return 'Priority: High\n\nThis task is due soon. Focus on completing it today to avoid last-minute stress. Break it into smaller steps if needed.';
    } else if (category == 'Work' || category == 'Finance') {
      return 'Priority: High\n\n$category tasks often have important consequences. Schedule dedicated time for this task and minimize distractions.';
    } else if (daysUntilDue <= 3) {
      return 'Priority: Medium\n\nYou have a few days, but don\'t delay. Set a specific time slot to work on this task.';
    } else {
      return 'Priority: Medium\n\nYou have time to plan this well. Consider breaking it into smaller milestones for better progress tracking.';
    }
  }

  String _getFallbackBreakdown(String taskTitle) {
    return '''
1. Define the specific goal and success criteria
2. Gather necessary resources and information
3. Create a step-by-step action plan
4. Execute the main work in focused sessions
5. Review and refine the results
''';
  }

  String _getFallbackInsights(List<TaskItem> tasks) {
    final completed = tasks.where((t) => t.isCompleted).length;
    final completionRate = (completed / tasks.length * 100).round();

    return '''
Your completion rate is $completionRate%. ${completionRate >= 70 ? 'Great work!' : 'You can improve!'}

Focus on completing high-priority tasks first. Break large tasks into smaller, manageable chunks. Set specific time blocks for deep work.
''';
  }

  String _getFallbackSchedule(List<TaskItem> pendingTasks) {
    final highPriority = pendingTasks.where((t) => t.priority == 'High').toList();

    if (highPriority.isNotEmpty) {
      return '''
Start with high-priority tasks: ${highPriority.first.title}

Schedule demanding tasks during your peak energy hours (usually morning). Group similar tasks together to maintain focus. Take breaks between different task types.
''';
    }

    return '''
Begin with the task that has the nearest deadline. Schedule demanding work during your peak energy hours. Group similar tasks to maintain momentum.
''';
  }
}
