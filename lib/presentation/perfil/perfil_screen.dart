// ignore_for_file: use_build_context_synchronously
/*
import 'package:SaveIt/domain/user.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/providers/perfil_provider.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:SaveIt/utils/ui/widgets/user_card.dart';
//import 'package:SaveIt/utils/ui/widgets/beltime_input.dart';
//import 'package:SaveIt/utils/ui/widgets/beltime_selector.dart';
//import 'package:SaveIt/utils/ui/widgets/filled_simple_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            _perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
            if(authProvider.user!=null) _user = Provider.of<PerfilProvider>(context, listen: false).initForm(authProvider.user!);
            return Container(
              color: AppColors.appBackground,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: MediaQuery.of(context).size.height,
              // height: MediaQuery.of(context).size.height - 130,
              child: SingleChildScrollView(
                // only scroll when is necessary
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mi perfil",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 30,),
                    _buildUserInfo(context, _perfilProvider),
                    const SizedBox(height: 130,),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, PerfilProvider _userFormProvider) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            const SizedBox(height: 50,),
            Expanded(
              child: (
                width: double.infinity,
                height: double.infinity,
                child: _buildUserInfo(context, _userFormProvider),
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage(Icons.account_circle as String),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, PerfilProvider _userFormProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BeltimeCard(
            width: double.infinity,
            color: AppColors.primary,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(_user.profile_pic_url ?? ''),
                ),
                const SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal, color: Colors.white),
                    ),
                    Text(
                      "${_user.surnames}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 60),
          Text("NOMBRE COMPLETO", style: Theme.of(context).textTheme.labelMedium,),
          Text(
            '${_user.name} ${_user.surnames ?? ''}',
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 30,),
          Text("DIRECCIÓN DE CORREO ELECTRÓNICO", style: Theme.of(context).textTheme.labelMedium,),
          Text(
            _user.email,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              SizedBox(
                  child: BeltimeSelector(
                    value: _user.phone_prefix ?? '+34',
                    items: prefixes.map((e) => DropdownMenuItem(
                      value: e['code'],
                      child: Text('${e['code']!} ${e['flag']!}'),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _user.phone_prefix = value;
                      });
                    },
                  )
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: BeltimeInput(
                    placeholder: "Teléfono",
                    textInputType: TextInputType.phone,
                    onChanged: (value) => _user.phone_number = value,
                    initialValue: _user.phone_number
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Checkbox(
                value: _user.allow_notifications ?? false,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onChanged: (value) {
                  setState(() {
                    _user.allow_notifications = value;
                  });
                },
              ),
              Expanded(
                child: Text(
                  "Acepto recibir notificaciones de la aplicación",
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Button save
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FilledSimpleButton(
                text: _userFormProvider.isLoading ? 'Guardando...' : 'Guardar',
                onPressedFunction: _userFormProvider.isLoading
                    ? (ctx) {

                }
                    : (ctx) async {
                  FocusScope.of(context).unfocus();
                  var resp = await _userFormProvider.updateUser(_user);
                  if(resp!.isNotEmpty){
                    toast(context, title: resp[0], type: resp[1]);
                    Provider.of<AuthProvider>(context, listen: false).refreshToken();
                  } else {
                    toast(context, title: 'Datos actualizados', type: 'success');
                  }
                }
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: GestureDetector(
              onTap: () async {
                await _userFormProvider.logout();
                WidgetsBinding.instance.addPostFrameCallback((_){
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(),
                    ),
                  );
                });
              },
              child: const Text(
                'Cerrar sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
