import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../utils/constants.dart';

class PageSkeleton extends StatelessWidget {
  const PageSkeleton({
    super.key,
    required this.height,
    required this.width,
  });
  final double height, width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(kDefaultPadding / 2),
      decoration: BoxDecoration(
        color: kPageSkeletonColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}
