import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constVar.dart';
import 'myText.dart';

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
  final Function(String?)? onChanged;
  final bool? isSearchable;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: MyText(
              hint,
              fontSize: 14,
              color: ConstVar.pColor!,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: DropdownSearch<String>(
              popupProps: PopupProps.menu(showSearchBox: isSearchable ?? false),
              items: (filter, loadProps) {
                return items;
              },
              onChanged: onChanged,
              selectedItem: selectedItem,
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
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
  final Function(String?)? onChanged;
  final bool? isSearchable;
  final IconData? icon;
  final bool? isFeilled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: MyText(
              hint,
              fontSize: 14,
              color: ConstVar.pColor!,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownSearch<String>(
            popupProps: PopupProps.menu(showSearchBox: isSearchable ?? false),
            items: (filter, loadProps) {
              return items;
            },
            onChanged: onChanged,

            selectedItem: selectedItem,
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: GoogleFonts.zain().fontFamily,
                ),
                labelStyle: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: GoogleFonts.zain().fontFamily,
                ),
                prefixIcon: Icon(icon, color: ConstVar.pColor),
                hintText: hint,
                filled: isFeilled,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
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
  final Function(String?)? onChanged;
  final bool? isSearchable;
  final IconData? icon;
  final bool? isFeilled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: DropdownSearch<String>(
        popupProps: PopupProps.menu(showSearchBox: isSearchable ?? false),
        items: (filter, loadProps) {
          return items;
        },
        onChanged: onChanged,

        selectedItem: selectedItem,
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            isDense: true,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontFamily: GoogleFonts.zain().fontFamily,
              fontSize: 12,
            ),
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontFamily: GoogleFonts.zain().fontFamily,
              fontSize: 12,
            ),
            prefixIcon: Icon(icon, color: ConstVar.pColor, size: 18),
            hintText: hint,
            filled: isFeilled,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
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
  final Function(String?)? onChanged;
  final bool? isSearchable;
  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      popupProps: PopupProps.menu(showSearchBox: isSearchable ?? false),
      items: (filter, loadProps) {
        return items;
      },
      onChanged: onChanged,
      selectedItem: selectedItem,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: GoogleFonts.zain().fontFamily,
          ),
          hintText: hint,
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
