import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/choice_chip_button.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../people/models/person.dart';
import '../../people/models/person_validator.dart';
import '../../people/models/relation_type.dart';
import '../../people/presentation/people_providers.dart';

/// 인물 추가·수정 (F-02). **임시 디자인**. 이름 1~20자(중복 불가), 관계 유형, 메모(선택).
class PersonFormScreen extends ConsumerStatefulWidget {
  const PersonFormScreen({super.key, this.personId});

  /// 있으면 그 인물을 수정한다.
  final String? personId;

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  final _name = TextEditingController();
  final _memo = TextEditingController();
  RelationType _type = RelationType.friend;
  Person? _editing;
  String? _nameError;
  String? _formError;
  bool _loaded = false;

  @override
  void dispose() {
    _name.dispose();
    _memo.dispose();
    super.dispose();
  }

  void _loadOnce(Person? person) {
    if (_loaded || person == null) return;
    _loaded = true;
    _editing = person;
    _name.text = person.name;
    _memo.text = person.memo ?? '';
    _type = person.relationType;
  }

  Future<void> _save() async {
    final existing = ref.read(peopleProvider).value ?? const [];
    final editing = _editing;
    final nameError = PersonValidator.validateName(
      _name.text,
      existing: existing,
      editingId: editing?.id,
    );
    final addError = editing == null
        ? PersonValidator.validateCanAdd(existing)
        : null;
    setState(() {
      _nameError = nameError;
      _formError = addError;
    });
    if (nameError != null || addError != null) return;

    final actions = ref.read(peopleActionsProvider);
    final router = GoRouter.of(context);
    if (editing == null) {
      await actions.create(
        name: _name.text,
        relationType: _type,
        memo: _memo.text,
      );
    } else {
      await actions.update(
        editing.copyWith(
          name: _name.text.trim(),
          relationType: _type,
          memo: _memo.text.trim(),
        ),
      );
    }
    if (!mounted) return;
    router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final id = widget.personId;
    if (id != null) _loadOnce(ref.watch(personProvider(id)));

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.graphTitle.copyWith(color: colors.textBlack),
      ),
    );

    return PageScaffold(
      title: _editing == null ? '인물 추가' : '인물 수정',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          0,
          AppSpacing.pageMargin,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label('이름 (별칭)'),
            AppTextField(
              fieldKey: const Key('person-name'),
              controller: _name,
              hint: '예: 지민',
              maxLength: PersonValidator.maxNameLength,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            Text(
              '실명 대신 별칭을 쓰는 걸 권해요.',
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            label('관계'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in RelationType.values)
                  ChoiceChipButton(
                    label: t.label,
                    selected: _type == t,
                    onTap: () => setState(() => _type = t),
                  ),
              ],
            ),
            label('메모 (선택)'),
            AppTextField(
              fieldKey: const Key('person-memo'),
              controller: _memo,
              hint: '기억해 둘 것이 있다면 적어 보세요.',
              minLines: 2,
              maxLines: 4,
            ),
            if (_formError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _formError!,
                  style: AppTextStyles.caption.copyWith(color: colors.brand),
                ),
              ),
            const SizedBox(height: 32),
            CtaButton(label: '저장', height: 52, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
