// ignore_for_file: unused_local_variable, use_build_context_synchronously, unused_field, invalid_use_of_protected_member

import 'dart:io';

import 'package:benji_aggregator/controller/vendor_controller.dart';
import 'package:benji_aggregator/src/components/my_appbar.dart';
import 'package:benji_aggregator/theme/colors.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../src/providers/constants.dart';
import '../../../src/skeletons/vendors_list_skeleton.dart';
import '../../controller/latlng_detail_controller.dart';
import '../../model/create_vendor_model.dart';
import '../../services/keys.dart';
import '../../src/components/location_list_tile.dart';
import '../../src/components/message_textformfield.dart';
import '../../src/components/my_blue_textformfield.dart';
import '../../src/components/my_elevatedButton.dart';
import '../../src/components/my_fixed_snackBar.dart';
import '../../src/components/my_intl_phonefield.dart';
import '../../src/components/my_maps_textformfield.dart';
import '../../src/googleMaps/autocomplete_prediction.dart';
import '../../src/googleMaps/places_autocomplete_response.dart';
import '../../src/responsive/responsive_constant.dart';
import '../../src/utils/network_utils.dart';
import '../google_maps/get_location_on_map.dart';
import 'business_category_modal.dart';

class RegisterVendor extends StatefulWidget {
  const RegisterVendor({super.key});

  @override
  State<RegisterVendor> createState() => _RegisterVendorState();
}

class _RegisterVendorState extends State<RegisterVendor> {
  //==========================================================================================\\
  @override
  void initState() {
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      VendorController.instance.businessType();
    });
    super.initState();

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
    selectedLocation.dispose();
    _scrollController.dispose();
  }

//==========================================================================================\\

  //===================== ALL VARIABLES =======================\\
  String? latitude;
  String? longitude;
  String countryDialCode = '234';
  List<AutocompletePrediction> placePredictions = [];
  final selectedLocation = ValueNotifier<String?>(null);

  //======================================== GLOBAL KEYS ==============================================\\
  final _formKey = GlobalKey<FormState>();
  final _cscPickerKey = GlobalKey<CSCPickerState>();

  //===================== BOOL VALUES =======================\\
  bool _isScrollToTopBtnVisible = false;
  late bool _loadingScreen;
  final bool _savingChanges = false;
  bool _typing = false;

  //============================================== CONTROLLERS =================================================\\
  final _scrollController = ScrollController();

  final vendorPersonalIdEC = TextEditingController();
  final vendorBusinessIdEC = TextEditingController();
  final vendorNameEC = TextEditingController();
  final vendorEmailEC = TextEditingController();
  final vendorPhoneNumberEC = TextEditingController();
  final vendorAddressEC = TextEditingController();
  final vendorBusinessTypeEC = TextEditingController();
  final vendorBusinessBioEC = TextEditingController();
  final vendorMonToFriOpeningHoursEC = TextEditingController();
  final vendorSatOpeningHoursEC = TextEditingController();
  final vendorSunOpeningHoursEC = TextEditingController();
  final vendorMonToFriClosingHoursEC = TextEditingController();
  final vendorSatClosingHoursEC = TextEditingController();
  final vendorSunClosingHoursEC = TextEditingController();
  final mapsLocationEC = TextEditingController();
  final LatLngDetailController latLngDetailController =
      Get.put(LatLngDetailController());

  //=================================== FOCUS NODES ====================================\\
  final vendorPersonalIdFN = FocusNode();
  final vendorBusinessIdFN = FocusNode();
  final vendorNameFN = FocusNode();
  final vendorEmailFN = FocusNode();
  final vendorPhoneNumberFN = FocusNode();
  final vendorAddressFN = FocusNode();
  final vendorBusinessTypeFN = FocusNode();
  final vendorBusinessBioFN = FocusNode();
  final vendorMonToFriOpeningHoursFN = FocusNode();
  final vendorSatOpeningHoursFN = FocusNode();
  final vendorSunOpeningHoursFN = FocusNode();
  final vendorMonToFriClosingHoursFN = FocusNode();
  final vendorSatClosingHoursFN = FocusNode();
  final vendorSunClosingHoursFN = FocusNode();
  final _mapsLocationFN = FocusNode();

  //============================================= FUNCTIONS ===============================================\\

