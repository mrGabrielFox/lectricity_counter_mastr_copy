import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:electricity_counter_mastr_copy/screens/user_settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

class ExampleMenuLandlord extends StatelessWidget {
  final CustomUser user; // Используем CastomUser
  final Function(BuildContext) showAddPropertyPopup;
  final Function() addMeter;
  final Function(bool) toggleTheme;
  final bool isDarkTheme;
  final Function() inviteTenant; // Добавляем метод для приглашения
  final PullDownMenuButtonBuilder builder;

  const ExampleMenuLandlord({
    super.key,
    required this.user,
    required this.showAddPropertyPopup,
    required this.addMeter,
    required this.toggleTheme,
    required this.isDarkTheme,
    required this.inviteTenant, // Добавляем метод для приглашения
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
          PullDownMenuItem(
            onTap: () {
              showAddPropertyPopup(context);
            },
            title: 'Добавить недвижимость',
            icon: CupertinoIcons.home,
          ),
          PullDownMenuItem(
            onTap: () {
              addMeter();
            },
            title: 'Добавить счётчик',
            icon: CupertinoIcons.add_circled,
          ),
          PullDownMenuItem(
            onTap: inviteTenant, // Вызываем метод приглашения
            title: 'Пригласить арендатора',
            icon: CupertinoIcons.person_add,
          ),
        ],
        buttonBuilder: builder,
      );
}
