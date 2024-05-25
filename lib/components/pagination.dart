import 'package:flutter/material.dart';

class Pagination extends StatefulWidget {
  Pagination({
    Key? key,
    required this.page,
    required this.totalPage,
    this.enabled = true,
    this.height = 12,
    this.shadow = true,
    this.onTap,
  }) : super(key: key);

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

  void _indexChange(_key, _index, _page) {
    if (_key[_index].currentContext != null) {
      Scrollable.ensureVisible(
        _key[_index].currentContext,
        alignment: 0.5,
      );
    }
    if (widget.onTap != null) {
      widget.onTap!(_page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<GlobalKey> _key =
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
              onTap: (widget.enabled && _currentPage > 1)
                  ? () {
                      setState(() {
                        _currentPage--;
                        _indexChange(_key, _currentPage - 1, _currentPage);
                      });
                    }
                  : () {},
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
                        key: _key[index],
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
                            _indexChange(_key, index, _currentPage);
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
              onTap: (_currentPage < widget.totalPage)
                  ? () {
                      setState(() {
                        _currentPage++;
                        _indexChange(_key, _currentPage - 1, _currentPage);
                      });
                    }
                  : () {},
            ),
          ),
        ],
      ),
    );
  }
}
