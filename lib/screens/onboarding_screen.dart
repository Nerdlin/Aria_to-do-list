import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'color': const Color(0xFF8B5CF6),
      'bgColor': const Color(0xFFF5F3FF),
      'icon': Icons.psychology_rounded,
      'title': 'Smart Daily Planning',
      'subtitle':
          'Aria analyzes your goals, energy levels, and calendar to craft a perfectly optimized daily plan — automatically.',
      'previewLabel': 'AI PREVIEW',
      'items': [
        {'text': '9:00 AM — Deep Work', 'highlight': true},
        {'text': '11:30 AM — Emails', 'highlight': false},
        {'text': '2:00 PM — Meetings', 'highlight': false},
        {'text': '4:30 PM — Review', 'highlight': false},
      ],
      'chips': ['✦ AI Optimized', '✦ Auto-Schedule'],
    },
    {
      'color': const Color(0xFF3B82F6),
      'bgColor': const Color(0xFFEFF6FF),
      'icon': Icons.bolt_rounded,
      'title': 'Priority Intelligence',
      'subtitle':
          'AI continuously ranks your tasks by impact and deadline so you always focus on what moves the needle most.',
      'previewLabel': 'AI PREVIEW',
      'items': [
        {'text': '🔴 High Impact · Q4 Strategy', 'highlight': true},
        {'text': '🟡 Medium · Team Sync', 'highlight': false},
        {'text': '🟢 Low · Archive emails', 'highlight': false},
      ],
      'chips': ['✦ Smart Ranking', '✦ Auto-Priority'],
    },
    {
      'color': const Color(0xFF10B981),
      'bgColor': const Color(0xFFF0FDF4),
      'icon': Icons.trending_up_rounded,
      'title': 'Time Optimization',
      'subtitle':
          'Aria learns your peak performance patterns and schedules deep work when your brain is firing on all cylinders.',
      'previewLabel': 'AI PREVIEW',
      'items': [
        {'text': 'Peak Focus: 9–11 AM', 'highlight': true},
        {'text': 'Creative: 2–4 PM', 'highlight': false},
        {'text': 'Admin: 4–6 PM', 'highlight': false},
        {'text': '87% Efficiency Score', 'highlight': false},
      ],
      'chips': ['✦ Pattern Learning', '✦ Peak Hours'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentColor = _slides[_currentSlide]['color'] as Color;
    final currentBgColor = _slides[_currentSlide]['bgColor'] as Color;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              currentBgColor.withValues(alpha: 0.6),
              currentBgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
                      style: TextButton.styleFrom(
                        foregroundColor: currentColor.withValues(alpha: 0.8),
                      ),
                      child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _currentSlide = value),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    final color = slide['color'] as Color;
                    final items = slide['items'] as List<Map<String, dynamic>>;
                    final chips = slide['chips'] as List<String>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(slide['icon'] as IconData, size: 36, color: Colors.white),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            slide['title'] as String,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slide['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      slide['previewLabel'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ...items.map((item) {
                                  final bool isHighlighted = item['highlight'] as bool;
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isHighlighted ? color.withValues(alpha: 0.1) : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(16),
                                      border: isHighlighted ? Border.all(color: color.withValues(alpha: 0.2)) : null,
                                    ),
                                    child: Text(
                                      item['text'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                                        color: isHighlighted ? color.withValues(alpha: 0.9) : const Color(0xFF4B5563),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: chips.map((chipText) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  chipText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(_slides.length, (index) {
                        final bool active = index == _currentSlide;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? currentColor : currentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                    InkWell(
                      onTap: () {
                        if (_currentSlide < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          Navigator.pushReplacementNamed(context, '/auth');
                        }
                      },
                      borderRadius: BorderRadius.circular(99),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: currentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: currentColor.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

