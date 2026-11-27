import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/tab_page_scaffold.dart';
import 'widgets/profile_section.dart';
import 'widgets/settings_section.dart';

/// 마이 탭(코드 이름은 all): 프로필·요약, 설정·데이터 관리(F-10·F-11). 체크리스트는 기록 탭에 있다.
class AllScreen extends StatelessWidget {
  const AllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPageScaffold(
      title: '마이',
      children: [
        SizedBox(height: AppSpacing.space8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
          child: Column(
            children: [
              ProfileSection(),
              SizedBox(height: AppSpacing.space32),
              SettingsSection(),
            ],
          ),
        ),
      ],
    );
  }
}
