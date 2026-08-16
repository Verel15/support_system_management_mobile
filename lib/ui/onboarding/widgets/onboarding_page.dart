import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/onboarding_storage.dart';
import '../../core/theme/brand_colors.dart';
import '../../core/widgets/gradient_button.dart';

class _OnboardingSlide {
  const _OnboardingSlide({required this.visual, required this.title, required this.subtitle});

  final Widget visual;
  final String title;
  final String subtitle;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static final _slides = [
    _OnboardingSlide(
      visual: Image.asset('assets/logo/logo-sms.png', width: 220),
      title: 'Support System',
      subtitle: 'ระบบช่วยเหลือที่พร้อมดูแลคุณ',
    ),
    const _OnboardingSlide(
      visual: _IconBadge(icon: LucideIcons.ticket),
      title: 'แจ้งปัญหาได้ทุกที่',
      subtitle: 'ส่งเรื่องแจ้งปัญหาได้ง่ายๆ ในไม่กี่ขั้นตอน',
    ),
    const _OnboardingSlide(
      visual: _IconBadge(icon: LucideIcons.activity),
      title: 'ติดตามสถานะแบบเรียลไทม์',
      subtitle: 'รู้ความคืบหน้าของเรื่องที่แจ้งได้ตลอดเวลา',
    ),
  ];

  bool get _isLastPage => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BrandColors.backgroundStart, BrandColors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (page) => setState(() => _page = page),
                  children: [for (final slide in _slides) _SlideView(slide: slide)],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? BrandColors.brandEnd : BrandColors.fieldIcon,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
                child: GradientButton(
                  label: _isLastPage ? 'เริ่มต้นใช้งาน' : 'ถัดไป',
                  onPressed: _isLastPage ? _finish : _next,
                ),
              ),
              TextButton(
                onPressed: _finish,
                child: const Text('ข้าม'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    await getIt<OnboardingStorage>().markSeen();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          slide.visual,
          const SizedBox(height: 32),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: BrandColors.navy),
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: BrandColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BrandColors.brandStart, BrandColors.brandEnd],
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 44),
    );
  }
}
