import 'package:alkhafajdashboard/view/screen/parts/cubit/parts_cubit.dart';
import 'package:alkhafajdashboard/view/screen/parts/widget/parts_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/parts/widget/parts_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:alkhafajdashboard/view/widget/myAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartsScreen extends StatelessWidget {
  const PartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartsCubit()..initialize(),
      child: Scaffold(
        drawer: const DashboardDrawer(currentRoute: 'parts'),
        backgroundColor: const Color(0xfff6f7fb),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Builder(
                builder: (context) => const MyAppbar(
                  title: 'صفحة الأقسام',
                  isBack: false,
                  actions: [],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocConsumer<PartsCubit, PartsState>(
                  listener: (context, state) {
                    if (state is PartsError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }

                    if (state is PartsSuccess) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<PartsCubit>();
                    final bool isBusy =
                        state is PartsLoading || state is PartsSaving;

                    if (state is PartsLoading &&
                        cubit.parts.isEmpty &&
                        cubit.items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: PartsListPanel(cubit: cubit, isBusy: isBusy),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: PartsFormPanel(cubit: cubit, isBusy: isBusy),
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
