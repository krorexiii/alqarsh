import 'package:alkhafajdashboard/view/screen/categories/cubit/categories_cubit.dart';
import 'package:alkhafajdashboard/view/screen/categories/widget/categories_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/categories/widget/categories_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:alkhafajdashboard/view/widget/myAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit()..fetchCategories(),
      child: Scaffold(
        drawer: const DashboardDrawer(currentRoute: 'categories'),
        backgroundColor: const Color(0xfff6f7fb),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Builder(
                builder: (context) => const MyAppbar(
                  title: 'صفحة التصنيفات',
                  isBack: false,
                  actions: [],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocConsumer<CategoriesCubit, CategoriesState>(
                  listener: (context, state) {
                    if (state is CategoriesError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }

                    if (state is CategoriesSuccess) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<CategoriesCubit>();
                    final bool isBusy =
                        state is CategoriesLoading || state is CategoriesSaving;

                    if (state is CategoriesLoading &&
                        cubit.categories.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: CategoriesListPanel(
                            cubit: cubit,
                            isBusy: isBusy,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: CategoriesFormPanel(
                            cubit: cubit,
                            isBusy: isBusy,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