//Google Maps
  _setLocation(index) async {
    final newLocation = placePredictions[index].description!;
    selectedLocation.value = newLocation;

    setState(() {
      mapsLocationEC.text = newLocation;
    });

    List<Location> location = await locationFromAddress(newLocation);
    latitude = location[0].latitude.toString();
    longitude = location[0].longitude.toString();
  }

  void placeAutoComplete(String query) async {
    Uri uri = Uri.https(
        "maps.googleapis.com",
        '/maps/api/place/autocomplete/json', //unencoder path
        {
          "input": query, //query params
          "key": googlePlacesApiKey, //google places api key
        });

    String? response = await NetworkUtility.fetchUrl(uri);
    PlaceAutocompleteResponse result =
        PlaceAutocompleteResponse.parseAutoCompleteResult(response!);
    if (result.predictions != null) {
      setState(() {
        placePredictions = result.predictions!;
      });
    }
  }

  void _toGetLocationOnMap() async {
    await Get.to(
      () => const GetLocationOnMap(),
      routeName: 'GetLocationOnMap',
      duration: const Duration(milliseconds: 300),
      fullscreenDialog: true,
      curve: Curves.easeIn,
      preventDuplicates: true,
      popGesture: true,
      transition: Transition.rightToLeft,
    );
    latitude = latLngDetailController.latLngDetail.value[0];
    longitude = latLngDetailController.latLngDetail.value[1];
    mapsLocationEC.text = latLngDetailController.latLngDetail.value[2];
    latLngDetailController.setEmpty();
    if (kDebugMode) {
      print("LATLNG: $latitude,$longitude");
      print(mapsLocationEC.text);
    }
  }

