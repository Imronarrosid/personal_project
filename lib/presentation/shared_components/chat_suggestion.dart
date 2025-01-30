// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:go_router/go_router.dart';
// import 'package:personal_project/presentation/responsive/dimension.dart';
// import 'package:personal_project/presentation/router/app_router.dart';
// import 'package:personal_project/presentation/router/route_utils.dart';

// import '../../constant/dimens.dart';
// import '../ui/mabar/mabar_page.dart';

// showChatSugestion(
//   BuildContext context, {
//   required Function(String msg) onMessageTap,
// }) {
//   if (MediaQuery.of(context).size.width > mobileWidth) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return Dialog(
//               child: SizedBox(
//             width: 400,
//             height: 500,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Saran Pesan',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 SizedBox(
//                   height: Dimens.DIMENS_24,
//                 ),
//                 ChatThemplateItem(
//                   msg:
//                       '"Lobi sudah siap, pemainnya masih dicari. Siapa yang mau jadi MVP?"',
//                   onTap: (msg) => onMessageTap(msg),
//                 ),
//                 SizedBox(
//                   height: Dimens.DIMENS_6,
//                 ),
//                 ChatThemplateItem(
//                   msg:
//                       '"Nyari squad buat push rank! Siapa yang siap jadi pro player dadakan?"',
//                   onTap: (msg) => onMessageTap(msg),
//                 ),
//                 SizedBox(
//                   height: Dimens.DIMENS_6,
//                 ),
//                 ChatThemplateItem(
//                   msg:
//                       '"Mabar yuk! Dijamin seru, kecuali kalau kamu nge-lag terus."',
//                   onTap: (msg) => onMessageTap(msg),
//                 ),
//               ],
//             ),
//           ));
//         });
//   } else {
//     showModalBottomSheet(
//         elevation: 0,
//         showDragHandle: true,
//         context: context,
//         builder: (context) => BottmonSheetChat(
//               onMessageTap: (msg) => onMessageTap(msg),
//             ));
//   }
// }

// class BottmonSheetChat extends StatelessWidget {
//   final Function(String) onMessageTap;
//   const BottmonSheetChat({
//     super.key,
//     required this.onMessageTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height * 0.5,
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Saran Pesan',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             SizedBox(
//               height: Dimens.DIMENS_24,
//             ),
//             ChatThemplateItem(
//               msg:
//                   '"Lobi sudah siap, pemainnya masih dicari. Siapa yang mau jadi MVP?"',
//               onTap: (msg) => onMessageTap(msg),
//             ),
//             SizedBox(
//               height: Dimens.DIMENS_6,
//             ),
//             ChatThemplateItem(
//               msg:
//                   '"Nyari squad buat push rank! Siapa yang siap jadi pro player dadakan?"',
//               onTap: (msg) => onMessageTap(msg),
//             ),
//             SizedBox(
//               height: Dimens.DIMENS_6,
//             ),
//             ChatThemplateItem(
//               msg:
//                   '"Mabar yuk! Dijamin seru, kecuali kalau kamu nge-lag terus."',
//               onTap: (msg) => onMessageTap(msg),
//             ),
//             SizedBox(
//               height: Dimens.DIMENS_6,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
