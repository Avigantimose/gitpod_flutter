import 'dart:math' as Math;
import 'package:flutter/widgets.dart';

class ArrowTile extends StatefulWidget {
  final Key key;
  final bool isBackwards;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Alignment alignment;
  final double width;
  final double height;
  final double arrowTipLength;
  final double backArrowTipLength;
  final double strokeWidth;
  final Color color;
  final Color strokeColor;
  final Widget child;

  ArrowTile({
    this.key,
    this.child,
    @required this.isBackwards,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(8),
    this.alignment = Alignment.centerLeft,
    this.width,
    this.height,
    @required this.arrowTipLength,
    @required this.backArrowTipLength,
    @required this.strokeWidth,
    @required this.color,
    @required this.strokeColor,
  }) :
    assert(isBackwards != null),
    assert(margin != null),
    assert(padding != null),
    assert(alignment != null),
    assert(arrowTipLength != null),
    assert(backArrowTipLength != null),
    assert(strokeWidth != null),
    assert(color != null),
    assert(strokeColor != null),
    super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ArrowTileState();
  }

}

class ArrowTileState extends State<ArrowTile> {
  ArrowTilePainter arrowTilePainter;

  @override
  void initState() {
    super.initState();
    arrowTilePainter = ArrowTilePainter(
      isBackwards: widget.isBackwards,
      arrowTipLength: widget.arrowTipLength,
      backArrowTipLength: widget.backArrowTipLength,
      color: widget.color,
      strokeColor: widget.strokeColor,
      shadowColor: const Color.fromRGBO(0, 0, 0, 1),
      strokeWidth: widget.strokeWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget arrowTile = Container(
      alignment: widget.alignment,
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: arrowTilePainter,
        isComplex: false,
        willChange: false,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: widget.padding.add(widget.isBackwards ?
            EdgeInsets.only(left: widget.arrowTipLength, right: widget.backArrowTipLength.abs()) :
            EdgeInsets.only(right: widget.arrowTipLength, left: widget.backArrowTipLength.abs())),
          child: widget.child
        ),
      )
    );

    return arrowTile;
  }

}

class ArrowTilePainter extends CustomPainter{
  final bool isBackwards;
  final double arrowTipLength;
  final double backArrowTipLength;
  final Color color;
  final Color shadowColor;
  final Color strokeColor;
  final double strokeWidth;

  Path arrowPath = Path();
  Paint linePaint = Paint();
  Paint fillPaint = Paint();

  ArrowTilePainter({
    @required this.arrowTipLength,
    @required this.backArrowTipLength,
    @required this.isBackwards,
    @required this.color,
    @required this.strokeColor,
    @required this.shadowColor,
    @required this.strokeWidth,
  }){
    fillPaint.style = PaintingStyle.fill;
    fillPaint.color = color;
    linePaint.style = PaintingStyle.stroke;
    linePaint.color = strokeColor;
    linePaint.strokeWidth = strokeWidth;
  }

  @override
  bool hitTest(Offset position) {
    return arrowPath.contains(position);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Heights
    double arrowLength = size.width;
    double arrowHeight = size.height;
    double arrowHalfHeight = arrowHeight / 2;

    // Widths
    double backArrowSides;
    double backArrowPoint;
    double frontArrowSides;
    double frontArrowPoint;

    arrowPath.reset();
    if (!isBackwards) {
      /**
       *  back           front
       *   _______________
       *  \               \
       *   \               \
       *    \               \
       *    /               /
       *   /               /
       *  /_______________/
       *
       */
      backArrowSides = backArrowTipLength <= 0 ? 0 : backArrowTipLength;
      backArrowPoint = backArrowTipLength >= 0 ? 0 : -backArrowTipLength;
      frontArrowSides = arrowTipLength <= 0 ? arrowLength : arrowLength - arrowTipLength;
      frontArrowPoint = arrowTipLength >= 0 ? arrowLength : arrowLength - arrowTipLength;
    } else {
      /**
       *    front           back
       *      ________________
       *     /                /
       *    /                /
       *   /                /
       *   \                \
       *    \                \
       *     \________________\
       */
      backArrowSides = backArrowTipLength <= 0 ? arrowLength : arrowLength - backArrowTipLength;
      backArrowPoint = backArrowTipLength >= 0 ? arrowLength : arrowLength + backArrowTipLength;
      frontArrowSides = arrowTipLength <= 0 ? 0 : arrowTipLength;
      frontArrowPoint = arrowTipLength >= 0 ? 0 : -arrowTipLength;
    }
    arrowPath
      ..moveTo(backArrowSides, 0)
      ..lineTo(frontArrowSides, 0)
      ..lineTo(frontArrowPoint, arrowHalfHeight)
      ..lineTo(frontArrowSides, arrowHeight)
      ..lineTo(backArrowSides, arrowHeight)
      ..lineTo(backArrowPoint, arrowHalfHeight)
      ..close();
    canvas
      ..drawPath(arrowPath, fillPaint)
      ..drawPath(arrowPath, linePaint);
  }

  @override
  bool shouldRepaint(ArrowTilePainter oldDelegate) =>
    arrowTipLength != oldDelegate.arrowTipLength
    || fillPaint != oldDelegate.fillPaint
    || linePaint != oldDelegate.linePaint
    || isBackwards != oldDelegate.isBackwards
    || color != oldDelegate.color
    || strokeColor != oldDelegate.strokeColor
    || shadowColor != oldDelegate.shadowColor;
}