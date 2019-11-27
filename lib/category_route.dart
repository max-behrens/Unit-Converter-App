import 'package:flutter/material.dart';
import 'package:unit_converter/backdrop.dart';
import 'package:unit_converter/category_tile.dart';
import 'package:unit_converter/unit_converter.dart';
import 'category.dart';
import 'unit.dart';
import 'dart:convert';
import 'dart:async';

class CategoryRoute extends StatefulWidget {
  @override
  _CategoryRouteState createState() => _CategoryRouteState();
}

class _CategoryRouteState extends State<CategoryRoute> {
  final _categories = <Category>[];
  Category _defaultCategory;
  Category _currentCategory;

  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xB3A357F9, {
      'highlight': Color(0xB3A357F9),
      'splash': Color(0xFFA357F9),
    }),
    ColorSwatch(0xB35757F9, {
      'highlight': Color(0xB35757F9),
      'splash': Color(0xFF5757F9),
    }),
    ColorSwatch(0xB3578DF9, {
      'highlight': Color(0xB3578DF9),
      'splash': Color(0xFF578DF9),
    }),
    ColorSwatch(0xB342E5D5, {
      'highlight': Color(0xB342E5D5),
      'splash': Color(0xFF42E5D5),
    }),
    ColorSwatch(0xB33CD173, {
      'highlight': Color(0xB33CD173),
      'splash': Color(0xFF3CD173),
    }),
    ColorSwatch(0xB3C2DE54, {
      'highlight': Color(0xB3C2DE54),
      'splash': Color(0xFFC2DE54),
    }),
    ColorSwatch(0xB3E5A950, {
      'highlight': Color(0xB3E5A950),
      'splash': Color(0xFFE5A950),
    }),
    ColorSwatch(0xB3DE7454, {
      'highlight': Color(0xB3DE7454),
      'splash': Color(0xFFDE7454),
      'error': Color(0xFFC14E2B),
    }),
  ];

  static const _icons = <String>[
    'assets/icons/length.png',
    'assets/icons/area.png',
    'assets/icons/volume.png',
    'assets/icons/mass.png',
    'assets/icons/time.png',
    'assets/icons/currency.png',
    'assets/icons/digital_storage.png',
    'assets/icons/power.png',
  ];

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    // We have static unit conversions located in our
    // assets/data/regular_units.json.

    if (_categories.isEmpty) {
      await _retrieveLocalCategories();
    }
  }

  Future<void> _retrieveLocalCategories() async {
    final regularUnitsJson = DefaultAssetBundle.of(context)
        .loadString('assets/data/regular_units.json');
    final unitsData = JsonDecoder().convert(await regularUnitsJson);
    if (unitsData is! Map) {
      throw ("Date retreived from API is not Map");
    }
    var categoryIndex = 0;
    unitsData.keys.forEach((key) {
      final List<Unit> units = unitsData[key]
          .map<Unit>((dynamic data) => Unit.fromJson(data))
          .toList();

      var category = Category(
          name: key,
          units: units,
          color: _baseColors[categoryIndex],
          iconLocation: _icons[categoryIndex]);
      setState(() {
        if (categoryIndex == 0) {
          _defaultCategory = category;
        }
        _categories.add(category);
      });
      categoryIndex++;
    });
  }




  void _onCategoryTap(Category category) {
    setState(() {
      print("Option pressed");
      _currentCategory = category;
    });
  }

  Widget _buildCategories(Orientation deviceOrientation) {
    if (deviceOrientation == Orientation.portrait) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          var _category = _categories[index];
          return CategoryTile(
            category: _category,
            onTap: _category.units.isEmpty
                ? null
                : _onCategoryTap,
          );
        },
        itemCount: _categories.length,
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        children: _categories.map((Category category) {
          return CategoryTile(
            category: category,
            onTap: _onCategoryTap,
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Center(
        child: Container(
          height: 180.0,
          width: 180.0,
          child: CircularProgressIndicator(),
        ),
      );
    }

    final listView = Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 48.0,
      ),
      child: _buildCategories(MediaQuery.of(context).orientation),
    );

    return Backdrop(
      currentCategory:
          _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? UnitConverter(category: _defaultCategory)
          : UnitConverter(category: _currentCategory),
      backPanel: listView,
      frontTitle: Text('Unit Converter'),
      backTitle: Text('Menu'),
    );
  }
}
