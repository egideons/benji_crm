import 'package:benji_aggregator/src/components/my_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import '../../../src/components/my_elevatedButton.dart';
import '../../../src/components/my_textformfield2.dart';
import '../../../src/providers/constants.dart';
import '../../../src/responsive/my_reponsive_width.dart';
import '../../../theme/colors.dart';

class AddBankAccountPage extends StatefulWidget {
  const AddBankAccountPage({Key? key}) : super(key: key);

  @override
  State<AddBankAccountPage> createState() => _AddBankAccountPageState();
}

class _AddBankAccountPageState extends State<AddBankAccountPage> {
//===================================== ALL VARIABLES =========================================\\
  final FocusNode _bankNames = FocusNode();
  final FocusNode _accountNumberFN = FocusNode();
  final TextEditingController _accountNumberEC = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String dropDownItemValue = "Access Bank";

  //================================== FUNCTION ====================================\\

  void dropDownOnChanged(String? onChanged) {
    setState(() {
      dropDownItemValue = onChanged!;
    });
  }

  //=================================== Navigation ============================\\
  void _saveAccount() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (() => FocusManager.instance.primaryFocus?.unfocus()),
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        appBar: MyAppBar(
          title: "Add bank account",
          elevation: 0.0,
          actions: const [],
          backgroundColor: kPrimaryColor,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: MyResponsiveWidth(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding, vertical: kDefaultPadding * 2),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank Details',
                        style: TextStyle(
                          color: kTextBlackColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                      kSizedBox,
                      kSizedBox,
                      Text(
                        'Bank Name',
                        style: TextStyle(
                          color: kTextGreyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      kHalfSizedBox,
                      DropdownButtonFormField<String>(
                        value: dropDownItemValue,
                        onChanged: dropDownOnChanged,
                        enableFeedback: true,
                        focusNode: _bankNames,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        elevation: 20,
                        validator: (value) {
                          if (value == null) {
                            _bankNames.requestFocus();
                            return "Pick an account";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue.shade50),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue.shade50),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue.shade50),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: kErrorBorderColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                        ),
                        iconEnabledColor: kAccentColor,
                        iconDisabledColor: kGreyColor2,
                        items: [
                          DropdownMenuItem<String>(
                            value: "Access Bank",
                            enabled: true,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/accessbank.png',
                                  height: 45,
                                  width: 45,
                                ),
                                const Text(
                                  'Access Bank',
                                  style: TextStyle(
                                    color: kTextBlackColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: "UBA",
                            enabled: true,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/accessbank.png',
                                  height: 45,
                                  width: 45,
                                ),
                                const Text(
                                  'UBA',
                                  style: TextStyle(
                                    color: kTextBlackColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: "FCMB",
                            enabled: true,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/accessbank.png',
                                  height: 45,
                                  width: 45,
                                ),
                                const Text(
                                  'FCMB',
                                  style: TextStyle(
                                    color: kTextBlackColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: "First Bank",
                            enabled: true,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/accessbank.png',
                                  height: 45,
                                  width: 45,
                                ),
                                const Text(
                                  'First Bank',
                                  style: TextStyle(
                                    color: kTextBlackColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: kDefaultPadding * 2,
                      ),
                      const Text(
                        'Account Number',
                        style: TextStyle(
                          color: Color(0xFF575757),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      kHalfSizedBox,
                      MyTextFormField2(
                        controller: _accountNumberEC,
                        focusNode: _accountNumberFN,
                        hintText: "Enter the account number here",
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value!.isEmpty) {
                            _accountNumberFN.requestFocus();
                            return "Enter the account number";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _accountNumberEC.text = value!;
                        },
                      ),
                      kSizedBox,
                      Text(
                        'Blessing Mesoma',
                        style: TextStyle(
                          color: kAccentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: kDefaultPadding * 4,
                      ),
                      MyElevatedButton(
                        onPressed: _saveAccount,
                        title: "Save Account",
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}