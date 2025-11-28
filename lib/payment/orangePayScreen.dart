// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:customer/models/payment_model/orange_money.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class OrangeMoneyScreen extends StatefulWidget {
  String initialURl;
  OrangeMoney orangePay;
  String accessToken = '';
  String payToken = '';
  String orderId = '';
  String amount = '';

  OrangeMoneyScreen({
    super.key,
    required this.initialURl,
    required this.orangePay,
    required this.accessToken,
    required this.payToken,
    required this.orderId,
    required this.amount,
  });

  @override
  State<OrangeMoneyScreen> createState() => _OrangeMoneyScreenState();
}

class _OrangeMoneyScreenState extends State<OrangeMoneyScreen> {
  WebViewController controller = WebViewController();
  bool isLoading = true;

  @override
  void initState() {
    controller.clearCache();
    initController();
    callTransaction();
    super.initState();
  }

  Timer? timer;

  callTransaction() {
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      if (mounted) {
        transactionstatus(accessToken: widget.accessToken, amount: widget.amount, orderId: widget.orderId, payToken: widget.payToken).then((value) {
          if (value == 'SUCCESS') {
            if (timer != null) {
              timer!.cancel();
            }
            Get.back(result: true);
          } else if (value == 'FAILED') {
            if (timer != null) {
              timer!.cancel();
            }
            Get.back(result: false);
          }
        });
      }
    });
  }

  initController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: ((url) {
            setState(() {
              isLoading = false;
            });
          }),
          onNavigationRequest: (NavigationRequest navigation) async {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialURl));
  }

  Future transactionstatus({
    required String orderId,
    required String amount,
    required String payToken,
    required String accessToken,
  }) async {
    String apiUrl = widget.orangePay.isSandbox == true
        ? 'https://api.orange.com/orange-money-webpay/dev/v1/transactionstatus'
        : 'https://api.orange.com/orange-money-webpay/cm/v1/transactionstatus';
    Map<String, String> requestBody = {
      "order_id": orderId,
      "amount": amount, // "OUV",
      "pay_token": payToken
    };

    var response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody));

    // Handle the response
    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['status'];
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        _showMyDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            centerTitle: false,
            leading: GestureDetector(
              onTap: () {
                _showMyDialog();
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            )),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : WebViewWidget(controller: controller),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Payment'.tr),
          content: SingleChildScrollView(
            child: Text("cancelPayment?".tr),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel'.tr,
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Get.back(result: false);
                Get.back(result: false);
              },
            ),
            TextButton(
              child: Text(
                'Continue'.tr,
                style: const TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Get.back(result: false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }
}
