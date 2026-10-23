import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../features/entries/models/emotion.dart';
import '../../features/entries/presentation/widgets/emotion_chip.dart';
import '../../app/theme/app_assets.dart';
import '../../features/entries/presentation/widgets/emotion_face.dart';
import '../../features/entries/presentation/widgets/emotion_picker.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_fab.dart';
import '../widgets/app_tab_bar.dart';
import '../widgets/app_text_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/bottom_cta_bar.dart';
import '../widgets/check_row.dart';
import '../widgets/consent_row.dart';
import '../widgets/donut_chart.dart';
import '../widgets/month_calendar.dart';
import '../widgets/notification_row.dart';
import '../widgets/permission_row.dart';
import '../widgets/select_card.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/summary_card.dart';
import '../widgets/swipe_to_delete.dart';
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
  Emotion? _emotion;
  DateTime _month = DateTime(2026, 10);
  DateTime _day = DateTime(2026, 10, 24);
  int _select = 0;
  int _tab = 0;

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
          section('감정 · 기록', [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final e in Emotion.values)
                  EmotionFace(emotion: e, size: 36),
              ],
            ),
            gap(),
            EmotionPicker(
              selected: _emotion,
              onChanged: (e) => setState(() => _emotion = e),
            ),
            gap(AppSpacing.space16),
            const EmotionRatioBar(
              counts: {Emotion.joy: 4, Emotion.calm: 3, Emotion.hurt: 2},
            ),
            gap(AppSpacing.space16),
            AppCard.white(
              padding: const EdgeInsets.all(AppSpacing.space12),
              child: MonthCalendar(
                month: _month,
                selected: _day,
                today: DateTime(2026, 10, 24),
                onSelected: (d) => setState(() => _day = d),
                onMonthChanged: (m) => setState(() => _month = m),
                markerFor: (d) => d.day % 5 == 0
                    ? EmotionFace(emotion: Emotion.joy, size: 20)
                    : null,
              ),
            ),
          ]),
          section('선택 · 진행 · 동의', [
            const StepProgressBar(current: 2, total: 4),
            gap(AppSpacing.space16),
            SelectCard(
              title: '친구',
              description: '편하게 마음을 나누는 친구',
              selected: _select == 0,
              onTap: () => setState(() => _select = 0),
            ),
            gap(),
            SelectCard(
              title: '가족',
              description: '가장 가까이 있는 가족',
              selected: _select == 1,
              onTap: () => setState(() => _select = 1),
            ),
            gap(AppSpacing.space16),
            ConsentRow(
              label: '전체 동의',
              emphasized: true,
              checked: _checkA && _checkB,
              onChanged: (v) => setState(() => _checkA = _checkB = v),
            ),
            ConsentRow(
              tag: '필수',
              label: '개인정보 수집·이용',
              checked: _checkA,
              onChanged: (v) => setState(() => _checkA = v),
              onView: _noop,
            ),
            ConsentRow(
              tag: '선택',
              label: '사용 분석',
              checked: _checkB,
              onChanged: (v) => setState(() => _checkB = v),
            ),
            const PermissionRow(
              iconAsset: AppAssets.bell,
              title: '인사이트 알림',
              description: '관계의 변화가 감지되면 알려 드려요.',
            ),
          ]),
          section('요약 · 탭 · 알림 · 차트', [
            const SummaryCard(
              items: [
                SummaryItem(value: '12', label: '기록'),
                SummaryItem(value: '3', label: '인물'),
                SummaryItem(value: '1/2', label: '체크 완료'),
              ],
            ),
            gap(),
            AppTabBar(
              labels: const ['전체', '안 읽음'],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            gap(),
            NotificationRow(
              iconAsset: AppAssets.forum,
              title: '지민님과의 관계를 살펴보세요',
              body: '최근 부정적인 기록이 늘었어요',
              timeLabel: '3시간 전',
              unread: true,
              onTap: _noop,
            ),
            gap(AppSpacing.space8),
            NotificationRow(
              iconAsset: AppAssets.sealCheck,
              title: '승현님과의 관계가 나아지고 있어요',
              body: '관계 지수가 올랐어요',
              timeLabel: '2일 전',
              unread: false,
              onTap: _noop,
            ),
            gap(),
            SwipeToDelete(
              dismissKey: const Key('gallery-swipe'),
              onDelete: _noop,
              child: AppCard.white(
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: const Row(children: [Text('← 밀어서 삭제')]),
              ),
            ),
            gap(AppSpacing.space16),
            const Center(
              child: DonutChart(
                segments: [
                  DonutSegment(value: 5, color: Color(0xFFFF80A6)),
                  DonutSegment(value: 3, color: Color(0xFFFFB3CA)),
                  DonutSegment(value: 2, color: Color(0xFFD94F79)),
                ],
                center: Text('10건'),
              ),
            ),
            gap(AppSpacing.space16),
            const Align(
              alignment: Alignment.centerRight,
              child: AppFab(label: '기록하기', onTap: _noop),
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
