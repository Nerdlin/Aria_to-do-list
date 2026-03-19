import 'package:flutter/material.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TaskService _taskService = TaskService();
  String _selectedCategory = 'Work';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.work_rounded, 'label': 'Work', 'color': const Color(0xFF7B61FF)},
    {'icon': Icons.person_rounded, 'label': 'Personal', 'color': const Color(0xFF3B82F6)},
    {'icon': Icons.fitness_center_rounded, 'label': 'Health', 'color': const Color(0xFFF59E0B)},
    {'icon': Icons.menu_book_rounded, 'label': 'Learning', 'color': const Color(0xFF10B981)},
    {'icon': Icons.attach_money_rounded, 'label': 'Finance', 'color': const Color(0xFFEF4444)},
    {'icon': Icons.palette_rounded, 'label': 'Creative', 'color': const Color(0xFFEC4899)},
  ];

  void _saveTask() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    await _taskService.addTask(
      title: _titleController.text.trim(),
      priority: 'High', // Defaulting to high for MVP
      category: _selectedCategory,
      date: DateTime.now(),
      isAiPick: true,
    );
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _useSuggestion(String suggestion) {
    _titleController.text = suggestion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A2E), size: 24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Task', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            Text('AI will prioritize automatically', style: TextStyle(color: const Color(0xFF6B7280).withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          _isLoading
              ? const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))))
              : TextButton(
                  onPressed: _saveTask,
                  child: const Text('Save', style: TextStyle(color: Color(0xFF7B61FF), fontSize: 16, fontWeight: FontWeight.w700)),
                )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF3F4F6).withOpacity(0.8), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFF7B61FF).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFF7B61FF), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Text('TASK TITLE', style: TextStyle(color: Color(0xFF7B61FF), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'What do you need to accomplish today?',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 20, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF3F4F6).withOpacity(0.8), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: Color(0xFF7B61FF), size: 20),
                          SizedBox(width: 10),
                          Text('AI Suggestions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                        ],
                      ),
                      Icon(Icons.refresh_rounded, color: const Color(0xFF9CA3AF).withOpacity(0.8)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildAiSuggestion('Review Q4 marketing report'),
                  _buildAiSuggestion('Schedule 1:1 with design team'),
                  _buildAiSuggestion('Update roadmap for next sprint'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF3F4F6).withOpacity(0.8), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CATEGORY', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    itemCount: _categories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return _buildCategoryBtn(cat['icon'], cat['label'], cat['color'], _selectedCategory == cat['label']);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildAiSuggestion(String text) {
    return InkWell(
      onTap: () => _useSuggestion(text),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: const Color(0xFF7B61FF).withOpacity(0.6), shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)))),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBtn(IconData icon, String label, Color color, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: color.withOpacity(0.3), width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? color : const Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
