// ignore_for_file:  unused_local_variable

import 'package:benji_aggregator/app/others/my_orders/all_orders.dart';
import 'package:benji_aggregator/controller/order_controller.dart';
import 'package:benji_aggregator/controller/rider_controller.dart';
import 'package:benji_aggregator/controller/vendor_controller.dart';
import 'package:benji_aggregator/src/components/dashboard_all_orders_container.dart';
import 'package:benji_aggregator/src/components/dashboard_app_bar.dart';
import 'package:benji_aggregator/src/skeletons/dashboard_page_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../controller/user_controller.dart';
import '../../model/order_list_model.dart';
import '../../src/components/dashboard_orders_container.dart';
import '../../src/components/dashboard_rider_vendor_container.dart';
import '../../src/providers/constants.dart';
import '../../src/responsive/responsive_constant.dart';
import '../../theme/colors.dart';
import '../others/my_orders/active_orders.dart';
import '../others/my_orders/pending_orders.dart';
import '../riders/riders.dart';
import '../vendors/vendors.dart';

class Dashboard extends StatefulWidget {
  final VoidCallback showNavigation;
  final VoidCallback hideNavigation;
  Dashboard(
      {Key? key, required this.showNavigation, required this.hideNavigation})
      : super(key: key);
  final user = Get.put(UserController());
  final vendor = Get.put(VendorController());
  final ride = Get.put(RiderController());

  @override
  State<Dashboard> createState() => _DashboardState();
}

typedef ModalContentBuilder = Widget Function(BuildContext);

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  //===================== Initial State ==========================\\
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      OrderController.instance.runTask();
      VendorController.instance.runTask();
      RiderController.instance.runTask();
    });

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    scrollController.addListener(_scrollListener);
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.showNavigation();
      } else {
        widget.hideNavigation();
      }
    });
    _loadingScreen = true;
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => setState(
        () => _loadingScreen = false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    scrollController.dispose();
    scrollController.removeListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.showNavigation();
      } else {
        widget.hideNavigation();
      }
    });
  }

//==========================================================================================\\

//=================================== ALL VARIABLES =====================================\\
  late bool _loadingScreen;
  bool _isScrollToTopBtnVisible = false;
  int incrementOrderID = 2 + 2;
  late int orderID;
  String orderItem = "Jollof Rice and Chicken";
  String customerAddress = "21 Odogwu Street, New Haven";
  int itemQuantity = 2;
  double price = 2500;
  double itemPrice = 2500;
  String orderImage = "chizzy's-food";
  String customerName = "Mercy Luke";

//============================================== CONTROLLERS =================================================\\
  final scrollController = ScrollController();
  late AnimationController _animationController;

//=================================== FUNCTIONS =====================================\\

  double calculateSubtotal() {
    return itemPrice * itemQuantity;
  }

//===================== Handle refresh ==========================\\

  Future<void> _handleRefresh() async {
    setState(() {
      _loadingScreen = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      OrderController.instance.runTask();
      VendorController.instance.runTask();
      RiderController.instance.runTask();
    });
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _loadingScreen = false;
    });
  }

