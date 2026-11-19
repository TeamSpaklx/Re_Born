import 'package:flutter/widgets.dart';

import 'app_dialogs.dart';

/// 입력 중인 화면을 나가기 전에 한 번 묻는다.
///
/// [dirty]면 뒤로 버튼, 화면을 오른쪽으로 밀기, Android 뒤로 가기 모두 바로 닫지 않고
/// "작성 중인 내용을 버릴까요?" 확인 창을 띄운다. "나가기"를 고르면 그때 닫는다.
/// 저장 후 코드에서 `pop()`으로 닫는 것은 막지 않는다.
class LeaveConfirmScope extends StatelessWidget {
  const LeaveConfirmScope({
    super.key,
    required this.dirty,
    required this.child,
    this.title = '작성 중인 내용을 버릴까요?',
    this.message = '나가면 지금까지 입력한 내용이 사라져요.',
  });

  final bool dirty;
  final Widget child;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showAppConfirmDialog(
          context,
          title: title,
          message: message,
          confirmLabel: '나가기',
          cancelLabel: '계속 쓰기',
          destructive: true,
        );
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: child,
    );
  }
}
