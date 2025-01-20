// import 'package:flutter/cupertino.dart';
// import 'package:flutter/widgets.dart';
// import 'package:pull_down_button/pull_down_button.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoApp(
//       home: Example(),
//       theme: CupertinoThemeData(
//         primaryColor: CupertinoColors.systemBlue,
//       ),
//     );
//   }
// }

// class Example extends StatelessWidget {
//   const Example({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final edgeInsets = MediaQuery.of(context).padding;
//     final padding = EdgeInsets.only(
//       left: 16 + edgeInsets.left,
//       top: 24 + edgeInsets.top,
//       right: 16 + edgeInsets.right,
//       bottom: 24 + edgeInsets.bottom,
//     );

//     return CupertinoPageScaffold(
//       navigationBar: CupertinoNavigationBar(
//         middle: Text('Messages'),
//         trailing: ExampleMenu(
//           builder: (_, showMenu) => CupertinoButton(
//             padding: EdgeInsets.zero,
//             onPressed: showMenu,
//             child: Icon(CupertinoIcons.ellipsis),
//           ),
//         ),
//       ),
//       child: ListView.separated(
//         padding: padding,
//         reverse: true,
//         itemBuilder: (context, index) {
//           final isSender = index.isEven;

//           return Align(
//             alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
//           );
//         },
//         separatorBuilder: (_, __) => const SizedBox(height: 16),
//         itemCount: 20,
//       ),
//     );
//   }
// }

// class ExampleMenu extends StatelessWidget {
//   const ExampleMenu({
//     super.key,
//     required this.builder,
//   });

//   final PullDownMenuButtonBuilder builder;

//   @override
//   Widget build(BuildContext context) => PullDownButton(
//         itemBuilder: (context) => [
//           PullDownMenuHeader(
//             leading: ColoredBox(
//               color: CupertinoColors.systemBlue.resolveFrom(context),
//             ),
//             title: 'Profile',
//             subtitle: 'Tap to open',
//             onTap: () {},
//             icon: CupertinoIcons.profile_circled,
//           ),
//           const PullDownMenuDivider.large(),
//           PullDownMenuActionsRow.medium(
//             items: [
//               PullDownMenuItem(
//                 onTap: () {},
//                 title: 'Info',
//                 icon: CupertinoIcons.info_circle,
//               ),
//               PullDownMenuItem(
//                 onTap: () {},
//                 title: 'Edit',
//                 icon: CupertinoIcons.pencil,
//               ),
//               PullDownMenuItem(
//                 onTap: () {},
//                 title: 'Delete',
//                 isDestructive: true,
//                 icon: CupertinoIcons.delete_simple,
//               ),
//             ],
//           ),
//           const PullDownMenuDivider.large(),
//           PullDownMenuItem(
//             onTap: () {},
//             title: 'Pin',
//             icon: CupertinoIcons.pin,
//           ),
//           PullDownMenuItem(
//             title: 'Forward',
//             subtitle: 'Share in different channel',
//             onTap: () {},
//             icon: CupertinoIcons.arrowshape_turn_up_right,
//           ),
//           PullDownMenuItem(
//             onTap: () {},
//             title: 'Delete',
//             isDestructive: true,
//             icon: CupertinoIcons.delete,
//           ),
//           const PullDownMenuDivider.large(),
//           PullDownMenuItem(
//             title: 'Select',
//             onTap: () {},
//             icon: CupertinoIcons.checkmark_circle,
//           ),
//         ],
//         buttonBuilder: builder,
//       );
// }
