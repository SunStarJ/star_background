import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../generated/assets.dart';

class UfoFront extends StatefulWidget {
  final Offset offset;

  const UfoFront({super.key, required this.offset});

  @override
  State<UfoFront> createState() => _UfoFrontState();
}

class _UfoFrontState extends State<UfoFront> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: SvgPicture.asset(Assets.svgUFO),
      width: 30,
      height: 30,
      left: widget.offset.dx + 15,
      top: widget.offset.dy + 15,
    );
  }
}
