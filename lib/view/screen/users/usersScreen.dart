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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String? selectedRole;
  String? selectedLocation;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _resetForm(UsersCubit cubit) {
    _formKey.currentState?.reset();
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    searchController.selection = TextSelection.collapsed(
      offset: searchController.text.length,
    );
    setState(() {
      selectedRole = null;
      selectedLocation = null;
    });
    cubit.clearSelection();
  }

  List<dynamic> _filteredUsers(UsersCubit cubit) {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return cubit.users;
    }

    return cubit.users.where((user) {
      final locationName = _locationName(cubit, user.locationId).toLowerCase();
      final roleName = _roleName(user.role).toLowerCase();
      return user.name.toLowerCase().contains(query) ||
          (user.username ?? '').toLowerCase().contains(query) ||
          locationName.contains(query) ||
          roleName.contains(query);
    }).toList();
  }

  String _roleName(String roleId) {
    try {
      return ConstVar.roleList.firstWhere((role) => role.id == roleId).name;
    } catch (_) {
      return roleId;
    }
  }

  String _locationName(UsersCubit cubit, int locationId) {
    try {
      return cubit.locations
          .firstWhere((location) => location.id == locationId)
          .name;
    } catch (_) {
      return 'غير محدد';
    }
  }

  void _selectUser(UsersCubit cubit, dynamic user) {
    emailController.text = user.username ?? "";
    passwordController.text = user.password ?? "";
    nameController.text = user.name;

    setState(() {
      selectedRole = _roleName(user.role);
      selectedLocation = _locationName(cubit, user.locationId);
    });

    cubit.selectUser(user);
  }

  void _submitForm(UsersCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedRole == null || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الصلاحية والموقع')),
      );
      return;
    }

    cubit.saveUser(
      username: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      role: selectedRole!,
      locationId: selectedLocation!,
    );
  }

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
                } else if (state is UsersActionSuccess) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                  _resetForm(context.read<UsersCubit>());
                }
              },
              builder: (context, state) {
                var cubit = BlocProvider.of<UsersCubit>(context);
                final filteredUsers = _filteredUsers(cubit);
                final bool isBusy = state is UsersLoading;
                if (state is UsersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: MyCard(
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cubit.userId == null
                                                  ? 'إضافة مستخدم جديد'
                                                  : 'تعديل بيانات المستخدم',
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              cubit.userId == null
                                                  ? 'أدخل بيانات المستخدم ثم احفظه مباشرة.'
                                                  : 'يمكنك مراجعة البيانات الحالية ثم حفظ التعديلات.',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (cubit.userId != null)
                                        MyButton(
                                          text: 'إلغاء التحديد',
                                          icon: Icons.close,
                                          variant: MyButtonVariant.ghost,
                                          onPressed: () => _resetForm(cubit),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.withValues(
                                        alpha: 0.06,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _StatTile(
                                            title: 'إجمالي المستخدمين',
                                            value: cubit.users.length
                                                .toString(),
                                            icon: Icons.group_outlined,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _StatTile(
                                            title: 'المواقع',
                                            value: cubit.locations.length
                                                .toString(),
                                            icon: Icons.location_on_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  MyTextFeild(
                                    controller: nameController,
                                    labelText: "الاسم الكامل",
                                    icon: Icons.person_outline,
                                  ),
                                  MyTextFeild(
                                    controller: emailController,
                                    labelText: "البريد الإلكتروني",
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    isReadOnly: cubit.userId != null,
                                  ),
                                  MyTextFeild(
                                    controller: passwordController,
                                    labelText: cubit.userId == null
                                        ? "كلمة المرور"
                                        : "كلمة المرور الجديدة",
                                    icon: Icons.lock,
                                  ),
                                  MyDropList(
                                    items: ConstVar.roleList
                                        .map((role) => role.name)
                                        .toList(),
                                    selectedItem: selectedRole,
                                    hint: 'اختر الصلاحية',
                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedRole = value;
                                      });
                                    },
                                  ),
                                  MyDropList(
                                    items: cubit.locations
                                        .map((location) => location.name)
                                        .toList(),
                                    selectedItem: selectedLocation,
                                    hint: 'اختر الموقع',
                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedLocation = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MyButton(
                                          text: cubit.userId == null
                                              ? "إضافة المستخدم"
                                              : "حفظ التعديلات",
                                          icon: cubit.userId == null
                                              ? Icons.person_add_alt_1
                                              : Icons.save_outlined,
                                          expand: true,
                                          onPressed: isBusy
                                              ? null
                                              : () => _submitForm(cubit),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: MyButton(
                                          text: 'تفريغ الحقول',
                                          icon: Icons.refresh,
                                          variant: MyButtonVariant.secondary,
                                          expand: true,
                                          onPressed: isBusy
                                              ? null
                                              : () => _resetForm(cubit),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: MyCard(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'قائمة المستخدمين',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'اضغط على أي مستخدم لعرض بياناته وتعديلها.',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  MyButton(
                                    text: 'تحديث',
                                    icon: Icons.refresh,
                                    variant: MyButtonVariant.ghost,
                                    onPressed: isBusy ? null : cubit.fetchUsers,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              MyTextFeild(
                                controller: searchController,
                                labelText: 'ابحث بالاسم أو البريد أو الموقع',
                                icon: Icons.search,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'عدد النتائج: ${filteredUsers.length}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: filteredUsers.isEmpty
                                    ? _EmptyUsersState(
                                        hasQuery: searchController.text
                                            .trim()
                                            .isNotEmpty,
                                      )
                                    : ListView.separated(
                                        itemCount: filteredUsers.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final user = filteredUsers[index];
                                          final bool isSelected =
                                              cubit.userId == user.id;
                                          return _UserListTile(
                                            userName: user.name,
                                            email: user.username ?? '',
                                            role: _roleName(user.role),
                                            location: _locationName(
                                              cubit,
                                              user.locationId,
                                            ),
                                            isSelected: isSelected,
                                            onTap: () =>
                                                _selectUser(cubit, user),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
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
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    searchController.dispose();
    super.dispose();
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.indigo.withValues(alpha: 0.12),
            child: Icon(icon, color: Colors.indigo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  const _UserListTile({
    required this.userName,
    required this.email,
    required this.role,
    required this.location,
    required this.isSelected,
    required this.onTap,
  });

  final String userName;
  final String email;
  final String role;
  final String location;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Colors.indigo.withValues(alpha: 0.08)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Colors.indigo.withValues(alpha: 0.45)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.indigo,
                child: Text(
                  userName.isNotEmpty ? userName[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(icon: Icons.badge_outlined, label: role),
                        _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: location,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.indigo),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyUsersState extends StatelessWidget {
  const _EmptyUsersState({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery
                ? 'لا توجد نتائج مطابقة للبحث'
                : 'لا يوجد مستخدمون حتى الآن',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery
                ? 'جرّب تغيير كلمات البحث أو امسح حقل البحث.'
                : 'ابدأ بإضافة أول مستخدم من النموذج الموجود على اليسار.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
