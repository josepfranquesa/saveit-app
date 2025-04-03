import 'package:SaveIt/utils/helpers/utils_functions.dart';
import 'package:SaveIt/utils/ui/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class SaveItCard extends StatelessWidget {
  const SaveItCard({
    super.key,
    this.width,
    this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(25)),
    this.color = Colors.white,
    this.withElevation = true,
    this.padding = const EdgeInsets.all(20),
    this.margin
  });

  final double? width;
  final Widget? child;
  final BorderRadiusGeometry borderRadius;
  final Color color;
  final bool withElevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color,
        boxShadow: withElevation ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ] : null,
      ),
      width: width ?? double.infinity,
      child: child ?? Container(),
    );
  }
}

class SaveItCardPage extends StatelessWidget {
  const SaveItCardPage({
    super.key,
    this.height,
    this.width,
    this.child,
    this.borderRadius = const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
    this.color = Colors.white
  });

  final double? height;
  final double? width;
  final Widget? child;
  final BorderRadiusGeometry borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      height: height ?? double.infinity,
      width: width ?? double.infinity,
      child: child ?? Container(),
    );
  }
}

class InsuranceCard extends StatelessWidget {
  const InsuranceCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(25)),
    this.text,
    this.type,
    this.color,
    this.textColor
  });

  final double? width;
  final double? height;
  final String? text;
  final String? type;
  final BorderRadiusGeometry borderRadius;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    Color c = color ?? AppUtils.insuranceBranchToColor(type);
    double iconSize = width!=null ? width! * 0.5 : 100;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: c,
      ),
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: insuranceBranchToIcon(type??'', size: iconSize, color: AppUtils.makeColorBrighter(c, 0.3)),
          ),
          Center(
            child: Text(
              text??'',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}