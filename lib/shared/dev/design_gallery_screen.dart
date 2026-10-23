import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../features/entries/models/emotion.dart';
import '../../features/entries/presentation/widgets/emotion_chip.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_text_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/bottom_cta_bar.dart';
import '../widgets/check_row.dart';
import '../widgets/choice_chip_button.dart';
import '../widgets/cta_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/list_section_header.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/profile_row.dart';
import '../widgets/segmented_control.dart';
import '../widgets/settings_group.dart';
import '../widgets/skeleton.dart';

/// 디자인 갤러리(개발용): 리본 디자인 시스템의 토큰과 공통 컴포넌트를 한 화면에 모아 눈으로 검수한다.
/// 디버그 빌드에서만 열린다(`/dev/gallery`, 전체 탭 설정 맨 아래 "디자인 갤러리").
/// 컴포넌트를 추가·수정하면 여기에도 반영하고 docs/DESIGN_SYSTEM.md 7장을 같이 고친다.
class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController(text: 'abc');
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _toggle = true;
  bool _checkA = true;
  bool _checkB = false;
  int _segment = 0;
  int _chip = 0;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget section(String title, List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListSectionHeader(title: title),
        ...children,
        const SizedBox(height: AppSpacing.space8),
      ],
    );
    Widget gap([double h = AppSpacing.space12]) => SizedBox(height: h);

    return PageScaffold(
      title: '디자인 갤러리',
      largeTitle: true,
      bottom: BottomCtaBar(label: '주요 행동 (하단 고정)', onPressed: () {}),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
        children: [
          section('색', [
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: [
                _swatch('brand', colors.brand),
                _swatch('ctaSoft', colors.ctaSoft),
                _swatch('cardPink', colors.cardPink),
                _swatch('background', colors.background),
                _swatch('chip', colors.chip),
                _swatch('danger', colors.danger),
                _swatch('dangerTile', colors.dangerTile),
                _swatch('toggleOff', colors.toggleOff),
                _swatch('skeleton', colors.skeleton),
                _swatch('textBlack', colors.textBlack),
                _swatch('textSecondary', colors.textSecondary),
              ],
            ),
          ]),
          section('감정 8색 (임시)', [
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: [
                for (final e in Emotion.values) EmotionChip(emotion: e),
              ],
            ),
            gap(),
            Row(
              children: [
                for (final e in Emotion.values) ...[
                  EmotionDot(emotion: e, size: 28),
                  const SizedBox(width: AppSpacing.space8),
                ],
              ],
            ),
          ]),
          section('글자', [
            Text(
              '큰 제목 26 ExtraBold',
              style: AppTextStyles.greeting.copyWith(color: colors.textBlack),
            ),
            Text(
              '제목 20 SemiBold',
              style: AppTextStyles.sectionTitle.copyWith(
                color: colors.textBlack,
              ),
            ),
            Text(
              '소제목 18 SemiBold',
              style: AppTextStyles.actionTitle.copyWith(
                color: colors.textBlack,
              ),
            ),
            Text(
              '본문 16 Medium',
              style: AppTextStyles.rowTitle.copyWith(color: colors.textBlack),
            ),
            Text(
              '본문 14 Medium',
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            ),
            Text(
              '캡션 10 Regular',
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ]),
          section('버튼', [
            const CtaButton(
              label: '주요 (primary)',
              height: 52,
              onPressed: _noop,
            ),
            gap(),
            const CtaButton(
              label: '소프트 (soft)',
              height: 52,
              variant: CtaVariant.soft,
              onPressed: _noop,
            ),
            gap(),
            const CtaButton(
              label: '보조 (secondary)',
              height: 52,
              variant: CtaVariant.secondary,
              onPressed: _noop,
            ),
            gap(),
            const CtaButton(
              label: '위험 (destructive)',
              height: 52,
              variant: CtaVariant.destructive,
              onPressed: _noop,
            ),
            gap(),
            const CtaButton(label: '비활성', height: 52, onPressed: null),
            gap(),
            const CtaButton(label: '작은 버튼 48', height: 48, onPressed: _noop),
          ]),
          section('입력', [
            AppTextField(
              controller: _name,
              label: '이름',
              hint: '이름을 입력해 주세요',
              helperText: '20자까지 입력할 수 있어요',
            ),
            gap(),
            AppTextField(
              controller: _email,
              label: '이메일',
              errorText: '올바른 이메일 형식이 아니에요',
            ),
            gap(),
            AppTextField(
              controller: _password,
              label: '비밀번호',
              hint: '8자 이상',
              obscureText: _hidePassword,
              suffix: AppTextButton(
                label: _hidePassword ? '보기' : '숨기기',
                color: colors.textSecondary,
                onTap: () => setState(() => _hidePassword = !_hidePassword),
              ),
            ),
          ]),
          section('칩 · 세그먼트 · 토글', [
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: [
                for (var i = 0; i < 3; i++)
                  ChoiceChipButton(
                    label: ['친구', '가족', '직장'][i],
                    selected: _chip == i,
                    onTap: () => setState(() => _chip = i),
                  ),
              ],
            ),
            gap(),
            SegmentedControl(
              labels: const ['주간', '월간', '연간'],
              selectedIndex: _segment,
              onChanged: (i) => setState(() => _segment = i),
            ),
            gap(),
            SettingsGroup(
              children: [
                SettingsRow.toggle(
                  title: '매일 기록 알림',
                  value: _toggle,
                  onChanged: (v) => setState(() => _toggle = v),
                ),
                SettingsRow.link(
                  title: '언어',
                  trailingText: '한국어',
                  onTap: () {},
                ),
                SettingsRow.destructive(title: '계정 삭제', onTap: () {}),
              ],
            ),
          ]),
          section('목록', [
            AppCard.white(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const ProfileRow(title: '이윤재', subtitle: '내 정보 · 계정 관리'),
                  CheckRow(
                    title: '지민님에게 가볍게 안부 묻기',
                    checked: _checkA,
                    onChanged: (v) => setState(() => _checkA = v),
                  ),
                  CheckRow(
                    title: '오늘은 거리를 두기',
                    subtitle: '인사이트에서 담았어요',
                    checked: _checkB,
                    onChanged: (v) => setState(() => _checkB = v),
                  ),
                ],
              ),
            ),
            gap(),
            Row(
              children: const [
                Badged(
                  badge: AppBadge.count(3),
                  child: Icon(Icons.notifications_none, size: 28),
                ),
                SizedBox(width: AppSpacing.space24),
                Badged(
                  badge: AppBadge.dot(),
                  child: Icon(Icons.mail, size: 28),
                ),
                SizedBox(width: AppSpacing.space24),
                AppBadge.count(120),
              ],
            ),
          ]),
          section('카드', [
            const AppCard.outlined(
              height: 72,
              child: Center(child: Text('outlined (기록 카드 Before)')),
            ),
            gap(),
            const AppCard.pink(
              height: 72,
              child: Center(child: Text('pink (기록 완료)')),
            ),
          ]),
          section('로딩 · 빈 상태 · 오류', [
            const SkeletonScope(
              child: Column(
                children: [
                  SkeletonListCard(),
                  SizedBox(height: AppSpacing.space12),
                  SkeletonBox(height: 120, radius: AppRadii.card),
                ],
              ),
            ),
            const EmptyState(
              message: '아직 기록이 없어요',
              hint: '첫 마음을 남겨 볼까요?',
              showMascot: true,
              actionLabel: '감정 기록하기',
              onAction: _noop,
            ),
            const ErrorState(onRetry: _noop),
          ]),
          section('모달 · 시트 · 토스트', [
            CtaButton(
              label: '확인 모달',
              height: 48,
              variant: CtaVariant.secondary,
              onPressed: () => showAppConfirmDialog(
                context,
                title: '로그아웃',
                message: '정말 로그아웃하시겠어요?',
                confirmLabel: '네',
                cancelLabel: '아니오',
              ),
            ),
            gap(),
            CtaButton(
              label: '위험 모달',
              height: 48,
              variant: CtaVariant.secondary,
              onPressed: () => showAppConfirmDialog(
                context,
                title: '기록을 삭제할까요?',
                message: '삭제하면 되돌릴 수 없어요.',
                confirmLabel: '삭제',
                destructive: true,
              ),
            ),
            gap(),
            CtaButton(
              label: '바텀시트',
              height: 48,
              variant: CtaVariant.secondary,
              onPressed: () => showAppBottomSheet<void>(
                context,
                title: '누구와의 기록인가요?',
                builder: (context) => Column(
                  children: [
                    SheetOptionRow(
                      title: '인물 없음',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    SheetOptionRow(
                      title: '지민',
                      subtitle: '친구',
                      selected: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            gap(),
            CtaButton(
              label: '토스트',
              height: 48,
              variant: CtaVariant.secondary,
              onPressed: () => showAppToast(context, '체크리스트에 담았어요'),
            ),
          ]),
          const SizedBox(height: AppSpacing.space24),
        ],
      ),
    );
  }

  static void _noop() {}

  Widget _swatch(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.button),
            border: Border.all(color: context.colors.cardBorder),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 64,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
