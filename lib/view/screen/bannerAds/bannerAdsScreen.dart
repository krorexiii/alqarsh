import 'package:alkhafajdashboard/view/screen/bannerAds/cubit/banner_ads_cubit.dart';
import 'package:alkhafajdashboard/view/screen/bannerAds/widget/banner_ads_form_panel.dart';
import 'package:alkhafajdashboard/view/screen/bannerAds/widget/banner_ads_list_panel.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BannerAdsScreen extends StatelessWidget {
  const BannerAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BannerAdsCubit()..fetchBannerAds(),
      child: DashboardScaffold(
        currentRoute: 'banner_ads',
        title: 'إدارة الإعلانات',
        subtitle:
            'تحكم بالبانرات الدعائية، ترتيبها، حالتها النشطة وصورتها النهائية بنفس هوية المتجر.',
        child: BlocConsumer<BannerAdsCubit, BannerAdsState>(
          listener: (BuildContext context, BannerAdsState state) {
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
          builder: (BuildContext context, BannerAdsState state) {
            final BannerAdsCubit cubit = context.read<BannerAdsCubit>();
            final bool isBusy =
                state is BannerAdsLoading || state is BannerAdsSaving;

            if (state is BannerAdsLoading && cubit.ads.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: BannerAdsListPanel(cubit: cubit, isBusy: isBusy),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: BannerAdsFormPanel(cubit: cubit, isBusy: isBusy),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
