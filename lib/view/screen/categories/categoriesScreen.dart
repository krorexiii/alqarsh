import 'package:alkhafajdashboard/view/screen/categories/cubit/categories_cubit.dart';
import 'package:alkhafajdashboard/view/screen/categories/widget/categories_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/categories/widget/categories_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit()..fetchCategories(),
      child: DashboardScaffold(
        currentRoute: 'categories',
        title: 'إدارة التصنيفات',
        subtitle:
            'أنشئ تصنيفات المتجر ورتّبها بصريًا حتى يكون عرض المنتجات أوضح وأكثر احترافية.',
        child: BlocConsumer<CategoriesCubit, CategoriesState>(
          listener: (BuildContext context, CategoriesState state) {
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
          builder: (BuildContext context, CategoriesState state) {
            final CategoriesCubit cubit = context.read<CategoriesCubit>();
            final bool isBusy =
                state is CategoriesLoading || state is CategoriesSaving;

            if (state is CategoriesLoading && cubit.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: CategoriesListPanel(cubit: cubit, isBusy: isBusy),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: CategoriesFormPanel(cubit: cubit, isBusy: isBusy),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
