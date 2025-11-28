import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/order_list_screen/order_details_screen.dart';
import 'package:customer/app/wallet_screen/payment_list_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/wallet_controller.dart';
import 'package:customer/models/wallet_transaction_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: WalletController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            body: controller.isLoading.value
                ? Constant.loader()
                : Constant.userModel == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/login.gif",
                              height: 120,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Please Log In to Continue".tr,
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 22, fontFamily: AppThemeData.semiBold),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "You’re not logged in. Please sign in to access your account and explore all features.".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RoundedButtonFill(
                              title: "Log in".tr,
                              width: 55,
                              height: 5.5,
                              color: AppThemeData.primary300,
                              textColor: AppThemeData.grey50,
                              onPress: () async {
                                Get.offAll(const LoginScreen());
                              },
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "My Wallet".tr,
                                              style: TextStyle(
                                                fontSize: 24,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontFamily: AppThemeData.semiBold,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "Keep track of your balance, transactions, and payment methods all in one place.".tr,
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontFamily: AppThemeData.regular,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                        image: DecorationImage(image: AssetImage("assets/images/wallet.png"), fit: BoxFit.fill)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                      child: Column(
                                        children: [
                                          Text(
                                            "My Wallet".tr,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: themeChange.getThem() ? AppThemeData.primary100 : AppThemeData.primary100,
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: AppThemeData.regular,
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(amount: controller.userModel.value.walletAmount.toString()),
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50,
                                              fontSize: 40,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: AppThemeData.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 80),
                                            child: RoundedButtonFill(
                                              title: "Top up".tr,
                                              color: AppThemeData.warning300,
                                              textColor: AppThemeData.grey900,
                                              onPress: () {
                                                Get.to(const PaymentListScreen());
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: controller.walletTransactionList.isEmpty
                                  ? Constant.showEmptyView(message: "Transaction not found".tr)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: controller.walletTransactionList.length,
                                        itemBuilder: (context, index) {
                                          WalletTransactionModel walletTractionModel = controller.walletTransactionList[index];
                                          return transactionCard(controller, themeChange, walletTractionModel);
                                        },
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
          );
        });
  }

  transactionCard(WalletController controller, themeChange, WalletTransactionModel transactionModel) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            await FireStoreUtils.getOrderByOrderId(transactionModel.orderId.toString()).then(
              (value) {
                if (value != null) {
                  Get.to(const OrderDetailsScreen(), arguments: {"orderModel": value});
                }
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: transactionModel.isTopup == false
                        ? SvgPicture.asset(
                            "assets/icons/ic_debit.svg",
                            height: 16,
                            width: 16,
                          )
                        : SvgPicture.asset(
                            "assets/icons/ic_credit.svg",
                            height: 16,
                            width: 16,
                          ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              transactionModel.note.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w600,
                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                              ),
                            ),
                          ),
                          Text(
                            Constant.amountShow(amount: transactionModel.amount.toString()),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: AppThemeData.medium,
                              color: transactionModel.isTopup == true ? AppThemeData.success400 : AppThemeData.danger300,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        Constant.timestampToDateTime(transactionModel.date!),
                        style: TextStyle(
                            fontSize: 12, fontFamily: AppThemeData.medium, fontWeight: FontWeight.w500, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
        ),
      ],
    );
  }
}

enum PaymentGateway { payFast, mercadoPago, paypal, stripe, flutterWave, payStack, paytm, razorpay, cod, wallet, midTrans, orangeMoney, xendit }
