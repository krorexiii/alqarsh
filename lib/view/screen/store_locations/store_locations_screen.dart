import 'package:alkhafajdashboard/view/screen/store_locations/cubit/store_locations_cubit.dart';
import 'package:alkhafajdashboard/view/screen/store_locations/store_locations_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/store_locations/store_locations_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreLocationsScreen extends StatelessWidget {
  const StoreLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoreLocationsCubit()..fetchStoreLocations(),
      child: DashboardScaffold(
        currentRoute: 'store_locations',
        title: 'مواقع المتجر',
        subtitle:
            'أدر الفروع ونقاط تجهيز الطلبات التي يعتمد عليها توزيع الطلبات وصلاحيات الموظفين داخل النظام.',
        child: BlocConsumer<StoreLocationsCubit, StoreLocationsState>(
          listener: (BuildContext context, StoreLocationsState state) {
            if (state is StoreLocationsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }

            if (state is StoreLocationsSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (BuildContext context, StoreLocationsState state) {
            final StoreLocationsCubit cubit = context
                .read<StoreLocationsCubit>();
            final bool isBusy =
                state is StoreLocationsLoading || state is StoreLocationsSaving;

            if (state is StoreLocationsLoading && cubit.locations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool compact = constraints.maxWidth < 1180;

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: StoreLocationsListPanel(
                          cubit: cubit,
                          isBusy: isBusy,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        flex: 5,
                        child: StoreLocationsFormPanel(
                          cubit: cubit,
                          isBusy: isBusy,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: StoreLocationsListPanel(
                        cubit: cubit,
                        isBusy: isBusy,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: StoreLocationsFormPanel(
                        cubit: cubit,
                        isBusy: isBusy,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
