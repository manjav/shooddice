import 'package:flutter/material.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/utils.dart';

class CoinEffect extends StatefulWidget {
  final int count;
  CoinEffect(this.count);
  @override
  _CoinEffectState createState() => _CoinEffectState();
}

class _CoinEffectState extends State<CoinEffect> with TickerProviderStateMixin {
  Animation<double>? _sizeIn;
  Animation<double>? _x;
  Animation<double>? _y;
  Animation<double>? _sizeOut;
  Animation<EdgeInsets>? _padding;
  Animation<double>? _opacity;

  late AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 2000), vsync: this);

  @override
  void initState() {
    _createAnimation();
    Sound.play("coin");
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Sound.play("button-down");
        Navigator.pop(context);
      }
    });
    _controller.forward().orCancel;
    super.initState();
  }

  void _createAnimation() {
    var w = Device.size.width;
    var h = Device.size.height;
    _sizeIn = _getAnimation(0.0, 64.d, 0, 0.2, Curves.easeOutBack);
    _x = _getAnimation(w * 0.38, w * 0.255, 0.5, 0.8, Curves.easeInSine);
    _y = _getAnimation(h * 0.5, h * 0.051, 0.5, 0.8, Curves.easeInExpo);
    _sizeOut = _getAnimation(74.d, 30.d, 0.5, 0.8, Curves.easeInSine);
    _opacity = _getAnimation(1, 0, 0.8, 0.9, Curves.ease);
    _padding = EdgeInsetsTween(
      begin: EdgeInsets.only(left: 0),
      end: EdgeInsets.only(left: 66.d),
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1, 0.25, curve: Curves.easeOutBack)));
  }

  Animation<double> _getAnimation(double begin, double end,
      double intervalBegin, double intervalEnd, Curve curve) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          intervalBegin,
          intervalEnd,
          curve: curve,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: _controller,
    );
  }

  // This function is called each time the controller "ticks" a new frame.
  // When it runs, all of the animation's values will have been
  // updated to reflect the controller's current value.
  Widget _buildAnimation(BuildContext context, Widget? child) {
    var theme = Theme.of(context);
    return Opacity(
        opacity: _opacity!.value,
        child: Stack(alignment: Alignment.center, children: [
          Positioned(
              left: _x!.value - 30.d,
              top: _y!.value + _sizeOut!.value * 0.14,
              child: Padding(
                  padding: _padding!.value,
                  child: Text("+${widget.count}",
                      style: theme.textTheme.button!
                          .copyWith(fontSize: _sizeOut!.value * 0.5)))),
          Positioned(
              top: _y!.value,
              left: _x!.value - _sizeIn!.value * 0.5,
              child: Container(
                  width: _sizeIn!.value,
                  alignment: Alignment.center,
                  child: SizedBox(
                      height: _sizeOut!.value, child: SVG.show("coin", 72.d))))
        ]));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
