import 'package:flutter/material.dart';

class Pagination extends StatefulWidget {
  Pagination({
    super.key,
    required this.page,
    required this.totalPage,
    this.enabled = true,
    this.height = 12,
    this.shadow = true,
    this.onTap,
  });

  final int page;
  final int totalPage;
  bool enabled;
  double height;
  bool shadow;
  dynamic onTap;

  @override
  State<Pagination> createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentPage = widget.page;
    });
  }

  void _indexChange(fkey, findex, fpage) {
    if (fkey[findex].currentContext != null) {
      Scrollable.ensureVisible(
        fkey[findex].currentContext,
        alignment: 0.5,
      );
    }
    if (widget.onTap != null) {
      widget.onTap!(fpage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<GlobalKey> gkey =
        List.generate(widget.totalPage, (index) => GlobalKey());

    return Container(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: 0,
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.shadow
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 0.2,
                  offset: const Offset(0, 0.1), // changes position of shadow
                ),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: (widget.enabled && _currentPage > 1)
                  ? () {
                      setState(() {
                        _currentPage--;
                        _indexChange(gkey, _currentPage - 1, _currentPage);
                      });
                    }
                  : () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 4,
                  top: 6,
                  bottom: 6,
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: (widget.enabled && _currentPage > 1)
                      ? Colors.black
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    for (var index = 0; index < widget.totalPage; index++)
                      InkWell(
                        key: gkey[index],
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentPage == (index + 1)
                                ? Colors.grey.shade300
                                : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: widget.height,
                            horizontal: 12,
                          ),
                          margin: const EdgeInsets.only(right: 4),
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              fontWeight: _currentPage == (index + 1)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _currentPage = index + 1;
                            _indexChange(gkey, index, _currentPage);
                          });
                        },
                      )
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: (_currentPage < widget.totalPage)
                  ? () {
                      setState(() {
                        _currentPage++;
                        _indexChange(gkey, _currentPage - 1, _currentPage);
                      });
                    }
                  : () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: (_currentPage < widget.totalPage)
                      ? Colors.black
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
