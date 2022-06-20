import 'package:flutter/material.dart';

import '../core/constants/dimensions.dart';

class Pill extends StatelessWidget {
  final double? width;
  final String text;

  const Pill({
    Key? key,
    this.width = 100,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.tiny,
        horizontal: Dimensions.small,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondaryVariant,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
