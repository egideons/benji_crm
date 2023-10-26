// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';

import 'package:benji_aggregator/app/overview/overview.dart';
import 'package:benji_aggregator/controller/error_controller.dart';
import 'package:benji_aggregator/controller/user_controller.dart';
import 'package:benji_aggregator/model/login_model.dart';
import 'package:benji_aggregator/services/api_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  static LoginController get instance {
    return Get.find<LoginController>();
  }

  var isLoad = false.obs;

  Future<void> login(SendLogin data) async {
    Get.put(UserController());
    isLoad.value = true;
    update();
    Map finalData = {
      "username": data.username,
      "password": data.password,
    };

    http.Response? response =
        await HandleData.postApi(Api.baseUrl + Api.login, null, finalData);

    if (response == null || response.statusCode != 200) {
      ApiProcessorController.errorSnack("Invalid email or password. Try again");
      isLoad.value = false;
      update();
      return;
    }

    var jsonData = jsonDecode(response.body);

    if (jsonData["token"] == false) {
      ApiProcessorController.errorSnack("Invalid email or password. Try again");
      isLoad.value = false;
      update();
    } else {
      http.Response? responseUser =
          await HandleData.getApi(Api.baseUrl + Api.user, jsonData["token"]);
      if (responseUser == null || response.statusCode != 200) {
        ApiProcessorController.errorSnack(
            "Invalid email or password. Try again");
        isLoad.value = false;
        update();
        return;
      }
      UserController.instance.saveUser(responseUser.body, jsonData["token"]);
      ApiProcessorController.successSnack("Login Successful");
      consoleLog("Here is your token oo ${jsonData["token"]}");
      Get.offAll(
        () => OverView(),
        fullscreenDialog: true,
        curve: Curves.easeIn,
        routeName: "OverView",
        predicate: (route) => true,
        popGesture: true,
        transition: Transition.cupertinoDialog,
      );
      return;
    }

    isLoad.value = false;
    update();
  }
}
