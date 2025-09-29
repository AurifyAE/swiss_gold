import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/widgets/category_shimmer.dart';
import 'package:swiss_gold/core/view_models/company_profile_view_model.dart';
import 'package:swiss_gold/views/support/widgets/contact_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  VideoPlayerController? _videoController;
  bool isVideoInitialized = false;
  String? url;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final model =
          Provider.of<CompanyProfileViewModel>(context, listen: false);
      url = await model.fetchCompanyAd();
      _initializeVideo(url.toString());
      model.fetchCompanyProfile();
    });
  }

  Future<void> _initializeVideo(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();

    setState(() {
      isVideoInitialized = true;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: false,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProfileViewModel>(builder: (context, model, child) {
      if (model.state == ViewState.loading) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (index) => const CategoryShimmer(),
            ),
          ),
        );
      } else if (model.companyProfileModel == null) {
        return const SizedBox.shrink();
      } else {
        return Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.53,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    isVideoInitialized
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : Center(
                            heightFactor: 15.h,
                            child: CircularProgressIndicator(
                              color: UIColor.gold,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ContactCard(
                  icon: ImageAssets.whatsapp,
                  title: 'Whatsapp',
                  onTap: () async {
                    if (model.companyProfileModel?.userDetails.contact != null) {
                      await openUrl(
                        'https://wa.me/${model.companyProfileModel!.userDetails.contact}',
                      );
                    }
                  },
                ),
                ContactCard(
                  icon: ImageAssets.gmail,
                  title: 'Gmail',
                  onTap: () async {
                    if (model.companyProfileModel?.userDetails.email != null &&
                        model.companyProfileModel!.userDetails.email.isNotEmpty) {
                      await openUrl(
                        'mailto:${model.companyProfileModel!.userDetails.email}',
                      );
                    }
                  },
                ),
                ContactCard(
                  icon: ImageAssets.phone,
                  title: 'Contact',
                  onTap: () {
                    if (model.companyProfileModel?.userDetails.contact != null) {
                      openUrl(
                        'tel:${model.companyProfileModel!.userDetails.contact.toString()}',
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        );
      }
    });
  }
}