//============================= Scroll to Top ======================================//
  void _scrollToTop() {
    _animationController.reverse();
    scrollController.animateTo(0,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  void _scrollListener() {
    //========= Show action button ========//
    if (scrollController.position.pixels >= 100) {
      _animationController.forward();
      setState(() => _isScrollToTopBtnVisible = true);
    }
    //========= Hide action button ========//
    else if (scrollController.position.pixels < 100) {
      _animationController.reverse();
      setState(() => _isScrollToTopBtnVisible = false);
    }
  }

//=================================== Navigation =====================================\\

  void _toSeeAllRiders() => Get.to(
        () => Riders(
          showNavigation: () {},
          hideNavigation: () {},
          appBarBackgroundColor: kAccentColor,
          appTitleColor: kPrimaryColor,
          appBarSearchIconColor: kPrimaryColor,
        ),
        duration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        curve: Curves.easeIn,
        routeName: "Riders",
        preventDuplicates: true,
        popGesture: true,
        transition: Transition.downToUp,
      );

  void _toSeeAllVendors() => Get.to(
        () => Vendors(
          showNavigation: () {},
          hideNavigation: () {},
          appBarBackgroundColor: kAccentColor,
          appTitleColor: kPrimaryColor,
          appBarSearchIconColor: kPrimaryColor,
        ),
        duration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        curve: Curves.easeIn,
        routeName: "Vendors",
        preventDuplicates: true,
        popGesture: true,
        transition: Transition.downToUp,
      );

  void _toSeeAllCompletedOrders(List<OrderItem> completed) => Get.to(
        () => AllCompletedOrders(completed: completed),
        duration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        curve: Curves.easeIn,
        routeName: "AllCompletedOrders",
        preventDuplicates: true,
        popGesture: true,
        transition: Transition.downToUp,
      );

  void _toSeeAllPendingOrders(List<OrderItem> orderList) => Get.to(
        () => PendingOrders(
          orderList: orderList,
        ),
        duration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        curve: Curves.easeIn,
        routeName: "PendingOrders",
        preventDuplicates: true,
        popGesture: true,
        transition: Transition.downToUp,
      );

  void _toSeeAllActiveOrders(List<OrderItem> orderList) => Get.to(
        () => ActiveOrders(
          orderList: orderList,
        ),
        duration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        curve: Curves.easeIn,
        routeName: "ActiveOrders",
        preventDuplicates: true,
        popGesture: true,
        transition: Transition.downToUp,
      );

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDateAndTime = formatDateAndTime(now);
    var media = MediaQuery.of(context).size;

    double subtotalPrice = calculateSubtotal();

//====================================================================================\\

    return Scaffold(
      appBar: const DashboardAppBar(numberOfNotifications: 4),
      floatingActionButton: _isScrollToTopBtnVisible
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              mini: deviceType(media.width) > 2 ? false : true,
              backgroundColor: kAccentColor,
              enableFeedback: true,
              mouseCursor: SystemMouseCursors.click,
              tooltip: "Scroll to top",
              hoverColor: kAccentColor,
              hoverElevation: 50.0,
              child: const FaIcon(FontAwesomeIcons.chevronUp, size: 18),
            )
          : const SizedBox(),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: kAccentColor,
          child: _loadingScreen
              ? const DashboardPageSkeleton()
              : Scrollbar(
                  controller: scrollController,
                  child: ListView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(kDefaultPadding),
                    children: [
                      GetBuilder<OrderController>(
                          init: OrderController(),
                          builder: (order) {
                            final active = order.orderList
                                .where((p0) =>
                                    !p0.deliveryStatus!
                                        .toLowerCase()
                                        .contains("COMP".toLowerCase()) &&
                                    p0.assignedStatus!
                                        .toLowerCase()
                                        .contains("ASSG".toLowerCase()))
                                .toList();
                            final pending = order.orderList
                                .where((p0) =>
                                    !p0.deliveryStatus!
                                        .toLowerCase()
                                        .contains("COMP".toLowerCase()) &&
                                    p0.assignedStatus!
                                        .toLowerCase()
                                        .contains("PEND".toLowerCase()))
                                .toList();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OrdersContainer(
                                  containerColor: kPrimaryColor,
                                  typeOfOrderColor: kTextGreyColor,
                                  iconColor: kLightGreyColor,
                                  numberOfOrders:
                                      intFormattedText(active.length),
                                  typeOfOrders: "Active",
                                  onTap: () => _toSeeAllActiveOrders(active),
                                ),
                                OrdersContainer(
                                  containerColor:
                                      // Colors.red.shade200,
                                      kAccentColor.withOpacity(0.4),
                                  typeOfOrderColor: kAccentColor,
                                  iconColor: kAccentColor,
                                  numberOfOrders:
                                      intFormattedText(pending.length),
                                  typeOfOrders: "Pending",
                                  onTap: () => _toSeeAllPendingOrders(pending),
                                ),
                              ],
                            );
                          }),
                      kSizedBox,
                      GetBuilder<OrderController>(
                          init: OrderController(),
                          builder: (order) {
                            final allCompletedOrders = order.orderList.toList();

                            return DasboardAllCompletedOrdersContainer(
                              onTap: () =>
                                  _toSeeAllCompletedOrders(allCompletedOrders),
                              number: allCompletedOrders.length,
                              typeOf: "All completed orders",
                            );
                          }),
                      kSizedBox,
                      GetBuilder<VendorController>(
                          init: VendorController(),
                          builder: (vendor) {
                            final allVendor = vendor.vendorList.toList();
                            final allOnlineVendor = vendor.vendorList
                                .where((p0) => p0.isOnline == true)
                                .toList();
                            return RiderVendorContainer(
                              onTap: _toSeeAllVendors,
                              number: intFormattedText(allVendor.length),
                              typeOf: "Vendors",
                              onlineStatus:
                                  "${intFormattedText(allOnlineVendor.length)} Online",
                            );
                          }),
                      kSizedBox,
                      GetBuilder<RiderController>(
                          init: RiderController(),
                          builder: (rider) {
                            final allRider = rider.riderList.toList();
                            // final allOnlineVendor = vendor.vendorList
                            //     .where((p0) => p0.isOnline == true)
                            //     .toList();
                            return RiderVendorContainer(
                              onTap: _toSeeAllRiders,
                              number: "${allRider.length}",
                              typeOf: "Riders",
                              onlineStatus: "32 Online",
                            );
                          }),
                      const SizedBox(height: kDefaultPadding * 2),
                      kSizedBox,
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
