// ignore_for_file: file_names, unused_local_variable, unused_field

import 'package:benji_aggregator/controller/rider_history_controller.dart';
import 'package:benji_aggregator/src/components/appbar/my_appbar.dart';
import 'package:benji_aggregator/src/components/card/empty.dart';
import 'package:benji_aggregator/src/components/image/my_image.dart';
import 'package:benji_aggregator/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../controller/url_launch_controller.dart';
import '../../model/rider_model.dart';
import '../../src/components/button/my_outlined_elevatedButton.dart';
import '../../src/components/section/my_liquid_refresh.dart';
import '../../src/utils/constants.dart';
import 'report_rider.dart';

class RidersDetail extends StatefulWidget {
  final RiderItem rider;
  const RidersDetail({super.key, required this.rider});

  @override
  State<RidersDetail> createState() => _RidersDetailState();
}

class _RidersDetailState extends State<RidersDetail> {
  //===================== Initial State ==========================\\
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  //============================ ALL VARIABLES =============================\\
  late bool _loadingScreen;

  bool isScrollToTopBtnVisible = false;

  //============================================== CONTROLLERS =================================================\\
  final ScrollController scrollController = ScrollController();

  //============================ FUNCTIONS =============================\\
  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _scrollListener() async {
    if (scrollController.position.pixels >= 200 &&
        isScrollToTopBtnVisible != true) {
      setState(() {
        isScrollToTopBtnVisible = true;
      });
    }
    if (scrollController.position.pixels < 200 &&
        isScrollToTopBtnVisible == true) {
      setState(() {
        isScrollToTopBtnVisible = false;
      });
    }

    if (RiderHistoryController.instance.loadedAll.value) {
      return;
    }

    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      await RiderHistoryController.instance.loadMore(widget.rider.id);
    }
  }

//===================== Handle refresh ==========================\\

  Future<void> handleRefresh() async {
    RiderHistoryController.instance.emptyRiderHistoryList();
    await RiderHistoryController.instance.riderHistory(widget.rider.id);
  }
//==========================================================================================\\

//=========================================== Navigation ===============================================\\

  void toReportRider() => Get.to(
        () => ReportRider(rider: widget.rider),
        duration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        curve: Curves.easeIn,
        routeName: "ReportRider",
        preventDuplicates: true,
        popGesture: true,
        transition: Transition.rightToLeft,
      );

