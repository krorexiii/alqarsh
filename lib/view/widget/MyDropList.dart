import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class MyDropList extends StatelessWidget {
  const MyDropList({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.hint,
    required this.onChanged,
    this.isSearchable,
  });

  final List<String> items;
  final String? selectedItem;
  final String hint;
  final ValueChanged<String?>? onChanged;
  final bool? isSearchable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            child: MyText(
              hint,
              fontSize: 15,
              color: ConstVar.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          _DropDownField(
            items: items,
            selectedItem: selectedItem,
            hint: hint,
            onChanged: onChanged,
            isSearchable: isSearchable ?? false,
            icon: Icons.keyboard_arrow_down_rounded,
          ),
        ],
      ),
    );
  }
}

class MyDropListBorder extends StatelessWidget {
  const MyDropListBorder({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.hint,
    required this.onChanged,
    this.icon,
    this.isFeilled,
    this.isSearchable,
  });

  final List<String> items;
  final String? selectedItem;
  final String hint;
  final ValueChanged<String?>? onChanged;
  final bool? isSearchable;
  final IconData? icon;
  final bool? isFeilled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _DropDownField(
        items: items,
        selectedItem: selectedItem,
        hint: hint,
        onChanged: onChanged,
        isSearchable: isSearchable ?? false,
        icon: icon,
        filled: isFeilled ?? true,
      ),
    );
  }
}

class MyDropListBorderSide extends StatelessWidget {
  const MyDropListBorderSide({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.hint,
    required this.onChanged,
    this.icon,
    this.isFeilled,
    this.isSearchable,
  });

  final List<String> items;
  final String? selectedItem;
  final String hint;
  final ValueChanged<String?>? onChanged;
  final bool? isSearchable;
  final IconData? icon;
  final bool? isFeilled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: _DropDownField(
        items: items,
        selectedItem: selectedItem,
        hint: hint,
        onChanged: onChanged,
        isSearchable: isSearchable ?? false,
        icon: icon,
        filled: isFeilled ?? true,
        dense: true,
      ),
    );
  }
}

class MyDropListWithOutBorder extends StatelessWidget {
  const MyDropListWithOutBorder({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.hint,
    required this.onChanged,
    this.isSearchable,
  });

  final List<String> items;
  final String? selectedItem;
  final String hint;
  final ValueChanged<String?>? onChanged;
  final bool? isSearchable;

  @override
  Widget build(BuildContext context) {
    return _DropDownField(
      items: items,
      selectedItem: selectedItem,
      hint: hint,
      onChanged: onChanged,
      isSearchable: isSearchable ?? false,
      borderless: true,
    );
  }
}

class _DropDownField extends StatelessWidget {
  const _DropDownField({
    required this.items,
    required this.selectedItem,
    required this.hint,
    required this.onChanged,
    required this.isSearchable,
    this.icon,
    this.filled = true,
    this.dense = false,
    this.borderless = false,
  });

  final List<String> items;
  final String? selectedItem;
  final String hint;
  final ValueChanged<String?>? onChanged;
  final bool isSearchable;
  final IconData? icon;
  final bool filled;
  final bool dense;
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(dense ? 14 : 18),
      borderSide: borderless
          ? BorderSide.none
          : const BorderSide(color: ConstVar.borderColor),
    );

    return DropdownSearch<String>(
      popupProps: PopupProps.menu(
        showSearchBox: isSearchable,
        searchFieldProps: const TextFieldProps(
          textDirection: TextDirection.rtl,
        ),
        menuProps: MenuProps(
          backgroundColor: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      items: (_, __) => items,
      onChanged: onChanged,
      selectedItem: selectedItem,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: hint,
          filled: filled,
          fillColor: filled ? Colors.white : Colors.transparent,
          prefixIcon: icon == null
              ? null
              : Icon(icon, color: ConstVar.pColor, size: dense ? 18 : 20),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: dense ? 12 : 16,
          ),
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: ConstVar.pColor, width: 1.4),
          ),
          border: border,
        ),
      ),
    );
  }
}
