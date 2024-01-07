import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_user_name_cubit.dart';
import 'package:provider/provider.dart';

class AddUserNamePage extends StatefulWidget {
  final String userName;
  const AddUserNamePage({super.key, required this.userName});

  @override
  State<AddUserNamePage> createState() => _AddUserNamePageState();
}

class _AddUserNamePageState extends State<AddUserNamePage> {
  late final TextEditingController _textEditingController;

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  bool isAvailable = false;

  @override
  void initState() {
    _textEditingController = TextEditingController(text: widget.userName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    return BlocConsumer<EditUserNameCubit, EditUserNameState>(
      listener: (context, state) {
        if (state.status == EditUserNameStatus.userNameNotAvailable) {
          isAvailable = false;
          _globalKey.currentState!.validate();
        }
        if (state.status == EditUserNameStatus.availlable) {
          isAvailable = true;
          _globalKey.currentState!.validate();
        }
        if (state.status == EditUserNameStatus.success) {
          _storeGameSelected(context);
          _toHome(context);
        }
        debugPrint('qwerty ENC ${state.status.name}');
        // if (state.status == EditUserNameStatus.loading) {
        //   showDialog(
        //       context: context,
        //       builder: (_) => WillPopScope(
        //             onWillPop: () {
        //               return Future.sync(() {
        //                 if (state.status == EditUserNameStatus.loading) {
        //                   return false;
        //                 }
        //                 return true;
        //               });
        //             },
        //             child: const Dialog(
        //               child: Center(
        //                 child: CircularProgressIndicator(),
        //               ),
        //             ),
        //           ));
        // }
      },
      builder: (comtext, state) => WillPopScope(
        onWillPop: () {
          return Future.sync(() {
            return false;
          });
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: COLOR_white_fff5f5f5,
            appBar: AppBar(
              backgroundColor: COLOR_white_fff5f5f5,
              title: Text(LocaleKeys.label_user_name.tr()),
              actions: [
                IconButton(
                    onPressed: () async {
                      await BlocProvider.of<EditUserNameCubit>(context)
                          .editUserName(_textEditingController.text);
                    },
                    icon: Icon(MdiIcons.check))
              ],
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _globalKey,
                      child: Theme(
                        data: ThemeData().copyWith(
                            colorScheme: ThemeData()
                                .colorScheme
                                .copyWith(primary: COLOR_black_ff121212)),
                        child: TextFormField(
                          validator: _validator,
                          controller: _textEditingController,
                          cursorColor: COLOR_black_ff121212,
                          onChanged: (value) async {
                            debugPrint('qwerty $value');
                            await BlocProvider.of<EditUserNameCubit>(context)
                                .checkUserNameAvailability(value);
                            _globalKey.currentState!.validate();
                          },
                          decoration: InputDecoration(suffix:
                              BlocBuilder<EditUserNameCubit, EditUserNameState>(
                            builder: (context, state) {
                              if (state.status == EditUserNameStatus.loading) {
                                return SizedBox(
                                    width: Dimens.DIMENS_12,
                                    height: Dimens.DIMENS_12,
                                    child: const CircularProgressIndicator());
                              }
                              return const SizedBox(
                                width: 0,
                                height: 0,
                              );
                            },
                          )),
                        ),
                      ),
                    ),
                    const Text(
                        'Buat name pengguna, Atau biarkan dan gunakan nama pengguna default'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toHome(BuildContext context) {
    context.go(APP_PAGE.home.toPath);
  }

  /// Store game selected if there a game selected
  ///
  /// on onboarding before.
  void _storeGameSelected(BuildContext context) {
    final repository = RepositoryProvider.of<UserRepository>(context);
    final appService = Provider.of<AppService>(context, listen: false);
    List<String> games = appService.getAllSelectedGameFav();
    repository.editGameFav(games);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  String? _validator(String? value) {
    if (value!.contains(RegExp(r'\s'))) {
      return 'Nama pengguna tidak boleh menggunakan spasi.';
    } else if (value.isEmpty) {
      return 'Nama Pengguna tidak boleh kosong.';
    } else if (value.trim().isEmpty) {
      return 'Nama pengguna tidak boleh diawali spasi.';
    } else if (isAvailable == false) {
      return 'User name not available.';
    }
    debugPrint('qwerty isacjaklv $isAvailable');
    return null; // Return null if the input is valid
  }
}
