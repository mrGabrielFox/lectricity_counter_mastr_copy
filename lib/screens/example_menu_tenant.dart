import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:electricity_counter_mastr_copy/screens/user_settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

class ExampleMenuTenant extends StatelessWidget {
  final CustomUser user; // Используем CastomUser
  final Function(bool) toggleTheme;
  final bool isDarkTheme;
  final PullDownMenuButtonBuilder builder;

  const ExampleMenuTenant({
    super.key,
    required this.user,
    required this.toggleTheme,
    required this.isDarkTheme,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => PullDownButton(
        itemBuilder: (context) => [
          PullDownMenuHeader(
            leading: ColoredBox(
              color: CupertinoColors.systemBlue.resolveFrom(context),
            ),
            title: 'Настройки',
            subtitle: 'Tap to open',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => UserSettingsScreen(
                    user: user, // Передаем CastomUser
                  ),
                ),
              );
            },
            icon: CupertinoIcons.settings,
          ),
          const PullDownMenuDivider.large(),
        ],
        buttonBuilder: builder,
      );
}
