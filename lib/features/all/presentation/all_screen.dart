import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/tab_page_scaffold.dart';
import 'widgets/checklist_section.dart';
import 'widgets/profile_section.dart';
import 'widgets/settings_section.dart';

/// 전체 탭: 프로필·요약, 체크리스트(F-04), 설정·데이터 관리(F-10·F-11).
class AllScreen extends StatelessWidget {
  const AllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPageScaffold(
      title: '전체',
      children: [
        SizedBox(height: AppSpacing.space8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
          child: Column(
            children: [
              ProfileSection(),
              SizedBox(height: AppSpacing.space32),
              ChecklistSection(),
              SizedBox(height: AppSpacing.space32),
              SettingsSection(),
            ],
          ),
        ),
      ],
    );
  }
}
