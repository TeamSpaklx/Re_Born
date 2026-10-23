import 'package:flutter/material.dart';

import '../../../shared/widgets/app_dialogs.dart';

/// 위기 표현이 감지되었을 때 보여 주는 안내 (SPEC F-13). 확인하면 저장이 그대로 이어진다.
/// 상담 연락처는 출시 전에 공식 기관 안내로 확인해 넣어야 한다(SPEC 11장 12번).
Future<void> showCrisisNotice(BuildContext context) {
  return showAppConfirmDialog(
    context,
    title: '마음이 많이 힘드신 것 같아요',
    message:
        '혼자 견디지 않아도 괜찮아요. 가까운 사람이나 전문 상담 기관에 도움을 요청해 보세요.\n'
        '리본은 의료·상담 서비스가 아니에요.',
    confirmLabel: '확인했어요',
    cancelLabel: null,
  );
}
