import 'package:alkhafajdashboard/view/screen/bannerAds/cubit/banner_ads_cubit.dart';
import 'package:alkhafajdashboard/view/screen/bannerAds/widget/banner_ads_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/bannerAds/widget/banner_ads_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:alkhafajdashboard/view/widget/myAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BannerAdsScreen extends StatelessWidget {
  const BannerAdsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BannerAdsCubit()..fetchBannerAds(),
      child: Scaffold(
        drawer: const DashboardDrawer(currentRoute: 'banner_ads'),
        backgroundColor: const Color(0xfff6f7fb),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Builder(
                builder: (context) => const MyAppbar(
                  title: 'صفحة الإعلانات',
                  isBack: false,
                  actions: [],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocConsumer<BannerAdsCubit, BannerAdsState>(
                  listener: (context, state) {
                    if (state is BannerAdsError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }

                    if (state is BannerAdsSuccess) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<BannerAdsCubit>();
                    final bool isBusy =
                        state is BannerAdsLoading || state is BannerAdsSaving;

                    if (state is BannerAdsLoading && cubit.ads.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: BannerAdsListPanel(
                            cubit: cubit,
                            isBusy: isBusy,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: BannerAdsFormPanel(
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
