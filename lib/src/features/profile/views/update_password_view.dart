import 'package:books/src/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/utilities/base_change_notifier.dart';
import '../../../core/utilities/validation_extensions.dart';
import '../../../widgets/app_elevated_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/spacing.dart';
import '../notifiers/update_password_notifier.dart';

class UpdatePasswordView extends StatefulWidget {
  const UpdatePasswordView({Key? key}) : super(key: key);

  @override
  _UpdatePasswordViewState createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> {
  final _formKey = GlobalKey<FormState>();

  late final oldPasswordController = TextEditingController();
  late final newPasswordController = TextEditingController();

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding:
              const EdgeInsets.all(24.0) + MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacing.smallHeight(),
              Text(
                AppStrings.updatePassword,
                style: Theme.of(context).textTheme.headline6,
              ),
              const Spacing.smallHeight(),
              const Divider(color: Colors.black87),
              const Spacing.bigHeight(),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Consumer(
                      builder: (_, ScopedReader watch, __) {
                        final controller =
                            watch(updatePasswordNotifierProvider);

                        return AppTextField(
                          hintText: AppStrings.oldPassword,
                          keyboardType: TextInputType.visiblePassword,
                          controller: oldPasswordController,
                          obscureText: !controller.oldPasswordVisible,
                          suffixIcon: IconButton(
                            icon: controller.oldPasswordVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: controller.toggleOldPasswordVisibility,
                          ),
                          validator: context.validatePassword,
                        );
                      },
                    ),
                    const Spacing.bigHeight(),
                    Consumer(
                      builder: (_, ScopedReader watch, __) {
                        final controller =
                            watch(updatePasswordNotifierProvider);

                        return AppTextField(
                          hintText: AppStrings.newPassword,
                          controller: newPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !controller.newPasswordVisible,
                          suffixIcon: IconButton(
                            icon: controller.newPasswordVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: controller.toggleNewPasswordVisibility,
                          ),
                          validator: context.validatePassword,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Spacing.largeHeight(),
              Consumer(
                builder: (_, watch, __) => AppElevatedButton(
                  isLoading:
                      watch(updatePasswordNotifierProvider).state.isLoading,
                  label: AppStrings.updatePassword,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    if (_formKey.currentState!.validate()) {
                      await context
                          .read(updatePasswordNotifierProvider)
                          .updatePassword(
                            oldPasswordController.text,
                            newPasswordController.text,
                          );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
