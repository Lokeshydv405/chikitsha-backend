import 'dart:async';
import 'dart:convert';
import 'package:chikitsha_munshi/core/config/app_config.dart';
import 'package:chikitsha_munshi/screens/Packages/PackageDetailsPage.dart';
import 'package:chikitsha_munshi/screens/home/widgets/Packagecard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SearchResultsPage extends StatefulWidget {
  final String query;
  final List<String>? selectedTags;
  const SearchResultsPage({Key? key, required this.query, this.selectedTags}) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<dynamic> _results = [];
  bool _loading = true;

  // Sorting
  String _selectedSort = "Relevance";
  final List<String> _sortOptions = [
    "Relevance",
    "Name A–Z",
    "Name Z–A",
    "Price Low–High",
    "Price High–Low",
    "Rating High–Low",
    "Newest",
    "Popular",
  ];

  // Tags
  List<String> _availableTags = [];
  List<String> _selectedTags = [];

  // Search
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _searchController.addListener(_onSearchChanged);
    // If tags are passed from HomePage, pre-select them
    if (widget.selectedTags != null && widget.selectedTags!.isNotEmpty) {
      _selectedTags = List<String>.from(widget.selectedTags!);
    }
    // initial fetch
    _fetchResults();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Debounced live search: updates results ~300ms after typing stops
  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.trim().isNotEmpty || _selectedTags.isNotEmpty) {
        setState(() => _loading = true);
        _fetchResults();
      } else {
        setState(() {
          _results = [];
          _availableTags = [];
          _loading = false;
        });
      }
    });
  }

  Future<void> _fetchResults() async {
    try {
      final searchText = _searchController.text.trim();

      final tagsParam = _selectedTags.isNotEmpty
          ? '&tags=${Uri.encodeComponent(_selectedTags.join(","))}'
          : '';

      final encodedSearch = Uri.encodeComponent(searchText);
      final url =
          '${AppConfig.serverUrl}/api/packages/search?search=$encodedSearch$tagsParam';

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Collect unique tags (for filter chips)
        final Set<String> tagSet = {};
        for (var pkg in data) {
          if (pkg['tags'] != null) {
            try {
              tagSet.addAll(List<String>.from(pkg['tags'].map((t) => t.toString())));
            } catch (_) {}
          }
        }

        setState(() {
          _results = data;
          _loading = false;

          // ensure selected tags stay visible even if missing from new results
          // _availableTags should be unselected tags only (we show selected tags separately)
          _availableTags = tagSet.toList();
          _applySorting();
        });
      } else {
        // non-200
        setState(() {
          _results = [];
          _availableTags = [];
          _loading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching search results: $e");
      setState(() {
        _results = [];
        _availableTags = [];
        _loading = false;
      });
    }
  }

  void _applySorting() {
    setState(() {
      try {
        switch (_selectedSort) {
          case "Name A–Z":
            _results.sort((a, b) => (a['name'] ?? "").compareTo(b['name'] ?? ""));
            break;
          case "Name Z–A":
            _results.sort((a, b) => (b['name'] ?? "").compareTo(a['name'] ?? ""));
            break;
          case "Price Low–High":
            _results.sort((a, b) =>
                (a['offerPrice'] ?? 0).compareTo(b['offerPrice'] ?? 0));
            break;
          case "Price High–Low":
            _results.sort((a, b) =>
                (b['offerPrice'] ?? 0).compareTo(a['offerPrice'] ?? 0));
            break;
          case "Rating High–Low":
            _results.sort((a, b) =>
                ((b['lab']?['rating']) ?? 0).compareTo((a['lab']?['rating']) ?? 0));
            break;
          case "Newest":
            _results.sort((a, b) {
              final da = DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              final db = DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              return db.compareTo(da);
            });
            break;
          case "Popular":
            _results.sort((a, b) =>
                ((b['isPopular'] == true) ? 1 : 0).compareTo((a['isPopular'] == true) ? 1 : 0));
            break;
          default:
            // Relevance -> keep API order
            break;
        }
      } catch (e) {
        // If sorting fails for some reason, keep original list
        print("Sorting error: $e");
      }
    });
  }

  // Toggle tag selection (keeps selected tags in their own row)
  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      _loading = true;
    });
    _fetchResults();
  }

  // Remove single selected tag (used by chip delete icon)
  void _removeSelectedTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
      _loading = true;
    });
    _fetchResults();
  }

  // Clear all selected tags
  void _clearAllTags() {
    if (_selectedTags.isEmpty) return;
    setState(() {
      _selectedTags.clear();
      _loading = true;
    });
    _fetchResults();
  }

  // Unselected tags (availableTags minus selected)
  List<String> get _unselectedTags {
    return _availableTags.where((t) => !_selectedTags.contains(t)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Search"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // search bar (same look as home page)
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                // immediate fetch already handled by listener; keep for explicit submit
                if (_searchController.text.trim().isNotEmpty) {
                  setState(() => _loading = true);
                  _fetchResults();
                }
              },
              decoration: InputDecoration(
                hintText: 'Search by test name or package...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _availableTags = [];
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Selected tags row (always visible if any selected)
          if (_selectedTags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _selectedTags.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InputChip(
                              label: Text(
                                tag,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.blue,
                              onPressed: () {
                                // maybe toggle/unselect
                                _removeSelectedTag(tag);
                              },
                              onDeleted: () {
                                _removeSelectedTag(tag);
                              },
                              deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Clear all button
                  TextButton(
                    onPressed: _clearAllTags,
                    child: const Text("Clear all"),
                    style: TextButton.styleFrom(foregroundColor: Colors.black54),
                  ),
                ],
              ),
            ),

          // Sort + Unselected tags row
          if (_results.isNotEmpty || _unselectedTags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Sort dropdown
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      icon: const Icon(Icons.sort, color: Colors.black54),
                      items: _sortOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSort = val);
                          _applySorting();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Unselected tags horizontally scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _unselectedTags.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(tag, style: const TextStyle(color: Colors.black87)),
                              selected: false,
                              onSelected: (_) => _toggleTag(tag),
                              selectedColor: Colors.blue,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Results count
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${_results.length} result${_results.length == 1 ? '' : 's'}",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ),

          // Results list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(child: Text("No results found"))
                    : ListView.builder(
                        itemCount: _results.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final pkg = _results[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PackageCard(
                              labLogo: pkg['lab']?['logo'],
                              labName: pkg['lab']?['name'],
                              rating: (pkg['lab']?['rating'] ?? 0).toDouble(),
                              packageName: pkg['name'] ?? "Unknown",
                              description: pkg['description'] ?? "",
                              originalPrice: (pkg['originalPrice'] ?? 0).toDouble(),
                              offerPrice: (pkg['offerPrice'] ?? 0).toDouble(),
                              gender: pkg['gender'],
                              fastingRequired: pkg['fastingRequired'] ?? false,
                              fastingDuration: pkg['fastingDuration'],
                              reportTime: pkg['reportTime'],
                              testsIncluded: (pkg['testsIncluded'] as List?)
                                      ?.map((e) => Map<String, dynamic>.from(e))
                                      .toList() ??
                                  [],
                              isPopular: pkg['isPopular'] ?? false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PackageDetailsPage(
                                        packageId: pkg['id'] ?? pkg['_id']),
                                  ),
                                );
                              },
                              onAddToCart: () {
                                print("Added ${pkg['name']} to cart");
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
