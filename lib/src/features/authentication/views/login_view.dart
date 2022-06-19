import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/images.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utilities/base_change_notifier.dart';
import '../../../core/utilities/validation_extensions.dart';
import '../../../widgets/app_elevated_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/responsive_dialog.dart';
import '../../../widgets/spacing.dart';
import '../../../widgets/statusbar.dart';
import '../notifiers/login_notifier.dart';
import 'forgot_password_view.dart';

class LoginView extends HookWidget {
  LoginView({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final emailAddressController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Statusbar(
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 767,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacing.largeHeight(),
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          AppStrings.login,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        const Spacing.largeHeight(),
                        AppTextField(
                          hintText: AppStrings.emailAddress,
                          controller: emailAddressController,
                          keyboardType: TextInputType.emailAddress,
                          validator: context.validateEmailAddress,
                        ),
                        const Spacing.bigHeight(),
                        Consumer(
                          builder: (context, watch, child) {
                            final loginNotifier = watch(loginNotifierProvider);

                            return AppTextField(
                              hintText: AppStrings.password,
                              controller: passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !loginNotifier.passwordVisible,
                              suffixIcon: IconButton(
                                icon: loginNotifier.passwordVisible
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                                onPressed:
                                    loginNotifier.togglePasswordVisibility,
                              ),
                              validator: context.validatePassword,
                            );
                          },
                        ),
                        const Spacing.smallHeight(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => const ResponsiveDialog(
                                child: ForgotPasswordView(),
                              ),
                            ),
                            child: const Text(AppStrings.forgotPassword),
                          ),
                        ),
                        const Spacing.smallHeight(),
                      ],
                    ),
                    const Spacing.mediumHeight(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Consumer(
                            builder: (_, watch, __) => AppElevatedButton(
                              isLoading:
                                  watch(loginNotifierProvider).state.isLoading,
                              label: AppStrings.login,
                              onPressed: () async {
                                FocusScope.of(context).unfocus();

                                if (_formKey.currentState!.validate()) {
                                  await context
                                      .read(loginNotifierProvider)
                                      .loginUser(
                                        emailAddress:
                                            emailAddressController.text,
                                        password: passwordController.text,
                                      );
                                }
                              },
                            ),
                          ),
                          const Spacing.mediumHeight(),
                          ElevatedButton.icon(
                            icon: Image.asset(AppImages.googleLogo, width: 24),
                            onPressed: () => context
                                .read(loginNotifierProvider)
                                .loginUserWithGoogle(),
                            label: Text(
                              AppStrings.signinWithGoogle,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          const Spacing.smallHeight(),
                          TextButton(
                            onPressed: () {
                              context
                                  .read(loginNotifierProvider)
                                  .navigateToRegister();
                            },
                            child: const Text(AppStrings.noAccount),
                          ),
                          const Spacing.smallHeight(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
