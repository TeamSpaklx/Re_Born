import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../core/utils/korean_date.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../analysis/crisis_checker.dart';
import '../../entries/models/emotion.dart';
import '../../entries/models/entry.dart';
import '../../entries/models/entry_validator.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../entries/presentation/widgets/emotion_picker.dart';
import '../../people/presentation/people_providers.dart';
import 'crisis_notice.dart';
import 'intensity_selector.dart';

/// 기록 작성·수정 (F-03). **임시 디자인**.
/// 본문(1~2000자) · 인물(선택) · 감정 · 강도를 고르고 저장하면 분석까지 이어진다.
class RecordFormScreen extends ConsumerStatefulWidget {
  const RecordFormScreen({super.key, this.entryId});

  /// 있으면 그 기록을 수정한다.
  final String? entryId;

  @override
  ConsumerState<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends ConsumerState<RecordFormScreen> {
  final _body = TextEditingController();
  Emotion? _emotion;
  int? _intensity;
  String? _personId;
  Entry? _editing;

  String? _bodyError;
  String? _emotionError;
  String? _intensityError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final id = widget.entryId;
    if (id != null) _loadForEdit(id);
  }

  Future<void> _loadForEdit(String id) async {
    final entry = await ref.read(entryProvider(id).future);
    if (!mounted || entry == null) return;
    setState(() {
      _editing = entry;
      _body.text = entry.body;
      _emotion = entry.emotion;
      _intensity = entry.intensity;
      _personId = entry.personId;
    });
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _bodyError = EntryValidator.validateBody(_body.text);
      _emotionError = _emotion == null ? '감정을 선택해 주세요.' : null;
      _intensityError = EntryValidator.validateIntensity(_intensity);
    });
    if (_bodyError != null ||
        _emotionError != null ||
        _intensityError != null) {
      return;
    }

    setState(() => _saving = true);
    // 위기 표현이 있으면 안내를 먼저 보여 주고, 저장은 그대로 진행한다.
    if (CrisisChecker.containsCrisisExpression(_body.text)) {
      await showCrisisNotice(context);
      if (!mounted) return;
    }

    final actions = ref.read(recordActionsProvider);
    final editing = _editing;
    final router = GoRouter.of(context);
    try {
      if (editing == null) {
        await actions.save(
          body: _body.text,
          emotion: _emotion!,
          intensity: _intensity!,
          personId: _personId,
        );
      } else {
        await actions.update(
          editing.copyWith(
            body: _body.text.trim(),
            emotion: _emotion,
            intensity: _intensity,
            personId: _personId,
          ),
        );
      }
    } catch (error, stack) {
      ref.read(appErrorLogProvider).record(error, stack, where: 'save-entry');
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(context, '저장하지 못했어요. 다시 시도해 주세요.');
      return;
    }
    if (!mounted) return;
    router.pop();
  }

  Future<void> _pickPerson() async {
    final people = ref.read(peopleProvider).value ?? const [];
    final colors = context.colors;
    final picked = await showAppBottomSheet<_PersonChoice>(
      context,
      title: '누구와의 기록인가요?',
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetOptionRow(
            title: '인물 없음',
            selected: _personId == null,
            onTap: () => Navigator.of(context).pop(const _PersonChoice(null)),
          ),
          if (people.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
              child: Text(
                '등록된 인물이 없어요. 인물 없이 저장할 수 있고, 관계 탭에서 인물을 추가할 수 있어요.',
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              ),
            ),
          for (final p in people)
            SheetOptionRow(
              title: p.name,
              subtitle: p.relationType.label,
              selected: _personId == p.id,
              onTap: () => Navigator.of(context).pop(_PersonChoice(p.id)),
            ),
        ],
      ),
    );
    if (picked != null) setState(() => _personId = picked.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final people = ref.watch(peopleProvider).value ?? const [];
    final personName = people
        .where((p) => p.id == _personId)
        .map((p) => p.name)
        .firstOrNull;
    final now = ref.watch(clockProvider)();

    Widget label(String text, {bool first = false}) => Padding(
      padding: EdgeInsets.only(
        top: first ? 0 : AppSpacing.space32,
        bottom: AppSpacing.space12,
      ),
      child: Text(
        text,
        style: AppTextStyles.groupTitle.copyWith(color: colors.textBlack),
      ),
    );

    return PageScaffold(
      title: _editing == null ? '지금 마음은\n어떤가요?' : '기록 수정',
      subtitle: _editing == null ? formatKoreanDate(now) : null,
      largeTitle: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.space8,
          AppSpacing.pageMargin,
          AppSpacing.space40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            label('감정', first: true),
            EmotionPicker(
              selected: _emotion,
              onChanged: (e) => setState(() {
                _emotion = e;
                _emotionError = null;
              }),
            ),
            if (_emotionError != null) _error(colors, _emotionError!),
            label('얼마나 강하게 느꼈나요?'),
            IntensitySelector(
              value: _intensity,
              onChanged: (v) => setState(() {
                _intensity = v;
                _intensityError = null;
              }),
            ),
            if (_intensityError != null) _error(colors, _intensityError!),
            label('오늘의 마음'),
            AppTextField(
              fieldKey: const Key('record-body'),
              controller: _body,
              hint: '있었던 일과 느낌을 적어 보세요.',
              maxLength: EntryValidator.maxBodyLength,
              minLines: 5,
              maxLines: 8,
              errorText: _bodyError,
              onChanged: (_) {
                if (_bodyError != null) setState(() => _bodyError = null);
              },
            ),
            label('누구와의 일인가요? (선택)'),
            Pressable(
              key: const Key('record-person'),
              onTap: _pickPerson,
              child: AppCard.white(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                  vertical: AppSpacing.space16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        personName ?? '인물 없음',
                        style: AppTextStyles.rowTitle.copyWith(
                          color: personName == null
                              ? colors.textSecondary
                              : colors.textBlack,
                        ),
                      ),
                    ),
                    SvgPicture.asset(AppAssets.chevronSignal),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: BottomCtaBar(
        label: _saving ? '저장 중…' : '저장',
        onPressed: _saving ? null : _save,
      ),
    );
  }

  Widget _error(AppColors colors, String text) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.space8),
    child: Text(text, style: AppTextStyles.body.copyWith(color: colors.danger)),
  );
}

/// 인물 선택 시트의 결과(null id = 인물 없음). 시트를 그냥 닫으면 선택이 바뀌지 않는다.
class _PersonChoice {
  const _PersonChoice(this.id);

  final String? id;
}
