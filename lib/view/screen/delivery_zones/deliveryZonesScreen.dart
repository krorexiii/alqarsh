import 'package:alkhafajdashboard/view/screen/delivery_zones/cubit/delivery_zones_cubit.dart';
import 'package:alkhafajdashboard/view/screen/delivery_zones/widget/delivery_zones_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/delivery_zones/widget/delivery_zones_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:alkhafajdashboard/view/widget/myAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryZonesScreen extends StatelessWidget {
  const DeliveryZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeliveryZonesCubit()..fetchDeliveryZones(),
      child: Scaffold(
        drawer: const DashboardDrawer(currentRoute: 'delivery_zones'),
        backgroundColor: const Color(0xfff6f7fb),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Builder(
                builder: (context) => const MyAppbar(
                  title: 'صفحة مناطق التوصيل',
                  isBack: false,
                  actions: [],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocConsumer<DeliveryZonesCubit, DeliveryZonesState>(
                  listener: (context, state) {
                    if (state is DeliveryZonesError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }

                    if (state is DeliveryZonesSuccess) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<DeliveryZonesCubit>();
                    final bool isBusy =
                        state is DeliveryZonesLoading ||
                        state is DeliveryZonesSaving;

                    if (state is DeliveryZonesLoading &&
                        cubit.deliveryZones.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: DeliveryZonesListPanel(
                            cubit: cubit,
                            isBusy: isBusy,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: DeliveryZonesFormPanel(
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
