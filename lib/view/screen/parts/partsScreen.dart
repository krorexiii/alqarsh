import 'package:alkhafajdashboard/view/screen/parts/cubit/parts_cubit.dart';
import 'package:alkhafajdashboard/view/screen/parts/widget/parts_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/parts/widget/parts_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartsScreen extends StatelessWidget {
  const PartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartsCubit()..initialize(),
      child: DashboardScaffold(
        currentRoute: 'parts',
        title: 'إدارة الأقسام',
        subtitle:
            'رتّب أقسام الصفحة الرئيسية وحدد المنتجات التابعة لكل قسم لتكوين واجهة متجر أكثر جاذبية.',
        child: BlocConsumer<PartsCubit, PartsState>(
          listener: (BuildContext context, PartsState state) {
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
          builder: (BuildContext context, PartsState state) {
            final PartsCubit cubit = context.read<PartsCubit>();
            final bool isBusy = state is PartsLoading || state is PartsSaving;

            if (state is PartsLoading &&
                cubit.parts.isEmpty &&
                cubit.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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
    );
  }
}
