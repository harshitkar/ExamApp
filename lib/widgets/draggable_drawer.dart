import 'package:flutter/material.dart';

class DraggableDrawer extends StatefulWidget {
  final double initialSize;
  final Widget child;

  const DraggableDrawer({
    super.key,
    required this.initialSize,
    required this.child,
  });

  @override
  _DraggableDrawerState createState() => _DraggableDrawerState();
}

class _DraggableDrawerState extends State<DraggableDrawer> {
  double _childSize = 0.3;
  double _dragStart = 0.0;
  final double _maxHeightFraction = 0.8;
  final double _minHeightFraction = 0.1;

  @override
  void initState() {
    super.initState();
    _childSize = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onVerticalDragStart: (details) {
          _dragStart = details.localPosition.dy;
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            double delta = _dragStart - details.localPosition.dy;
            double newSize = _childSize + delta / MediaQuery.of(context).size.height;
            _childSize = newSize.clamp(_minHeightFraction, _maxHeightFraction);
            _dragStart = details.localPosition.dy;
          });
        },
        child: Container(
          height: MediaQuery.of(context).size.height * _childSize,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Column(
            children: [
              Container(
                height: 10, // Height of the handle
                width: 80, // Width of the handle
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: widget.child,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
