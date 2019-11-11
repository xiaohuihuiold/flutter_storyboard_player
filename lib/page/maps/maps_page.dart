import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 地图列表页
class MapsPage extends StatefulWidget {
  static const routerName = '/maps';

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  ScrollController _controller = ScrollController();

  int _selectIndex;
  int _selectIndexA;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.all(40.0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.grey),
                  child: Text(
                    'TITLE $_selectIndexA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 50.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              controller: _controller,
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: List.generate(
                  50,
                  (index) {
                    return GestureDetector(
                      onTap: () {
                        _controller.animateTo(
                          (index - 3) * 60.0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                        );
                      },
                      child: _ListItem(
                        controller: _controller,
                        selected: () {
                          _selectIndexA = index;
                          _selectIndex = index;
                        },
                        child: Container(
                          width: 400.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: _selectIndex == index
                                ? Colors.pink
                                : Colors.pinkAccent.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8.0,
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 12.0),
                              Icon(
                                Icons.image,
                                color: Colors.black26,
                                size: 36.0,
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                'TITLE $index',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItem extends SingleChildRenderObjectWidget {
  final ScrollController controller;
  final Function selected;

  _ListItem({
    Key key,
    Widget child,
    this.controller,
    this.selected,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    _ListItemRenderBox renderBox = _ListItemRenderBox(context, selected);
    controller?.addListener(() {
      renderBox?.markNeedsPaint();
    });
    return renderBox;
  }
}

class _ListItemRenderBox extends RenderProxyBox {
  final BuildContext context;

  final Function selected;
  Size screenSize;

  _ListItemRenderBox(this.context, this.selected) {
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    double height = screenSize.height;

    Offset position = localToGlobal(Offset.zero);
    double positionMiddle = (position.dy + (child.size.height / 2.0));
    double diff = sin((positionMiddle / height) * 2 - 1);
    if ((position.dy - (height / 2.0 - child.size.height / 2.0)).abs() <=
        child.size.height / 2.0) {
      if (selected != null) {
        selected();
      }
    }

    context.paintChild(
        child,
        Offset((diff.abs() * 0.4) * size.width + offset.dx,
            -(diff * 0.3) * size.height + offset.dy));
  }

  @override
  bool get alwaysNeedsCompositing => child != null;
}