//=========================== IMAGE PICKER ====================================\\

  final ImagePicker _picker = ImagePicker();
  File? selectedCoverImage;
  File? selectedLogoImage;
  String? country;
  String? state;
  String? city;
  String? shopType;
  String? shopTypeHint;
  //================================== function ====================================\\
  pickCoverImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
    );
    if (image != null) {
      selectedCoverImage = File(image.path);
      Get.back();
      setState(() {});
    }
  }

  pickLogoImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
    );
    if (image != null) {
      selectedLogoImage = File(image.path);
      Get.back();
      setState(() {});
    }
  }

  //========================== Save data ==================================\\
  Future<void> _saveChanges() async {
    if (country == null) {
      myFixedSnackBar(
        context,
        "please select country".toUpperCase(),
        kErrorColor,
        const Duration(seconds: 1),
      );
      return;
    }
    if (state == null) {
      myFixedSnackBar(
        context,
        "please select state".toUpperCase(),
        kErrorColor,
        const Duration(seconds: 1),
      );
      return;
    }
    if (city == null) {
      myFixedSnackBar(
        context,
        "please select city".toUpperCase(),
        kErrorColor,
        const Duration(seconds: 1),
      );
      return;
    }
    if (shopType == null) {
      myFixedSnackBar(
        context,
        "please select type of business".toUpperCase(),
        kErrorColor,
        const Duration(seconds: 1),
      );
      return;
    }
    SendCreateModel data = SendCreateModel(
      personaId: vendorPersonalIdEC.text,
      businessId: vendorBusinessIdEC.text,
      businessName: vendorNameEC.text,
      businessType: shopType,
      businessPhone: vendorPhoneNumberEC.text,
      bussinessAddress: mapsLocationEC.text,
      businessEmail: vendorEmailEC.text,
      country: country ?? "NG",
      state: state ?? "",
      city: city ?? "",
      openHours: vendorMonToFriOpeningHoursEC.text,
      closeHours: vendorMonToFriClosingHoursEC.text,
      satOpenHours: vendorSatOpeningHoursEC.text,
      satCloseHours: vendorSatClosingHoursEC.text,
      sunOpenHours: vendorSunOpeningHoursEC.text,
      sunCloseHours: vendorSunClosingHoursEC.text,
      businessBio: vendorBusinessBioEC.text,
      coverImage: selectedCoverImage,
      profileImage: selectedLogoImage,
    );
    // VendorController.instance.createVendor(data, true);

    // Simulating a delay of 3 seconds

    //Display snackBar
    // myFixedSnackBar(
    //   context,
    //   "Your changes have been saved successfully".toUpperCase(),
    //   kAccentColor,
    //   const Duration(seconds: 1),
    // );

    // Future.delayed(const Duration(seconds: 1), () {
    //   // Navigate to the new page
    //   Navigator.of(context).pop(context);

    //   setState(() {
    //     _savingChanges = false;
    //   });
    // });
  }

  //=========================== WIDGETS ====================================\\
  Widget uploadCoverImage() => Container(
        height: 140,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(
          left: kDefaultPadding,
          right: kDefaultPadding,
          bottom: kDefaultPadding,
        ),
        child: Column(
          children: <Widget>[
            const Text(
              "Upload Cover Image",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            kSizedBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        pickCoverImage(ImageSource.camera);
                      },
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              width: 0.5,
                              color: kLightGreyColor,
                            ),
                          ),
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.camera,
                            color: kAccentColor,
                          ),
                        ),
                      ),
                    ),
                    kHalfSizedBox,
                    const Text("Camera"),
                  ],
                ),
                kWidthSizedBox,
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        pickCoverImage(ImageSource.gallery);
                      },
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              width: 0.5,
                              color: kLightGreyColor,
                            ),
                          ),
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.image,
                            color: kAccentColor,
                          ),
                        ),
                      ),
                    ),
                    kHalfSizedBox,
                    const Text("Gallery"),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget uploadLogoImage() => Container(
        height: 140,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(
          left: kDefaultPadding,
          right: kDefaultPadding,
          bottom: kDefaultPadding,
        ),
        child: Column(
          children: <Widget>[
            const Text(
              "Upload Logo Image",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            kSizedBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        pickLogoImage(ImageSource.camera);
                      },
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              width: 0.5,
                              color: kLightGreyColor,
                            ),
                          ),
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.camera,
                            color: kAccentColor,
                          ),
                        ),
                      ),
                    ),
                    kHalfSizedBox,
                    const Text("Camera"),
                  ],
                ),
                kWidthSizedBox,
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        pickLogoImage(ImageSource.gallery);
                      },
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              width: 0.5,
                              color: kLightGreyColor,
                            ),
                          ),
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.image,
                            color: kAccentColor,
                          ),
                        ),
                      ),
                    ),
                    kHalfSizedBox,
                    const Text("Gallery"),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  //===================== Scroll to Top ==========================\\
  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      _isScrollToTopBtnVisible = false;
    });
  }

  Future<void> _scrollListener() async {
    if (_scrollController.position.pixels >= 100 &&
        _isScrollToTopBtnVisible != true) {
      setState(() {
        _isScrollToTopBtnVisible = true;
      });
    }
    if (_scrollController.position.pixels < 100 &&
        _isScrollToTopBtnVisible == true) {
      setState(() {
        _isScrollToTopBtnVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: (() => FocusManager.instance.primaryFocus?.unfocus()),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: MyAppBar(
          title: "Register a vendor",
          elevation: 0,
          actions: const [],
          backgroundColor: kPrimaryColor,
        ),
        bottomNavigationBar: GetBuilder<VendorController>(builder: (sending) {
          return sending.isLoadCreate.value
              ? Center(
                  child: CircularProgressIndicator(color: kAccentColor),
                )
              : Container(
                  color: kPrimaryColor,
                  padding: const EdgeInsets.only(
                    top: kDefaultPadding,
                    left: kDefaultPadding,
                    right: kDefaultPadding,
                    bottom: kDefaultPadding,
                  ),
                  child: MyElevatedButton(
                    onPressed: (() async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _saveChanges();
                      }
                    }),
                    title: "Save",
                  ),
                );
        }),
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
          child: FutureBuilder(
            future: null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                const VendorsListSkeleton();
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
              return Scrollbar(
                controller: _scrollController,
                radius: const Radius.circular(10),
                scrollbarOrientation: ScrollbarOrientation.right,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(kDefaultPadding),
                  children: [
                    const Text(
                      "Header content",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    kSizedBox,
                    DottedBorder(
                      color: kLightGreyColor,
                      borderPadding: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(kDefaultPadding / 2),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(20),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                elevation: 20,
                                barrierColor: kBlackColor.withOpacity(0.8),
                                showDragHandle: true,
                                useSafeArea: true,
                                isDismissible: true,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(kDefaultPadding),
                                  ),
                                ),
                                enableDrag: true,
                                builder: ((builder) => uploadCoverImage()),
                              );
                            },
                            splashColor: kAccentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            child: selectedCoverImage == null
                                ? Container(
                                    width: media.width,
                                    height: 144,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 0.50,
                                          color: Color(0xFFE6E6E6),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              "assets/icons/image-upload.png"),
                                          kHalfSizedBox,
                                          Text(
                                            'Upload cover image',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: kTextGreyColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: media.width,
                                    height: 144,
                                    decoration: ShapeDecoration(
                                      image: DecorationImage(
                                        image: FileImage(selectedCoverImage!),
                                        fit: BoxFit.cover,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 0.50,
                                          color: Color(0xFFE6E6E6),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                          ),
                          kSizedBox,
                          selectedLogoImage == null
                              ? InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      elevation: 20,
                                      barrierColor:
                                          kBlackColor.withOpacity(0.8),
                                      showDragHandle: true,
                                      useSafeArea: true,
                                      isDismissible: true,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(kDefaultPadding),
                                        ),
                                      ),
                                      enableDrag: true,
                                      builder: ((builder) => uploadLogoImage()),
                                    );
                                  },
                                  splashColor: kAccentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 144,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 0.50,
                                          color: Color(0xFFE6E6E6),
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: kTransparentColor,
                                            minRadius: 40,
                                            maxRadius: 50,
                                            child: Icon(
                                              Icons.image,
                                              color: kAccentColor,
                                            ),
                                          ),
                                          kHalfSizedBox,
                                          Text(
                                            'Upload your profile logo',
                                            style: TextStyle(
                                              color: kTextGreyColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: 200,
                                      decoration: ShapeDecoration(
                                        shape: const OvalBorder(),
                                        image: DecorationImage(
                                          image: FileImage(
                                            selectedLogoImage!,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    kSizedBox,
                    Form(
                      key: _formKey,
                      child: ValueListenableBuilder(
                          valueListenable: selectedLocation,
                          builder: (context, selectedLocationValue, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Personal Identification",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorPersonalIdEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorPersonalIdEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorPersonalIdFN,
                                  hintText: "Enter personal ID",
                                  textInputType: TextInputType.text,
                                ),
                                kSizedBox,
                                const Text(
                                  "Business Identification",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorBusinessIdEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorBusinessIdEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorBusinessIdFN,
                                  hintText:
                                      "Enter the business ID (if provided by the vendor)",
                                  textInputType: TextInputType.text,
                                ),
                                kSizedBox,
                                const Text(
                                  "Business Name",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorNameEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorNameEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorNameFN,
                                  hintText: "Enter the name of the business",
                                  textInputType: TextInputType.name,
                                ),
                                kSizedBox,
                                const Text(
                                  "Type of Business",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                GetBuilder<VendorController>(builder: (type) {
                                  return InkWell(
                                    onTap: () async {
                                      var data = await shopTypeModal(
                                          context, type.businessType);
                                      if (data != null) {
                                        setState(() {
                                          shopType = data.id.toString();
                                          shopTypeHint = data.name.toString();
                                        });
                                        //  consoleLog(data.name.toString());
                                      }
                                    },
                                    child: MyBlueTextFormField(
                                      controller: vendorBusinessTypeEC,
                                      isEnabled: false,
                                      validator: (value) {
                                        return null;
                                      },
                                      onSaved: (value) {},
                                      textInputAction: TextInputAction.next,
                                      focusNode: vendorBusinessTypeFN,
                                      hintText: shopTypeHint ??
                                          "E.g Restaurant, Auto Dealer, etc",
                                      textInputType: TextInputType.name,
                                    ),
                                  );
                                }),
                                kSizedBox,
                                const Text(
                                  "Business Email",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorEmailEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorEmailEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {},
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorEmailFN,
                                  hintText: "Enter the bussiness email",
                                  textInputType: TextInputType.emailAddress,
                                ),
                                kSizedBox,
                                const Text(
                                  "Business Phone Number",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyIntlPhoneField(
                                  controller: vendorPhoneNumberEC,
                                  initialCountryCode: "NG",
                                  invalidNumberMessage: "Invalid phone number",
                                  dropdownIconPosition: IconPosition.trailing,
                                  showCountryFlag: true,
                                  showDropdownIcon: true,
                                  dropdownIcon: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: kAccentColor,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorPhoneNumberFN,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorPhoneNumberEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {},
                                ),
                                kSizedBox,
                                const Text(
                                  "Business Address",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Location on Google maps',
                                      style: TextStyle(
                                        color: kTextBlackColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    kHalfSizedBox,
                                    MyMapsTextFormField(
                                      controller: mapsLocationEC,
                                      validator: (value) {
                                        if (value == null) {
                                          _mapsLocationFN.requestFocus();
                                          "Enter a location";
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        placeAutoComplete(value);
                                        setState(() {
                                          selectedLocation.value = value;
                                          _typing = true;
                                        });
                                        if (kDebugMode) {
                                          print(
                                              "ONCHANGED VALUE: ${selectedLocation.value}");
                                        }
                                      },
                                      textInputAction: TextInputAction.done,
                                      focusNode: _mapsLocationFN,
                                      hintText: "Search a location",
                                      textInputType: TextInputType.text,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(
                                            kDefaultPadding),
                                        child: FaIcon(
                                          FontAwesomeIcons.locationDot,
                                          color: kAccentColor,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    kSizedBox,
                                    Divider(
                                      height: 10,
                                      thickness: 2,
                                      color: kLightGreyColor,
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _toGetLocationOnMap,
                                      icon: FaIcon(
                                        FontAwesomeIcons.locationArrow,
                                        color: kAccentColor,
                                        size: 18,
                                      ),
                                      label: const Text("Locate on map"),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: kLightGreyColor,
                                        foregroundColor: kTextBlackColor,
                                        fixedSize: Size(media.width, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 10,
                                      thickness: 2,
                                      color: kLightGreyColor,
                                    ),
                                    const Text(
                                      "Suggestions:",
                                      style: TextStyle(
                                        color: kTextBlackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    kHalfSizedBox,
                                    SizedBox(
                                      height: () {
                                        if (_typing == false) {
                                          return 0.0;
                                        }
                                        if (_typing == true) {
                                          return 150.0;
                                        }
                                      }(),
                                      child: Scrollbar(
                                        controller: _scrollController,
                                        child: ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: placePredictions.length,
                                          itemBuilder: (context, index) =>
                                              LocationListTile(
                                            onTap: () => _setLocation(index),
                                            location: placePredictions[index]
                                                .description!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                kSizedBox,
                                const Text(
                                  "Localization",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                CSCPicker(
                                  key: _cscPickerKey,
                                  layout: Layout.vertical,
                                  countryDropdownLabel: "Select country",
                                  stateDropdownLabel: "Select state",
                                  cityDropdownLabel: "Select city",
                                  onCountryChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        country = value;
                                      });
                                    }
                                  },
                                  onStateChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        state = value;
                                      });
                                    }
                                  },
                                  onCityChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        city = value;
                                      });
                                    }
                                  },
                                ),
                                kSizedBox,
                                Center(
                                  child: Text(
                                    "Business hours".toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                kSizedBox,
                                const Center(
                                  child: Text(
                                    "Mondays to Fridays",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                kSizedBox,
                                const Text(
                                  "Opening hours",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorMonToFriOpeningHoursEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorMonToFriOpeningHoursEC
                                            .text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {},
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorMonToFriOpeningHoursFN,
                                  hintText: "00:00 AM",
                                  textInputType: TextInputType.text,
                                ),
                                kSizedBox,
                                const Text(
                                  "Closing hours",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorMonToFriClosingHoursEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorMonToFriClosingHoursEC
                                            .text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {},
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorMonToFriClosingHoursFN,
                                  hintText: "00:00 PM",
                                  textInputType: TextInputType.text,
                                ),
                                kSizedBox,
                                const Center(
                                  child: Text(
                                    "Saturdays",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                kSizedBox,
                                const Text(
                                  "Opening hours",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorSatOpeningHoursEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorSatOpeningHoursEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {},
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorSatOpeningHoursFN,
                                  hintText: "00:00 AM",
                                  textInputType: TextInputType.text,
                                ),
                                kSizedBox,
                                const Text(
                                  "Closing hours",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorSatClosingHoursEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorSatClosingHoursEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {},
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorSatClosingHoursFN,
                                  hintText: "00:00 PM",
                                  textInputType: TextInputType.text,
                                ),
                                kSizedBox,
                                const Center(
                                  child: Text(
                                    "Sundays",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                kSizedBox,
                                const Text(
                                  "Opening hours",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorSunOpeningHoursEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorSunOpeningHoursEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {},
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorSunOpeningHoursFN,
                                  hintText: "00:00 AM",
                                  textInputType: TextInputType.text,
                                ),
                                kSizedBox,
                                const Text(
                                  "Closing hours",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyBlueTextFormField(
                                  controller: vendorSunClosingHoursEC,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorSunClosingHoursEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {},
                                  textInputAction: TextInputAction.next,
                                  focusNode: vendorSunClosingHoursFN,
                                  hintText: "00:00 PM",
                                  textInputType: TextInputType.text,
                                ),
                                kSizedBox,
                                const Text(
                                  "Business Bio",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                kSizedBox,
                                MyMessageTextFormField(
                                  controller: vendorBusinessBioEC,
                                  textInputAction: TextInputAction.newline,
                                  focusNode: vendorBusinessBioFN,
                                  hintText: "About the business...",
                                  maxLines: 10,
                                  keyboardType: TextInputType.multiline,
                                  maxLength: 6000,
                                  validator: (value) {
                                    if (value == null ||
                                        vendorBusinessBioEC.text.isEmpty) {
                                      return "Field cannot be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {
                                    vendorBusinessBioEC.text = value;
                                  },
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