//=====================================================================================\\

  //=================================== Show Popup Menu =====================================\\
  //Show popup menu
  void showPopupMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    const position = RelativeRect.fromLTRB(10, 60, 0, 0);

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        const PopupMenuItem<String>(
          value: 'report',
          child: Text("Report rider"),
        ),
      ],
    ).then((value) {
      // Handle the selected value from the popup menu
      if (value != null) {
        switch (value) {
          case 'report':
            toReportRider();
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDateAndTime = formatDateAndTime(now);
    var media = MediaQuery.of(context).size;

    // void seeDeliveryMessage() => showModalBottomSheet(
    //       context: context,
    //       isScrollControlled: true,
    //       elevation: 20,
    //       barrierColor: kBlackColor.withOpacity(0.6),
    //       showDragHandle: true,
    //       useSafeArea: true,
    //       isDismissible: true,
    //       shape: const RoundedRectangleBorder(
    //         borderRadius:
    //             BorderRadius.vertical(top: Radius.circular(kDefaultPadding)),
    //       ),
    //       enableDrag: true,
    //       builder: (context) => SizedBox(
    //         height: 80,
    //         child: Center(
    //           child: Text(
    //             message,
    //             style: TextStyle(
    //               fontSize: 20,
    //               color: messageColor,
    //               fontWeight: FontWeight.w500,
    //             ),
    //           ),
    //         ),
    //       ),
    //     );

    //====================================================================\\
    return MyLiquidRefresh(
      onRefresh: handleRefresh,
      child: Scaffold(
        appBar: MyAppBar(
          title: isScrollToTopBtnVisible
              ? "${widget.rider.firstName} ${widget.rider.lastName}"
              : "Riders Details",
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => showPopupMenu(context),
              icon: FaIcon(
                FontAwesomeIcons.ellipsisVertical,
                color: kAccentColor,
              ),
            ),
          ],
          backgroundColor: kPrimaryColor,
        ),
        floatingActionButton: isScrollToTopBtnVisible
            ? FloatingActionButton(
                onPressed: scrollToTop,
                mini: true,
                backgroundColor: kAccentColor,
                foregroundColor: kPrimaryColor,
                enableFeedback: true,
                mouseCursor: SystemMouseCursors.click,
                tooltip: "Scroll to top",
                hoverColor: kAccentColor,
                hoverElevation: 50.0,
                child: const FaIcon(FontAwesomeIcons.chevronUp, size: 18),
              )
            : const SizedBox(),
        body: SafeArea(
          child: GetBuilder<RiderHistoryController>(initState: (state) async {
            await RiderHistoryController.instance.riderHistory(widget.rider.id);
          }, builder: (riderController) {
            return Scrollbar(
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(kDefaultPadding),
                children: [
                  kSizedBox,
                  Container(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    decoration: ShapeDecoration(
                      color: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 24,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: kLightGreyColor,
                              child: ClipOval(
                                child: MyImage(url: widget.rider.image),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding / 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: media.width - 250,
                                child: Text(
                                  "${widget.rider.firstName} ${widget.rider.lastName}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              kHalfSizedBox,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.phone,
                                    color: kAccentColor,
                                    size: 18,
                                  ),
                                  kHalfWidthSizedBox,
                                  SizedBox(
                                    width: media.width - 250,
                                    child: Text(
                                      widget.rider.phone,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: kTextGreyColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              kHalfSizedBox,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.route,
                                    color: kAccentColor,
                                    size: 18,
                                  ),
                                  kHalfWidthSizedBox,
                                  SizedBox(
                                    width: media.width - 250,
                                    child: Text(
                                      "${widget.rider.tripCount} Trips Completed",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: kTextGreyColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              kHalfSizedBox,
                              MyOutlinedElevatedButton(
                                onPressed: () =>
                                    UrlLaunchController.makePhoneCall(
                                  widget.rider.phone,
                                ),
                                // circularBorderRadius: 16,
                                // minimumSizeWidth: 100,
                                // minimumSizeHeight: 30,
                                // maximumSizeWidth: 100,
                                // maximumSizeHeight: 30,
                                title: "Call",
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  const Text(
                    "Delivery History",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  kHalfSizedBox,
                  riderController.isLoad.value == true
                      ? Center(
                          child: CircularProgressIndicator(
                            color: kAccentColor,
                          ),
                        )
                      : riderController.historyList.isEmpty
                          ? const EmptyCard()
                          : ListView.separated(
                              separatorBuilder: (context, index) => kSizedBox,
                              itemCount: riderController.historyList.length,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) => Column(
                                children: [
                                  Container(
                                    decoration: ShapeDecoration(
                                      color: kPrimaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      shadows: const [
                                        BoxShadow(
                                          color: Color(0x0F000000),
                                          blurRadius: 24,
                                          offset: Offset(0, 4),
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            // width: 110,
                                            height: 120,
                                            decoration: const ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                ),
                                              ),
                                            ),
                                            child: MyImage(
                                              url: widget.rider.image,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 7,
                                              horizontal: 12,
                                            ),
                                            child: Column(
                                              // mainAxisAlignment:
                                              //     MainAxisAlignment.start,
                                              // crossAxisAlignment:
                                              //     CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'ID: ${riderController.historyList[index].order.code}',
                                                      style: const TextStyle(
                                                        color: kTextBlackColor,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    Container(
                                                      // width: 68,
                                                      // height: 24,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 7,
                                                          vertical: 5),
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side:
                                                              const BorderSide(
                                                            width: 0.50,
                                                            color: Color(
                                                                0xFFC8C8C8),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      child: SizedBox(
                                                        child: Text(
                                                          riderController
                                                              .historyList[
                                                                  index]
                                                              .deliveryStatus,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: riderController
                                                                    .historyList[
                                                                        index]
                                                                    .deliveryStatus
                                                                    .contains(
                                                                        "delivered")
                                                                ? kSuccessColor
                                                                : riderController
                                                                        .historyList[
                                                                            index]
                                                                        .deliveryStatus
                                                                        .contains(
                                                                            "processing")
                                                                    ? kAccentColor
                                                                    : kSecondaryColor,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                // Text(
                                                //   ,
                                                //   style: TextStyle(
                                                //     color: kTextGreyColor,
                                                //     fontSize: 12,
                                                //     fontWeight: FontWeight.w400,
                                                //   ),
                                                // ),
                                                kHalfSizedBox,
                                                // Row(
                                                //   children: [
                                                //     Column(
                                                //       mainAxisAlignment:
                                                //           MainAxisAlignment
                                                //               .center,
                                                //       children: [
                                                //         Container(
                                                //           height: 12,
                                                //           width: 12,
                                                //           padding:
                                                //               const EdgeInsets
                                                //                   .all(2),
                                                //           decoration:
                                                //               ShapeDecoration(
                                                //             shape: OvalBorder(
                                                //               side: BorderSide(
                                                //                 width: 1,
                                                //                 color:
                                                //                     kAccentColor,
                                                //               ),
                                                //             ),
                                                //           ),
                                                //           child: Container(
                                                //             decoration:
                                                //                 BoxDecoration(
                                                //               color:
                                                //                   kAccentColor,
                                                //               borderRadius:
                                                //                   BorderRadius
                                                //                       .circular(
                                                //                           8),
                                                //             ),
                                                //           ),
                                                //         ),
                                                //         Container(
                                                //           color: kAccentColor,
                                                //           height: 10,
                                                //           width: 1.5,
                                                //         ),
                                                //         FaIcon(
                                                //           FontAwesomeIcons
                                                //               .locationDot,
                                                //           size: 12,
                                                //           color: kAccentColor,
                                                //         ),
                                                //       ],
                                                //     ),
                                                //     kHalfWidthSizedBox,
                                                // Expanded(
                                                //   child: Column(
                                                //     mainAxisAlignment:
                                                //         MainAxisAlignment
                                                //             .start,
                                                //     crossAxisAlignment:
                                                //         CrossAxisAlignment
                                                //             .start,
                                                //     children: [
                                                //       Text(
                                                //         '21 Bartus Street, Abuja Nigeria',
                                                //         style: TextStyle(
                                                //           color:
                                                //               kTextGreyColor,
                                                //           fontSize: 10,
                                                //           height: 2,
                                                //           fontWeight:
                                                //               FontWeight
                                                //                   .w400,
                                                //         ),
                                                //       ),
                                                //       Text(
                                                //         '3 Edwins Close, Wuse, Abuja',
                                                //         style: TextStyle(
                                                //           color:
                                                //               kTextGreyColor,
                                                //           fontSize: 10,
                                                //           height: 2,
                                                //           fontWeight:
                                                //               FontWeight
                                                //                   .w400,
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ),
                                                // ],
                                                // ),
                                                const SizedBox(width: 22),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        riderController
                                                            .historyList[index]
                                                            .createdDate,
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF929292),
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      child: Text(
                                                        '\u20A6 ${doubleFormattedText(riderController.historyList[index].order.totalPrice)}',
                                                        style: TextStyle(
                                                          color: kTextGreyColor,
                                                          fontSize: 10,
                                                          fontFamily: 'sen',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  kSizedBox,
                  RiderHistoryController.instance.loadedAll.value
                      ? Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 20),
                          height: 10,
                          width: 10,
                          decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kPageSkeletonColor),
                        )
                      : const SizedBox(),
                  RiderHistoryController.instance.isLoadMore.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: kAccentColor,
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
