  import 'dart:developer' as dev;

import '../../services/server_provider.dart';
import '../../view_models/product_view_model.dart';

double calculateBidPriceForDisplay(
      GoldRateProvider goldRateProvider, ProductViewModel productViewModel) {
    double originalBid = 0.0;
    double biddingPrice = 0.0;
    double askingPrice = 0.0;
    double bidPrice = 0.0;

    if (goldRateProvider.goldData != null) {
      originalBid =
          double.tryParse('${goldRateProvider.goldData!['bid']}') ?? 0.0;
      // dev.log("🟡 Original bid from socket for display: $originalBid");

      if (goldRateProvider.spotRateData != null) {
        double bidSpread = goldRateProvider.spotRateData!.goldBidSpread;
        double askSpread = goldRateProvider.spotRateData!.goldAskSpread;

        biddingPrice = originalBid + bidSpread;
        // dev.log(
        //     "🧮 Display bid calculation step 1: Bidding price = $originalBid (bid) + $bidSpread (bid spread) = $biddingPrice");

        askingPrice = biddingPrice + askSpread + 0.5;
        // dev.log(
        //     "🧮 Display bid calculation step 2: Asking price = $biddingPrice (bidding price) + $askSpread (ask spread) + 0.5 = $askingPrice");

        bidPrice = askingPrice / 31.103 * 3.674;
        // dev.log(
        //     "🧮 Display bid calculation step 3: Final price = $askingPrice / 31.103 × 3.674 = $bidPrice AED/g");
      } else {
        bidPrice = originalBid / 31.103 * 3.674;
        // dev.log(
        //     "⚠️ Display bid using original bid (no spot rates): $originalBid / 31.103 × 3.674 = $bidPrice AED/g");
      }
    } else {
      // dev.log("⚠️ Warning: Gold data is not available for display, using zero");
    }

    return bidPrice;
  }