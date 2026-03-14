import 'package:alkhafajdashboard/view/screen/items/cubit/items_cubit.dart';
import 'package:alkhafajdashboard/view/screen/items/widget/items_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/items/widget/items_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:alkhafajdashboard/view/widget/myAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ItemsCubit()..initialize(),
      child: Scaffold(
        drawer: const DashboardDrawer(currentRoute: 'items'),
        backgroundColor: const Color(0xfff6f7fb),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Builder(
                builder: (context) => const MyAppbar(
                  title: 'صفحة المنتجات',
                  isBack: false,
                  actions: [],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocConsumer<ItemsCubit, ItemsState>(
                  listener: (context, state) {
                    if (state is ItemsError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }

                    if (state is ItemsSuccess) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<ItemsCubit>();
                    final bool isBusy =
                        state is ItemsLoading || state is ItemsSaving;

                    if (state is ItemsLoading &&
                        cubit.items.isEmpty &&
                        cubit.categories.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ItemsListPanel(cubit: cubit, isBusy: isBusy),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: ItemsFormPanel(cubit: cubit, isBusy: isBusy),
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
