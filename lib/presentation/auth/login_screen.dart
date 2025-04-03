// ignore_for_file: use_build_context_synchronously

import 'package:SaveIt/presentation/auth/register_screen.dart';
import 'package:SaveIt/presentation/transactions/transaction_register_screen.dart';
import 'package:SaveIt/providers/login_form_provider.dart';
import 'package:SaveIt/utils/helpers/utils_functions.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:SaveIt/utils/ui/widgets/saveit_input.dart';
import 'package:SaveIt/utils/ui/widgets/filled_simple_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Provider.of<LoginFormProvider>(context, listen: false).initForm();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.principal,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            currentFocus.unfocus();
          },
          child: Consumer<LoginFormProvider>(
              builder: (context, loginFormProvider, __) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox( height: 50 ,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Image.asset(
                            'assets/images/logo_login.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Text(
                          'Inicia sesión para continuar',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 50),
                        SaveitInput(
                          placeholder: "Correo electrónico",
                          textInputType: TextInputType.emailAddress,
                          initialValue: loginFormProvider.email,
                          onChanged: (value) => loginFormProvider.email = value,
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
                          isPassword: !loginFormProvider.show_password,
                          initialValue: loginFormProvider.password,
                          onChanged: (value) => loginFormProvider.password = value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              loginFormProvider.show_password ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () {
                              loginFormProvider.showPassword = !loginFormProvider.show_password;
                            },
                            splashColor: Colors.transparent,
                          ),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        // errorText(loginFormProvider, context),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: FilledSimpleButton(
                              text: loginFormProvider.isLoading ? 'Entrando ...' : 'Entrar',
                              onPressedFunction: loginFormProvider.isLoading
                                  ? (ctx) {
                              }
                                  : (ctx) async {
                                FocusScope.of(context).unfocus();
                                var resp = await loginFormProvider.login(context);
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
                              }
                          ),
                        ),
                         const SizedBox(height: 20),
                         SizedBox(
                           // Calculate width based on screen size
                           width: MediaQuery.of(context).size.width * 0.6,
                           child: GestureDetector(
                             onTap: () {
                               Navigator.of(context).push(
                                 MaterialPageRoute(
                                   builder: (context) => const RegisterScreen(),
                                 ),
                               );
                             },
                             child: const Text(
                               '¿Aun no tienes cuenta?',
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                 color: AppColors.white,
                                 fontSize: 14,
                               ),
                             ),
                           ),
                         ),
                        const SizedBox(height: 100,),
                        SizedBox(
                          // Calculate width based on screen size
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: const Text(
                            '¿Has olvidado tu contraseña?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.transparent,
                              fontSize: 14,
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