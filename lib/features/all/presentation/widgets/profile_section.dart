import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/data_providers.dart';
import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/platform/image_picker_service.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/cta_button.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/profile_row.dart';
import '../../../../shared/widgets/summary_card.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/models/auth_validator.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../entries/presentation/entries_providers.dart';
import '../../../people/presentation/people_providers.dart';
import '../../../settings/presentation/settings_providers.dart';
import '../../../todos/presentation/todos_providers.dart';

/// 전체 탭 맨 위: 프로필 행(닉네임·이메일, 누르면 닉네임 변경)과 요약 카드(기록·인물·체크리스트 완료).
class ProfileSection extends ConsumerWidget {
  const ProfileSection({super.key});

  Future<void> _editNickname(
    BuildContext context,
    WidgetRef ref,
    String current,
    String? currentPhoto,
  ) async {
    final result = await showAppBottomSheet<_ProfileEditResult>(
      context,
      title: '프로필 편집',
      builder: (context) => _ProfileEditSheet(
        initialNickname: current,
        initialPhoto: currentPhoto,
      ),
    );
    if (result == null || !context.mounted) return;
    if (result.nicknameChanged) {
      await ref.read(settingsActionsProvider).saveNickname(result.nickname);
    }
    if (!context.mounted) return;
    if (result.profileChanged) {
      showAppToast(context, '프로필이 변경되었어요');
    } else if (result.nicknameChanged) {
      showAppToast(context, '닉네임을 바꿨어요');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(settingsProvider).value?.nickname ?? '';
    final photo = ref.watch(settingsProvider).value?.profileImagePath;
    final email = ref.watch(sessionProvider)?.email;
    final entries = ref.watch(entriesProvider).value?.length ?? 0;
    final people = ref.watch(peopleProvider).value?.length ?? 0;
    final todos = ref.watch(todosProvider).value ?? const [];
    final done = todos.where((t) => t.done).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard.white(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: ProfileRow(
            title: nickname.isEmpty ? '닉네임을 정해 주세요' : nickname,
            subtitle: email,
            avatar: UserAvatar(photoPath: photo, size: 56),
            onTap: () => _editNickname(context, ref, nickname, photo),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        SummaryCard(
          items: [
            SummaryItem(value: '$entries', label: '기록'),
            SummaryItem(value: '$people', label: '인물'),
            SummaryItem(value: '$done/${todos.length}', label: '체크 완료'),
          ],
        ),
      ],
    );
  }
}

/// 프로필 편집 시트: 아바타(사진 또는 캐릭터) + 사진 찍기·앨범에서 선택·기본으로 되돌리기 + 닉네임.
/// 사진은 고르는 즉시 저장되고, 닉네임은 "저장"을 눌러야 시트가 닫히며 저장된다.
class _ProfileEditSheet extends ConsumerStatefulWidget {
  const _ProfileEditSheet({
    required this.initialNickname,
    required this.initialPhoto,
  });

  final String initialNickname;
  final String? initialPhoto;

  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialNickname,
  );
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick(PhotoSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final path = await ref.read(imagePickerServiceProvider).pick(source);
      if (path != null) {
        await ref.read(settingsActionsProvider).saveProfileImage(path);
      }
    } on PhotoPickException catch (e) {
      if (mounted) {
        showAppToast(
          context,
          e.source == PhotoSource.camera
              ? '카메라를 쓸 수 없어요. 기기 설정에서 권한을 확인해 주세요.'
              : '앨범을 열 수 없어요. 기기 설정에서 권한을 확인해 주세요.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    final error = AuthValidator.validateNickname(_controller.text);
    setState(() => _error = error);
    if (error == null) {
      final photo = ref.read(settingsProvider).value?.profileImagePath;
      Navigator.of(context).pop(
        _ProfileEditResult(
          nickname: _controller.text.trim(),
          nicknameChanged: _controller.text.trim() != widget.initialNickname,
          profileChanged: photo != widget.initialPhoto,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final photo = ref.watch(settingsProvider).value?.profileImagePath;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(photoPath: photo, size: 96),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.brand,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.cardWhite, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(
                      AppAssets.ixEdit,
                      colorFilter: ColorFilter.mode(
                        colors.onCta,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        _PhotoActionRow(
          key: const Key('profile-camera'),
          iconAsset: AppAssets.ixCamera,
          label: '사진 찍기',
          onTap: () => _pick(PhotoSource.camera),
        ),
        _PhotoActionRow(
          key: const Key('profile-gallery'),
          iconAsset: AppAssets.ixGallery,
          label: '앨범에서 선택',
          onTap: () => _pick(PhotoSource.gallery),
        ),
        if (photo != null)
          _PhotoActionRow(
            key: const Key('profile-reset'),
            iconAsset: AppAssets.trash,
            label: '기본 캐릭터로 되돌리기',
            destructive: true,
            onTap: () =>
                ref.read(settingsActionsProvider).saveProfileImage(null),
          ),
        const SizedBox(height: AppSpacing.space16),
        AppTextField(
          fieldKey: const Key('nickname-field'),
          controller: _controller,
          label: '닉네임',
          hint: '닉네임',
          errorText: _error,
          helperText: '${AuthValidator.maxNicknameLength}자 이내, 홈 인사에 쓰여요.',
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.space16),
        CtaButton(label: '저장', height: 52, onPressed: _submit),
      ],
    );
  }
}

class _ProfileEditResult {
  const _ProfileEditResult({
    required this.nickname,
    required this.nicknameChanged,
    required this.profileChanged,
  });

  final String nickname;
  final bool nicknameChanged;
  final bool profileChanged;
}

class _PhotoActionRow extends StatelessWidget {
  const _PhotoActionRow({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = destructive ? colors.danger : colors.textBlack;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(width: AppSpacing.space12),
              Text(label, style: AppTextStyles.rowTitle.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
