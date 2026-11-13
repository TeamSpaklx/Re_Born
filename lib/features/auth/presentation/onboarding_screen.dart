import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/app_text_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/select_card.dart';
import '../../../shared/widgets/step_progress_bar.dart';
import '../../people/models/person_validator.dart';
import '../../people/models/relation_type.dart';
import '../../people/presentation/people_providers.dart';

/// 가입 3/4: 가장 먼저 마음을 기록해 볼 사람 한 명을 추가한다. 건너뛸 수 있다.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  RelationType _type = RelationType.friend;
  String? _nameError;
  bool _busy = false;

  static const _descriptions = {
    RelationType.friend: '편하게 마음을 나누는 친구',
    RelationType.family: '가장 가까이 있는 가족',
    RelationType.teacher: '학교·학원에서 만나는 선생님',
    RelationType.coworker: '함께 일하고 공부하는 동료',
    RelationType.other: '위에 없는 소중한 사람',
  };

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _skip() => context.go(AppRoutes.onboardingPermission);

  Future<void> _next() async {
    final existing = ref.read(peopleProvider).value ?? const [];
    final error = PersonValidator.validateName(_name.text, existing: existing);
    setState(() => _nameError = error);
    if (error != null) return;
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    try {
      await ref
          .read(peopleActionsProvider)
          .create(name: _name.text, relationType: _type);
    } catch (e, stack) {
      ref
          .read(appErrorLogProvider)
          .record(e, stack, where: 'onboarding-person');
      if (!mounted) return;
      setState(() => _busy = false);
      showAppToast(context, '저장하지 못했어요. 다시 시도해 주세요.');
      return;
    }
    router.go(AppRoutes.onboardingPermission);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PageScaffold(
      title: '누구와의 마음을\n먼저 기록해 볼까요?',
      subtitle: '한 명만 먼저 추가해 둘게요. 나중에 더 추가할 수 있어요.',
      largeTitle: true,
      showBack: false,
      progress: const StepProgressBar(current: 3, total: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.space8,
          AppSpacing.pageMargin,
          AppSpacing.space24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              fieldKey: const Key('onboarding-name'),
              controller: _name,
              label: '이름(별칭)',
              hint: '예: 하은',
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: AppSpacing.space24),
            Text(
              '어떤 사이인가요?',
              style: AppTextStyles.sectionLabel.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            for (final type in RelationType.values) ...[
              SelectCard(
                title: type.label,
                description: _descriptions[type],
                selected: _type == type,
                onTap: () => setState(() => _type = type),
              ),
              const SizedBox(height: AppSpacing.space12),
            ],
          ],
        ),
      ),
      bottom: BottomCtaBar(
        label: '다음',
        onPressed: _busy ? null : _next,
        secondary: AppTextButton(
          label: '나중에 할게요',
          color: colors.textSecondary,
          onTap: _skip,
        ),
      ),
    );
  }
}
