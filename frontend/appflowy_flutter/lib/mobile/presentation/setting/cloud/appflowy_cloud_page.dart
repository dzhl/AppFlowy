import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/mobile/presentation/base/app_bar/app_bar.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/user/application/auth/auth_service.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/setting_cloud.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppFlowyCloudPage extends StatelessWidget {
  const AppFlowyCloudPage({super.key});

  static const routeName = '/AppFlowyCloudPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlowyAppBar(
        titleText: LocaleKeys.settings_menu_cloudSettings.tr(),
      ),
      body: SettingCloud(
        restartAppFlowy: () async {
          await getIt<AuthService>().signOut();
          await runAppFlowy();
        },
      ),
    );
  }
}
