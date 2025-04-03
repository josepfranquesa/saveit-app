// ignore_for_file: use_build_context_synchronously

import 'package:SaveIt/presentation/transactions/transaction_register_screen.dart';
import 'package:SaveIt/providers/register_form_provider.dart';
import 'package:SaveIt/utils/helpers/utils_functions.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:SaveIt/utils/ui/widgets/saveit_input.dart';
import 'package:SaveIt/utils/ui/widgets/saveit_selector.dart';
import 'package:SaveIt/utils/ui/widgets/filled_simple_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider.of<RegisterFormProvider>(context, listen: false).initForm();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.principal,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            currentFocus.unfocus();
          },
          child: Consumer<RegisterFormProvider>(
              builder: (context, registerFormProvider, __) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox( height: 40 ,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Image.asset(
                            'assets/images/logo_login.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox( height: 30 ,),
                        Text(
                          'Registrate',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 50),
                        SaveitInput(
                            placeholder: "Nombre",
                            textInputType: TextInputType.name,
                            initialValue: registerFormProvider.name,
                            onChanged: (value) => registerFormProvider.setName(value)
                        ),
                        const SizedBox(height: 10),
                        SaveitInput(
                          placeholder: "Teléfono",
                          textInputType: TextInputType.phone,
                          onChanged: (value) => registerFormProvider.setPhoneNumber(value),
                          initialValue: registerFormProvider.phone,
                          validator: (value) {
                            String pattern = r"^[0-9]{9}$";
                            RegExp regExp = RegExp(pattern);
                            return regExp.hasMatch(value ?? '')
                                ? null
                                : 'El valor introducido no es un teléfono válido';
                          },
                        ),
                        const SizedBox(height: 10),
                        SaveitInput(
                          placeholder: "Correo electrónico",
                          textInputType: TextInputType.emailAddress,
                          initialValue: registerFormProvider.email,
                          onChanged: (value) => registerFormProvider.setEmail(value),
                          validator: (value) {
                            String pattern = r"^[\w\-\.]+@([\w-]+\.)+[\w-]{2,4}$";
                            RegExp regExp = RegExp(pattern);
                            return regExp.hasMatch(value ?? '')
                                ? null
                                : 'El valor introducido no es un correo electrónico';
                          },
                        ),
                        const SizedBox(height: 10),
                        SaveitInput(
                          placeholder: "Contraseña",
                          textInputType: TextInputType.text,
                          isPassword: !registerFormProvider.show_password,
                          initialValue: registerFormProvider.password,
                          onChanged: (value) => registerFormProvider.setPassword(value),
                          suffixIcon: IconButton(
                            icon: Icon(
                              registerFormProvider.show_password ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.principal,
                            ),
                            onPressed: () {
                              registerFormProvider.showPassword = !registerFormProvider.show_password;
                            },
                            splashColor: Colors.transparent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SaveitInput(
                          placeholder: "Repite tu contraseña",
                          textInputType: TextInputType.text,
                          isPassword: !registerFormProvider.show_password,
                          initialValue: registerFormProvider.repeat_password,
                          onChanged: (value) => registerFormProvider.setRepeatPassword(value),
                          suffixIcon: IconButton(
                            icon: Icon(
                              registerFormProvider.show_password ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.principal,
                            ),
                            onPressed: () {
                              registerFormProvider.showPassword = !registerFormProvider.show_password;
                            },
                            splashColor: Colors.transparent,
                          ),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        // errorText(registerFormProvider, context),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Opacity(
                            opacity: registerFormProvider.isLoading || !registerFormProvider.isValidForm() ? 0.5 : 1,
                            child: FilledSimpleButton(
                              text: registerFormProvider.isLoading ? 'Registrándome ...' : 'Registrarme',
                              onPressedFunction: registerFormProvider.isLoading || !registerFormProvider.isValidForm()
                                  ? (ctx) {
                              }
                                  : (ctx) async {
                                FocusScope.of(context).unfocus();
                                var resp = await registerFormProvider.register(context);
                                if(resp.isNotEmpty){
                                  AppUtils.toast(context, title: resp[0], type: resp[1]);
                                } else {
                                  AppUtils.toast(context, title: 'Bienvenid@', type: 'success');
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => TransactionRegisterScreen(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          // Calculate width based on screen size
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '¿Ya tienes cuenta?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ],
                    ),
                  ),
                );
              }
          ),
        ),
      ),
    );
  }
}