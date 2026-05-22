import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/store_locations/store_locations_screen.dart';
import 'package:alkhafajdashboard/view/screen/users/cubit/users_cubit.dart';
import 'package:alkhafajdashboard/view/widget/MyDropList.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedRole;
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final UsersCubit cubit = context.read<UsersCubit>();
      if (cubit.users.isEmpty || cubit.locations.isEmpty) {
        cubit.fetchUsers();
      }
    });
  }

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
    final String query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return cubit.users;
    }

    return cubit.users.where((dynamic user) {
      final String locationName = _locationName(
        cubit,
        user.locationId,
      ).toLowerCase();
      final String roleName = _roleName(user.role).toLowerCase();
      return user.name.toLowerCase().contains(query) ||
          (user.username ?? '').toLowerCase().contains(query) ||
          locationName.contains(query) ||
          roleName.contains(query);
    }).toList();
  }

  String _roleName(String roleId) {
    try {
      return ConstVar.roleList
          .firstWhere((dynamic role) => role.id == roleId)
          .name;
    } catch (_) {
      return roleId;
    }
  }

  String _locationName(UsersCubit cubit, int? locationId) {
    if (locationId == null) {
      return 'غير محدد';
    }

    try {
      return cubit.locations
          .firstWhere((dynamic location) => location.id == locationId)
          .name;
    } catch (_) {
      return 'غير محدد';
    }
  }

  void _selectUser(UsersCubit cubit, dynamic user) {
    emailController.text = user.username ?? '';
    passwordController.text = user.password ?? '';
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
    if (cubit.locations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أضف موقع متجر واحد على الأقل قبل إنشاء المستخدم'),
        ),
      );
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
    return DashboardScaffold(
      currentRoute: 'users',
      title: 'إدارة المستخدمين',
      subtitle:
          'واجهة عربية مرتبة لإدارة الموظفين والصلاحيات وربط الحسابات بالمواقع بطريقة أوضح وأسرع.',
      actions: <Widget>[
        Builder(
          builder: (BuildContext context) {
            final UsersCubit cubit = context.read<UsersCubit>();
            return MyButton(
              text: 'تحديث البيانات',
              icon: Icons.refresh_rounded,
              variant: MyButtonVariant.secondary,
              onPressed: cubit.fetchUsers,
            );
          },
        ),
      ],
      child: BlocConsumer<UsersCubit, UsersState>(
        listener: (BuildContext context, UsersState state) {
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
        builder: (BuildContext context, UsersState state) {
          final UsersCubit cubit = context.read<UsersCubit>();
          final bool isBusy = state is UsersLoading;
          final List<dynamic> filteredUsers = _filteredUsers(cubit);

          if (isBusy && cubit.users.isEmpty && cubit.locations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 1180;
              final Widget formPanel = _UsersFormPanel(
                formKey: _formKey,
                cubit: cubit,
                isBusy: isBusy,
                nameController: nameController,
                emailController: emailController,
                passwordController: passwordController,
                selectedRole: selectedRole,
                selectedLocation: selectedLocation,
                onRoleChanged: (String? value) {
                  setState(() => selectedRole = value);
                },
                onLocationChanged: (String? value) {
                  setState(() => selectedLocation = value);
                },
                onSubmit: () => _submitForm(cubit),
                onReset: () => _resetForm(cubit),
              );
              final Widget listPanel = _UsersListPanel(
                cubit: cubit,
                filteredUsers: filteredUsers,
                searchController: searchController,
                onSearchChanged: (_) => setState(() {}),
                onSelectUser: (dynamic user) => _selectUser(cubit, user),
                locationNameBuilder: (int? locationId) =>
                    _locationName(cubit, locationId),
                roleNameBuilder: _roleName,
                hasQuery: searchController.text.trim().isNotEmpty,
              );

              if (compact) {
                return ListView(
                  children: <Widget>[
                    // _UsersHeroCard(
                    //   totalUsers: cubit.users.length,
                    //   totalLocations: cubit.locations.length,
                    //   selectedUser: cubit.userId == null ? 'لا يوجد' : 'نشط',
                    // ),
                    // const SizedBox(height: 22),
                    formPanel,
                    const SizedBox(height: 22),
                    SizedBox(height: 700, child: listPanel),
                  ],
                );
              }

              return Column(
                children: <Widget>[
                  // _UsersHeroCard(
                  //   totalUsers: cubit.users.length,
                  //   totalLocations: cubit.locations.length,
                  //   selectedUser: cubit.userId == null ? 'لا يوجد' : 'نشط',
                  // ),
                  // const SizedBox(height: 22),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(flex: 3, child: formPanel),
                        const SizedBox(width: 22),
                        Expanded(flex: 4, child: listPanel),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
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

class _UsersHeroCard extends StatelessWidget {
  const _UsersHeroCard({
    required this.totalUsers,
    required this.totalLocations,
    required this.selectedUser,
  });

  final int totalUsers;
  final int totalLocations;
  final String selectedUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: ConstVar.brandGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: ConstVar.softShadow,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 760;
          final List<Widget> metrics = <Widget>[
            _HeroMetric(
              title: 'إجمالي المستخدمين',
              value: '$totalUsers',
              icon: Icons.group_outlined,
            ),
            _HeroMetric(
              title: 'المواقع المرتبطة',
              value: '$totalLocations',
              icon: Icons.location_on_outlined,
            ),
            _HeroMetric(
              title: 'الحساب المحدد',
              value: selectedUser,
              icon: Icons.person_search_rounded,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'إدارة الفريق والصلاحيات',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'إضافة موظفين جدد، متابعة المواقع، ومراجعة الحسابات المختارة ضمن تخطيط واضح ومناسب للواجهة العربية.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              if (compact)
                Column(
                  children:
                      metrics
                          .expand(
                            (Widget widget) => <Widget>[
                              widget,
                              const SizedBox(height: 12),
                            ],
                          )
                          .toList()
                        ..removeLast(),
                )
              else
                Row(
                  children:
                      metrics
                          .expand(
                            (Widget widget) => <Widget>[
                              Expanded(child: widget),
                              const SizedBox(width: 12),
                            ],
                          )
                          .toList()
                        ..removeLast(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MyText(
                  title,
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.86),
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 4),
                MyText(
                  value,
                  size: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersFormPanel extends StatelessWidget {
  const _UsersFormPanel({
    required this.formKey,
    required this.cubit,
    required this.isBusy,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.selectedRole,
    required this.selectedLocation,
    required this.onRoleChanged,
    required this.onLocationChanged,
    required this.onSubmit,
    required this.onReset,
  });

  final GlobalKey<FormState> formKey;
  final UsersCubit cubit;
  final bool isBusy;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? selectedRole;
  final String? selectedLocation;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onLocationChanged;
  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return MyCard(
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MyText(
                          cubit.userId == null
                              ? 'إنشاء مستخدم جديد'
                              : 'تعديل الحساب المختار',
                          size: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        const SizedBox(height: 6),
                        MyText(
                          cubit.userId == null
                              ? 'أضف بيانات الموظف، الصلاحية، والموقع ثم احفظ مباشرة.'
                              : 'راجع بيانات الحساب الحالي ثم احفظ التعديلات المطلوبة.',
                          size: 14,
                          color: ConstVar.textMuted,
                          height: 1.5,
                        ),
                      ],
                    ),
                  ),
                  if (cubit.userId != null)
                    MyButton(
                      text: 'إلغاء التحديد',
                      icon: Icons.close_rounded,
                      variant: MyButtonVariant.ghost,
                      onPressed: onReset,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      ConstVar.pColor.withValues(alpha: 0.10),
                      ConstVar.sColor.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _MiniMetric(
                        label: 'المستخدمون',
                        value: '${cubit.users.length}',
                        icon: Icons.group,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniMetric(
                        label: 'المواقع',
                        value: '${cubit.locations.length}',
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              MyTextFeild(
                controller: nameController,
                labelText: 'الاسم الكامل',
                icon: Icons.person_outline_rounded,
              ),
              MyTextFeild(
                controller: emailController,
                labelText: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isReadOnly: cubit.userId != null,
              ),
              MyTextFeild(
                controller: passwordController,
                labelText: cubit.userId == null
                    ? 'كلمة المرور'
                    : 'كلمة المرور الجديدة',
                icon: Icons.lock_outline_rounded,
              ),
              MyDropList(
                items: ConstVar.roleList
                    .map<String>((dynamic role) => role.name as String)
                    .toList(),
                selectedItem: selectedRole,
                hint: 'اختر الصلاحية',
                onChanged: onRoleChanged,
              ),
              MyDropList(
                items: cubit.locations
                    .map<String>((dynamic location) => location.name as String)
                    .toList(),
                selectedItem: selectedLocation,
                hint: 'اختر الموقع',
                onChanged: cubit.locations.isEmpty ? null : onLocationChanged,
              ),
              if (cubit.locations.isEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ConstVar.sColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ConstVar.sColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_off_outlined,
                            color: ConstVar.sColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MyText(
                              'لا توجد مواقع متجر متاحة حاليًا',
                              size: 14,
                              fontWeight: FontWeight.w800,
                              color: ConstVar.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        'أضف موقع متجر أولًا حتى تتمكن من إسناد الحساب الجديد إلى فرع أو نقطة تجهيز محددة.',
                        size: 13,
                        color: ConstVar.textMuted,
                        height: 1.5,
                      ),
                      const SizedBox(height: 12),
                      MyButton(
                        text: 'فتح مواقع المتجر',
                        icon: Icons.storefront_rounded,
                        variant: MyButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const StoreLocationsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ConstVar.panelSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ConstVar.borderColor),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.info_outline_rounded, color: ConstVar.pColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MyText(
                        'سيتم ربط المستخدم مباشرة بالموقع المختار وتفعيل صلاحياته حسب الدور المحدد.',
                        size: 13,
                        color: ConstVar.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MyButton(
                      text: cubit.userId == null
                          ? 'إضافة المستخدم'
                          : 'حفظ التعديلات',
                      icon: cubit.userId == null
                          ? Icons.person_add_alt_1_rounded
                          : Icons.save_rounded,
                      expand: true,
                      onPressed: isBusy ? null : onSubmit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      text: 'تفريغ الحقول',
                      icon: Icons.layers_clear_rounded,
                      variant: MyButtonVariant.secondary,
                      expand: true,
                      onPressed: isBusy ? null : onReset,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ConstVar.pColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: ConstVar.pColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MyText(
                  label,
                  size: 12,
                  color: ConstVar.textMuted,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 4),
                MyText(value, size: 22, fontWeight: FontWeight.w900),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersListPanel extends StatelessWidget {
  const _UsersListPanel({
    required this.cubit,
    required this.filteredUsers,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSelectUser,
    required this.locationNameBuilder,
    required this.roleNameBuilder,
    required this.hasQuery,
  });

  final UsersCubit cubit;
  final List<dynamic> filteredUsers;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<dynamic> onSelectUser;
  final String Function(int? locationId) locationNameBuilder;
  final String Function(String roleId) roleNameBuilder;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return MyCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MyText(
                      'قائمة المستخدمين',
                      size: 24,
                      fontWeight: FontWeight.w900,
                    ),
                    const SizedBox(height: 6),
                    MyText(
                      'اختر أي مستخدم لعرض بياناته داخل النموذج وتعديلها بسرعة.',
                      size: 14,
                      color: ConstVar.textMuted,
                      height: 1.45,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ConstVar.panelSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: MyText(
                  '${filteredUsers.length} نتيجة',
                  size: 13,
                  fontWeight: FontWeight.w800,
                  color: ConstVar.pColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          MyTextFeild(
            controller: searchController,
            labelText: 'ابحث بالاسم أو البريد أو الموقع',
            icon: Icons.search_rounded,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredUsers.isEmpty
                ? _EmptyUsersState(hasQuery: hasQuery)
                : ListView.separated(
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final dynamic user = filteredUsers[index];
                      return _UserListTile(
                        userName: user.name,
                        email: user.username ?? '',
                        role: roleNameBuilder(user.role),
                        location: locationNameBuilder(user.locationId),
                        isSelected: cubit.userId == user.id,
                        onTap: () => onSelectUser(user),
                      );
                    },
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected
                ? ConstVar.pColor.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? ConstVar.pColor.withValues(alpha: 0.34)
                  : ConstVar.borderColor,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? ConstVar.brandGradient
                      : ConstVar.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MyText(userName, size: 17, fontWeight: FontWeight.w900),
                    const SizedBox(height: 4),
                    MyText(email, size: 13, color: ConstVar.textMuted),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
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
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isSelected ? ConstVar.pColor : ConstVar.textMuted,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ConstVar.panelSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ConstVar.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: ConstVar.pColor),
          const SizedBox(width: 6),
          MyText(
            label,
            size: 12,
            fontWeight: FontWeight.w700,
            color: ConstVar.textPrimary,
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
        children: <Widget>[
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: ConstVar.panelSoft,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              hasQuery
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 42,
              color: ConstVar.pColor,
            ),
          ),
          const SizedBox(height: 18),
          MyText(
            hasQuery ? 'لا توجد نتائج مطابقة' : 'لا يوجد مستخدمون حتى الآن',
            size: 22,
            fontWeight: FontWeight.w900,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 380,
            child: MyText(
              hasQuery
                  ? 'جرّب تغيير كلمات البحث أو امسح حقل البحث لإظهار جميع الحسابات.'
                  : 'ابدأ بإضافة أول مستخدم من النموذج الموجود في هذه الصفحة.',
              size: 14,
              color: ConstVar.textMuted,
              textAlign: TextAlign.center,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
