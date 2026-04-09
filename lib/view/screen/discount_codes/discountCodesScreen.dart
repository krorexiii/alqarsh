import 'package:alkhafajdashboard/view/screen/discount_codes/cubit/discount_codes_cubit.dart';
import 'package:alkhafajdashboard/view/screen/discount_codes/widget/discount_codes_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/discount_codes/widget/discount_codes_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscountCodesScreen extends StatelessWidget {
  const DiscountCodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscountCodesCubit()..fetchDiscountCodes(),
      child: DashboardScaffold(
        currentRoute: 'discount_codes',
        title: 'أكواد الخصم',
        subtitle:
            'أنشئ البرومو كود وحدد نوع الخصم والحد الأدنى والصلاحية وعدد مرات الاستخدام من مكان واحد.',
        child: BlocConsumer<DiscountCodesCubit, DiscountCodesState>(
          listener: (BuildContext context, DiscountCodesState state) {
            if (state is DiscountCodesError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }

            if (state is DiscountCodesSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (BuildContext context, DiscountCodesState state) {
            final DiscountCodesCubit cubit = context.read<DiscountCodesCubit>();
            final bool isBusy =
                state is DiscountCodesLoading || state is DiscountCodesSaving;

            if (state is DiscountCodesLoading && cubit.discountCodes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: DiscountCodesListPanel(cubit: cubit, isBusy: isBusy),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: DiscountCodesFormPanel(cubit: cubit, isBusy: isBusy),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
