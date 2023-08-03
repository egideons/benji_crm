// ignore_for_file: file_names, unused_local_variable

import 'package:benji_aggregator/app/others/item_detail_screen.dart';
import 'package:benji_aggregator/src/providers/constants.dart';
import 'package:benji_aggregator/src/providers/custom%20show%20search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/route_manager.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../src/common_widgets/category_button_section.dart';
import '../../src/common_widgets/my_appbar.dart';
import '../../src/common_widgets/vendors_product_container.dart';
import '../../theme/colors.dart';
import 'vendor_orders_tab.dart';
import 'vendor_products_tab.dart';

class VendorsDetailPage extends StatefulWidget {
  final String vendorCoverImage;
  final String vendorName;
  final double vendorRating;
  final String vendorActiveStatus;
  final Color vendorActiveStatusColor;
  const VendorsDetailPage({
    super.key,
    required this.vendorCoverImage,
    required this.vendorName,
    required this.vendorRating,
    required this.vendorActiveStatus,
    required this.vendorActiveStatusColor,
  });

  @override
  State<VendorsDetailPage> createState() => _VendorsDetailPageState();
}

class _VendorsDetailPageState extends State<VendorsDetailPage>
    with SingleTickerProviderStateMixin {
  //=================================== ALL VARIABLES ====================================\\
  late bool _loadingScreen;
  bool _isLoadingTabBarContent = false;

  //=================================== CONTROLLERS ====================================\\
  late TabController _tabBarController;

//===================== KEYS =======================\\
  // final _formKey = GlobalKey<FormState>();

//===================== BOOL VALUES =======================\\
  bool isLoading = false;

  //===================== CATEGORY BUTTONS =======================\\
  final List _categoryButtonText = [
    "Pasta",
    "Burgers",
    "Rice Dishes",
    "Chicken",
    "Snacks"
  ];

  final List<Color> _categoryButtonBgColor = [
    kAccentColor,
    kDefaultCategoryBackgroundColor,
    kDefaultCategoryBackgroundColor,
    kDefaultCategoryBackgroundColor,
    kDefaultCategoryBackgroundColor
  ];
  final List<Color> _categoryButtonFontColor = [
    kPrimaryColor,
    kTextGreyColor,
    kTextGreyColor,
    kTextGreyColor,
    kTextGreyColor
  ];

//===================== VENDORS LIST VIEW INDEX =======================\\
  List<int> foodListView = [0, 1, 3, 4, 5, 6];

//===================== FUNCTIONS =======================\\
  @override
  void initState() {
    _tabBarController = TabController(length: 2, vsync: this);
    _loadingScreen = true;
    Future.delayed(
      const Duration(seconds: 3),
      () => setState(
        () => _loadingScreen = false,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    super.dispose();
  }
//===================== Handle refresh ==========================\\

  Future<void> _handleRefresh() async {
    setState(() {
      _loadingScreen = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _loadingScreen = false;
    });
  }

  void _clickOnTabBarOption() async {
    setState(() {
      _isLoadingTabBarContent = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoadingTabBarContent = false;
    });
  }

  //===================== Navigation ==========================\\
  void toItemDetailScreen() => Get.to(
        () => const ItemDetailScreen(),
        duration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        curve: Curves.easeIn,
        routeName: "Item Details",
        preventDuplicates: true,
        popGesture: true,
        transition: Transition.rightToLeft,
      );

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;

    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: kAccentColor,
      borderWidth: 5.0,
      backgroundColor: kPrimaryColor,
      height: 150,
      animSpeedFactor: 2,
      showChildOpacityTransition: false,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: MyAppBar(
          title: "Vendor Details",
          elevation: 0.0,
          backgroundColor: kPrimaryColor,
          toolbarHeight: 40,
          actions: [
            IconButton(
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
              icon: Icon(
                Icons.search,
                color: kAccentColor,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_horiz,
                color: kAccentColor,
              ),
            ),
          ],
        ),
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: FutureBuilder(builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              Center(child: SpinKitDoubleBounce(color: kAccentColor));
            }
            if (snapshot.connectionState == ConnectionState.none) {
              const Center(
                child: Text("Please connect to the internet"),
              );
            }
            // if (snapshot.connectionState == snapshot.requireData) {
            //   SpinKitDoubleBounce(color: kAccentColor);
            // }
            if (snapshot.connectionState == snapshot.error) {
              const Center(
                child: Text("Error, Please try again later"),
              );
            }
            return _loadingScreen
                ? Center(child: SpinKitDoubleBounce(color: kAccentColor))
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    dragStartBehavior: DragStartBehavior.down,
                    children: [
                      SizedBox(
                        height: 340,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                        "assets/images/vendors/${widget.vendorCoverImage}.png"),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.13,
                              left: kDefaultPadding,
                              right: kDefaultPadding,
                              child: Container(
                                width: 200,
                                padding:
                                    const EdgeInsets.all(kDefaultPadding / 2),
                                decoration: ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      blurStyle: BlurStyle.normal,
                                    ),
                                  ],
                                  color: const Color(0xFFFEF8F8),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 0.50,
                                      color: Color(0xFFFDEDED),
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: kDefaultPadding * 2.6),
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.vendorName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(
                                            0xFF302F3C,
                                          ),
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      kHalfSizedBox,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: kAccentColor,
                                            size: 15,
                                          ),
                                          kHalfWidthSizedBox,
                                          const SizedBox(
                                            width: 300,
                                            child: Text(
                                              "Old Abakaliki Rd, Thinkers Corner 400103, Enugusdsudhosud",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      kHalfSizedBox,
                                      InkWell(
                                        onTap: (() async {
                                          final websiteurl = Uri.parse(
                                            "https://goo.gl/maps/8pKoBVCsew5oqjU49",
                                          );
                                          if (await canLaunchUrl(
                                            websiteurl,
                                          )) {
                                            launchUrl(
                                              websiteurl,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          } else {
                                            throw "An unexpected error occured and $websiteurl cannot be loaded";
                                          }
                                        }),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          width: mediaWidth / 4,
                                          padding: const EdgeInsets.all(
                                              kDefaultPadding / 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: kAccentColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: const Text(
                                            "Show on map",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                      kHalfSizedBox,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: 102,
                                            height: 56.67,
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  19,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.access_time_outlined,
                                                  color: kAccentColor,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                const Text(
                                                  "30 mins",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: -0.28,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 102,
                                            height: 56.67,
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  19,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  color: kStarColor,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "${widget.vendorRating}",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: -0.28,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 102,
                                            height: 56.67,
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(19),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  widget.vendorActiveStatus,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: widget
                                                        .vendorActiveStatusColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: -0.36,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Icon(
                                                  Icons.info_outline,
                                                  color: kAccentColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.07,
                              left: MediaQuery.of(context).size.width / 2.7,
                              child: Container(
                                width: 107,
                                height: 107,
                                decoration: ShapeDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      "assets/images/vendors/ntachi-osa-logo.png",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(43.50),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding),
                        child: Container(
                          width: mediaWidth,
                          decoration: BoxDecoration(
                            color: kDefaultCategoryBackgroundColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Column(
                            children: [
                              TabBar(
                                controller: _tabBarController,
                                onTap: (value) => _clickOnTabBarOption(),
                                enableFeedback: true,
                                mouseCursor: SystemMouseCursors.click,
                                automaticIndicatorColorAdjustment: true,
                                overlayColor:
                                    MaterialStatePropertyAll(kAccentColor),
                                labelColor: kPrimaryColor,
                                unselectedLabelColor: kTextGreyColor,
                                indicatorColor: kAccentColor,
                                indicatorWeight: 2,
                                splashBorderRadius: BorderRadius.circular(50),
                                indicator: BoxDecoration(
                                  color: kAccentColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                tabs: const [
                                  Tab(
                                    text: "Products",
                                  ),
                                  Tab(text: "Orders"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      kSizedBox,
                      SizedBox(
                        height: mediaHeight,
                        width: mediaWidth,
                        child: Column(
                          children: [
                            Expanded(
                              child: TabBarView(
                                controller: _tabBarController,
                                physics: const BouncingScrollPhysics(),
                                dragStartBehavior: DragStartBehavior.down,
                                children: [
                                  _isLoadingTabBarContent
                                      ? SpinKitDoubleBounce(color: kAccentColor)
                                      : VendorsProductsTab(
                                          list: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              CategoryButtonSection(
                                                onPressed: () {},
                                                category: _categoryButtonText,
                                                categorybgColor:
                                                    _categoryButtonBgColor,
                                                categoryFontColor:
                                                    _categoryButtonFontColor,
                                              ),
                                              for (int i = 0;
                                                  i < foodListView.length;
                                                  i++)
                                                VendorsProductContainer(
                                                  onTap: toItemDetailScreen,
                                                ),
                                            ],
                                          ),
                                        ),
                                  const VendorsOrdersTab(
                                    list: Column(
                                      children: [
                                        Text("Vendor Orders 1"),
                                        Text("Vendor Orders 2"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
          }),
        ),
      ),
    );
  }
}
