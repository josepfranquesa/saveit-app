import 'package:SaveIt/domain/user.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/providers/perfil_provider.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:SaveIt/utils/ui/widgets/filled_simple_button.dart';
import 'package:SaveIt/utils/ui/widgets/saveit_card.dart';
import 'package:SaveIt/utils/ui/widgets/saveit_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/helpers/utils_functions.dart';
import '../auth/login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<PerfilScreen> {
  late User _user;
  late PerfilProvider _perfilProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

      _user = _perfilProvider.initForm(
        authProvider.user ??
            User(
              id: 0,
              name: 'Usuario Demo',
              email: 'demo@email.com',
              phone: '000000000',
            ),
      );

      setState(() {}); // Redibujar si fuera necesario
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Container(
              color: AppColors.backgroundInApp,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mi perfil", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 30),
                    _buildUserInfo(context, _perfilProvider),
                    const SizedBox(height: 130),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, PerfilProvider userFormProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SaveItCard(
          width: double.infinity,
          color: AppColors.principal,
          child: Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.disabled,
                child: Icon(
                  Icons.person,
                  size: 45,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        Text("NOMBRE COMPLETO", style: Theme.of(context).textTheme.labelMedium),
        Text(
          _user.name,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 30),
        Text("DIRECCIÓN DE CORREO ELECTRÓNICO", style: Theme.of(context).textTheme.labelMedium),
        Text(
          _user.email,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 30),
        SaveitInput(
          placeholder: "Teléfono",
          textInputType: TextInputType.phone,
          onChanged: (value) => _user.phone = value,
          initialValue: _user.phone,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FilledSimpleButton(
            text: userFormProvider.isLoading ? 'Guardando...' : 'Guardar',
            onPressedFunction: userFormProvider.isLoading
                ? (ctx) {}
                : (ctx) async {
              FocusScope.of(context).unfocus();
              var resp = await userFormProvider.updateUser(_user);
              if (resp!.isNotEmpty) {
                AppUtils.toast(context, title: resp[0], type: resp[1]);
                Provider.of<AuthProvider>(context, listen: false).refreshToken();
              } else {
                AppUtils.toast(context, title: 'Datos actualizados', type: 'success');
              }
            },
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: GestureDetector(
            onTap: () async {
              await userFormProvider.logout();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              });
            },
            child: const Text(
              'Cerrar sesión',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.principal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
