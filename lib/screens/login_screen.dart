import 'package:flora/constants/images.dart';
import 'package:flora/providers/auth_providers.dart';
import 'package:flora/themes/colors.dart';
import 'package:flora/themes/styles.dart';
import 'package:flora/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flora/constants/app_helpers.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  PageController _pageController = PageController();
  List images = [
    {'image': woman, 'title': 'Chat with friends & family'},
    {'image': woman, 'title': 'Chat with friends & family'},
    {'image': woman, 'title': 'Chat with friends & family'},
  ];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    startanimation();
  }

  void startanimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_pageController.hasClients) {
        if (_pageController.page!.round() == images.length - 1) {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn);
        } else {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Flo',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maincolor,
                  ),
                  children: [
                    TextSpan(
                      text: 'ra',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.googlebuttonColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppHelpers.kdefaultPadding * 4),
              Expanded(
                  child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: ((context, index) {
                        return Column(
                          children: [
                            Image.asset(images[index]['image']),
                            const SizedBox(height: AppHelpers.kdefaultPadding),
                            Text(
                              images[index]['title'],
                              style: TextStyles.mainText,
                            ),
                          ],
                        );
                      })),
                  flex: 1),
              const SizedBox(height: AppHelpers.kdefaultPadding),
              Wrap(
                spacing: 3,
                children:
                    List.generate(images.length, (index) => buildDots(index)),
              ),
              const SizedBox(height: AppHelpers.kdefaultPadding),
              Column(
                children: [
                  CustomButtom(
                      onPressed: () {
                        auth.signInWithGoogle(context: context);
                      },
                      color: AppColors.googlebuttonColor,
                      icon: FlutterIcons.google_mco,
                      text: 'Login with Google'),
                  const SizedBox(height: AppHelpers.kdefaultPadding),
                  CustomButtom(
                      onPressed: () {},
                      icon: FlutterIcons.apple1_ant,
                      color: AppColors.facebookbuttonColor,
                      text: 'Login with Apple'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDots(int index) {
    return Container(
      height: 6,
      width: 6,
      decoration: BoxDecoration(
        color: currentIndex == index ? AppColors.maincolor : Colors.grey,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
