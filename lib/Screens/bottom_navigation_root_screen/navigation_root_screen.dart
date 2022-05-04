import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:midika/Screens/add_new_item_screen/items_list.dart';
import 'package:midika/Screens/dashboard_screen/dashboard_screen.dart';
import 'package:midika/Screens/home_screen/home_screen_widget.dart';
import 'package:midika/Screens/order_status_screen/order_status_screen.dart';
import 'package:midika/Screens/profile_screens/profile_screen.dart';
import 'package:midika/Screens/qr_screen/manage_or_code.dart';
import 'package:midika/provider/screen_provider.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class BottomNavigationRootScreen extends StatefulWidget {
  int index;

  BottomNavigationRootScreen({Key? key, this.index = 2}) : super(key: key);

  @override
  State<BottomNavigationRootScreen> createState() =>
      _BottomNavigationRootScreenState();
}

class _BottomNavigationRootScreenState
    extends State<BottomNavigationRootScreen> {
  List<Widget> _buildScreens() {
    return [
      const ItemList(),
      const OrderStatusScreen(),
      const DashBoardScreen(),
      const ManageQRCodeScreen(),
      const ProfileScreen1(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: appIcon(path: iconNavOrder),
        title: ("Home"),
        activeColorPrimary: appPrimaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: appIcon(path: iconNavMenu),
        title: ("Search"),
        activeColorPrimary: appPrimaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(
          iconNavCenter,
          fit: BoxFit.cover,
        ),
        // icon: appIcon(
        //     path: iconNavCenter, width: 100, height: 100, fit: BoxFit.cover),
        title: ("Scan"),
        activeColorPrimary: appPrimaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: appIcon(
          path: iconNavScan,
        ),
        title: ("Post"),
        activeColorPrimary: appPrimaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: appIcon(
          path: iconNavUser,
        ),
        title: ("Profile"),
        activeColorPrimary: appPrimaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller;

    _controller = PersistentTabController(initialIndex: widget.index);

    return PersistentTabView(
      context,
      controller: _controller,

      // hideNavigationBar:
      //     Provider.of<AuthServices>(context, listen: true).isLoading,
      screens: _buildScreens(),

      items: _navBarsItems(),
      confineInSafeArea: true,
      navBarHeight: 70,
      hideNavigationBar: false,
      onItemSelected: (index) {
        Provider.of<ScreenProvier>(context, listen: false)
            .setCurrentIndex(index);
      },
      backgroundColor: Colors.white,
      // Default is Colors.white.
      handleAndroidBackButtonPress: true,
      // Default is true.
      resizeToAvoidBottomInset: true,
      // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true,
      // Default is true.
      hideNavigationBarWhenKeyboardShows: true,
      // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(32.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.style12, // Choose the nav bar style with this property.
    );
  }
}
