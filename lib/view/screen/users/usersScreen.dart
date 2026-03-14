import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/users/cubit/users_cubit.dart';
import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widget/MyDropList.dart';
import '../../widget/myAppbar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String? selectedRole;
  String? selectedLocation;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DashboardDrawer(currentRoute: 'users'),
      backgroundColor: const Color(0xfff6f7fb),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Builder(
              builder: (context) => const MyAppbar(
                title: "إدارة المستخدمين",
                isBack: false,
                actions: [],
              ),
            ),
            const SizedBox(height: 10),
            BlocConsumer<UsersCubit, UsersState>(
              listener: (context, state) {
                if (state is UsersError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                } else if (state is UsersSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم حفظ المستخدم بنجاح")),
                  );
                  usernameController.clear();
                  passwordController.clear();
                  nameController.clear();
                  selectedRole = null;
                  selectedLocation = null;
                }
              },
              builder: (context, state) {
                var cubit = BlocProvider.of<UsersCubit>(context);
                if (state is UsersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: MyCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                MyTextFeild(
                                  controller: usernameController,
                                  labelText: "اسم المستخدم",
                                  icon: Icons.person,
                                  isReadOnly: cubit.userId != null,
                                ),
                                MyTextFeild(
                                  controller: passwordController,
                                  labelText: "كلمة المرور",
                                  icon: Icons.lock,
                                ),
                                MyTextFeild(
                                  controller: nameController,
                                  labelText: "الاسم الكامل",
                                  icon: Icons.person_outline,
                                ),
                                MyDropList(
                                  items: ConstVar.roleList
                                      .map((role) => role.name)
                                      .toList(),
                                  selectedItem: selectedRole,
                                  hint: '',
                                  onChanged: (String? p1) {
                                    selectedRole = p1;
                                  },
                                ),
                                MyDropList(
                                  items: cubit.locations
                                      .map((location) => location.name)
                                      .toList(),
                                  selectedItem: selectedLocation,
                                  hint: 'اختر الموقع',
                                  onChanged: (String? p1) {
                                    selectedLocation = p1;
                                  },
                                ),
                                SizedBox(height: 20),
                                MyButton(
                                  text: "حفظ",
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      cubit.saveUser(
                                        username: usernameController.text,
                                        password: passwordController.text,
                                        name: nameController.text,
                                        role: selectedRole!,
                                        locationId: selectedLocation!,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: cubit.users.length,
                          itemBuilder: (context, index) {
                            var user = cubit.users[index];
                            return ListTile(
                              title: Text(user.name),
                              subtitle: Text(user.username ?? ""),
                              trailing: Text(user.role),
                              onTap: () {
                                usernameController.text = user.username ?? "";
                                passwordController.text = user.password ?? "";
                                nameController.text = user.name;
                                selectedRole = ConstVar.roleList
                                    .firstWhere((r) => r.id == user.role)
                                    .name;
                                selectedLocation = cubit.locations
                                    .firstWhere((l) => l.id == user.locationId)
                                    .name;
                                cubit.selectUser(user);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
