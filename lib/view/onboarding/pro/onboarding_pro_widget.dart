import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:quizzy_design/quizzy_design.dart';

class OnboardingProWidget extends HookWidget {
  const OnboardingProWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final pageController = usePageController();
    final currentPage = useState(0);

    final pages = [
      (
        illustrationAsset: 'assets/images/quizzy-01-generate.svg',
        title: l10n.onboardingProPage1Title,
        description: l10n.onboardingProPage1Description,
      ),
      (
        illustrationAsset: 'assets/images/quizzy-02-validate.svg',
        title: l10n.onboardingProPage2Title,
        description: l10n.onboardingProPage2Description,
      ),
      (
        illustrationAsset: 'assets/images/quizzy-03-sync.svg',
        title: l10n.onboardingProPage3Title,
        description: l10n.onboardingProPage3Description,
      ),
      (
        illustrationAsset: 'assets/images/quizzy-04-stats.svg',
        title: l10n.onboardingProPage4Title,
        description: l10n.onboardingProPage4Description,
      ),
    ];

    final isLastPage = currentPage.value == pages.length - 1;

    void finishOnboarding() => Navigator.of(context).pop();

    void goNext() {
      if (isLastPage) {
        finishOnboarding();
      } else {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) => currentPage.value = index,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return _OnboardingProPage(
                    illustrationAsset: page.illustrationAsset,
                    title: page.title,
                    description: page.description,
                  );
                },
              ),
            ),
            _PageIndicator(pageCount: pages.length, currentPage: currentPage.value),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  text: isLastPage
                      ? l10n.onboardingProGetStartedButton
                      : l10n.onboardingProNextButton,
                  onPressed: goNext,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardingProPage extends StatelessWidget {
  const _OnboardingProPage({
    required this.illustrationAsset,
    required this.title,
    required this.description,
  });

  final String illustrationAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 240,
            child: SvgPicture.asset(illustrationAsset),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.h2.copyWith(color: AppColors.grayscale600),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.mainText.copyWith(color: AppColors.grayscale500),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.pageCount,
    required this.currentPage,
  });

  final int pageCount;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary500 : AppColors.grayscale300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
