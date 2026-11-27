import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../core/utils/korean_date.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/leave_confirm_scope.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../analysis/crisis_checker.dart';
import '../../entries/models/emotion.dart';
import '../../entries/models/entry.dart';
import '../../entries/models/entry_validator.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../entries/presentation/widgets/emotion_picker.dart';
import 'crisis_notice.dart';
import 'intensity_selector.dart';

/// 일기 작성·수정 (F-03). **임시 디자인**.
/// 감정 · 강도(1~5단계 기준표) · 본문(1~2000자)을 쓰고 저장하면 AI 코멘트 결과 화면으로 간다.
/// 수정이면 저장 뒤 상세로 돌아가고, 코멘트는 다시 받는다.
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
    });
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  /// 처음(새 기록이면 빈 값, 수정이면 불러온 값)과 달라졌는지. 달라졌으면 나갈 때 묻는다.
  bool get _dirty {
    final editing = _editing;
    if (editing == null) {
      if (widget.entryId != null) return false; // 수정할 기록을 아직 불러오는 중
      return _body.text.trim().isNotEmpty ||
          _emotion != null ||
          _intensity != null;
    }
    return _body.text.trim() != editing.body.trim() ||
        _emotion != editing.emotion ||
        _intensity != editing.intensity;
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
        final saved = await actions.save(
          body: _body.text,
          emotion: _emotion!,
          intensity: _intensity!,
        );
        if (!mounted) return;
        // 작성 화면을 결과 화면으로 바꾼다(뒤로 가면 작성 화면이 아니라 원래 탭으로).
        router.pushReplacement(AppRoutes.recordResult(saved.id));
        return;
      } else {
        await actions.update(
          editing.copyWith(
            body: _body.text.trim(),
            emotion: _emotion,
            intensity: _intensity,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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

    // 본문은 글자마다 화면 전체를 다시 그리지 않도록 확인 범위만 다시 계산한다.
    return ListenableBuilder(
      listenable: _body,
      builder: (context, child) => LeaveConfirmScope(
        dirty: !_saving && _dirty,
        title: _editing == null ? '작성 중인 기록을 버릴까요?' : '수정한 내용을 버릴까요?',
        child: child!,
      ),
      child: _form(context, colors, label, now),
    );
  }

  Widget _form(
    BuildContext context,
    AppColors colors,
    Widget Function(String, {bool first}) label,
    DateTime now,
  ) {
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
