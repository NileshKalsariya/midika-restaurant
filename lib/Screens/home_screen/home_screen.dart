// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:midika/models/home_screen_model.dart';
// import 'package:midika/utils/asset_paths.dart';
// import 'package:midika/utils/colors.dart';
// import 'package:midika/utils/strings.dart';
// import 'package:sizer/sizer.dart';
//
// import 'home_screen_widget.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final List<Item> _itemList = [
//     Item(
//       borderColor: burgerBorderColor,
//       bgColor: burgerBgColor,
//       title: txtBurger,
//       imgPath: iconBurger,
//     ),
//     Item(
//       borderColor: pizzaBorderColor,
//       bgColor: pizzaBgColor,
//       title: txtPizza,
//       imgPath: iconPizzaSlice,
//     ),
//     Item(
//       borderColor: chineseBorderColor,
//       bgColor: chineseBgColor,
//       title: txtChinese,
//       imgPath: iconChineseFood,
//     ),
//     Item(
//       borderColor: drinkBorderColor,
//       bgColor: drinkBgColor,
//       title: txtDrink,
//       imgPath: iconDrink,
//     ),
//     Item(
//       borderColor: iceCreamBorderColor,
//       bgColor: iceCreamBgColor,
//       title: txtIceCream,
//       imgPath: iconIceCream,
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: SizedBox(
//             height: 100.h,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   homeScreenAppBar(),
//                   SizedBox(height: 5.h),
//                   offerCard(offerPercentage: 60),
//                   SizedBox(height: 3.h),
//                   SizedBox(
//                     height: 100,
//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       itemBuilder: (context, index) => itemWidget(
//                         path: _itemList[index].imgPath,
//                         title: _itemList[index].title,
//                         bgColor: _itemList[index].bgColor,
//                         borderColor: _itemList[index].borderColor,
//                       ),
//                       separatorBuilder: (BuildContext context, int index) =>
//                           const SizedBox(width: 20.0),
//                       itemCount: _itemList.length,
//                     ),
//                   ),
//                   titleIndicatorWidget(
//                     title: txtPopularrestaurants,
//                     path: iconLike,
//                   ),
//                   restaurantWidget(
//                     address: 'celina, delaware 10299',
//                     title: 'Munch Grill cafe',
//                     path: imgTesting,
//                   ),
//                   titleIndicatorWidget(
//                     title: txtNearbyRestaurants,
//                     path: iconFoodTray,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
