import 'package:keuangan/providers/menu_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class SearchInput extends StatefulWidget {
  SearchInput({
    Key? key,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.onReset,
    this.onSaved,
  }) : super(key: key);

  String? initialValue;
  ValueChanged<String?>? onChanged;
  VoidCallback? onEditingComplete;
  VoidCallback? onReset;
  FormFieldSetter<String>? onSaved;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final TextEditingController _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _menuBloc = context.watch<MenuBloc>();

    Color rColor = _menuBloc.activeTab == 0
        ? Colors.black54
        : _menuBloc.activeTab == 1
            ? Colors.green.shade700
            : _menuBloc.activeTab == 2
                ? Colors.pink
                : _menuBloc.activeTab == 3
                    ? Colors.amber.shade700
                    : _menuBloc.activeTab == 4
                        ? Colors.blue
                        : Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: FormBuilderTextField(
              controller: _search,
              name: 'search',
              style: TextStyle(
                color: rColor,
              ),
              cursorColor: rColor,
              onChanged: (value) {
                _menuBloc.search = value!;
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              onEditingComplete: () {
                if (widget.onEditingComplete != null) {
                  widget.onEditingComplete!();
                }
              },
              onReset: () {
                _search.text = '';
                _search.clear();
                _menuBloc.search = '';
                if (widget.onReset != null) {
                  widget.onReset!();
                }
              },
              onSaved: widget.onSaved,
              decoration: InputDecoration(
                labelText: 'Cari menu',
                hintText: 'Cari menu',
                labelStyle: TextStyle(
                  color: rColor,
                ),
                hintStyle: TextStyle(
                  color: rColor,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: rColor,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.min(4),
                FormBuilderValidators.max(255),
              ]),
              keyboardType: TextInputType.text,
            ),
          ),
          _menuBloc.search != ""
              ? Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Icon(
                        Icons.close,
                        color: rColor,
                      ),
                    ),
                    onTap: () {
                      _search.text = '';
                      _search.clear();
                      _menuBloc.search = '';
                      if (widget.onReset != null) {
                        widget.onReset!();
                      }
                    },
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
