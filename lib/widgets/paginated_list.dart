import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/paginated_result.dart';

typedef PageFetcher<T> = Future<PaginatedResult<T>> Function({DocumentSnapshot? startAfter, int limit});

class PaginatedList<T> extends StatefulWidget {
  final PageFetcher<T> fetchPage;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final int pageSize;
  final bool shrinkWrap;

  const PaginatedList({super.key, required this.fetchPage, required this.itemBuilder, this.pageSize = 20, this.shrinkWrap = false});

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  final ScrollController _ctrl = ScrollController();
  List<T> _items = [];
  DocumentSnapshot? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _ctrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onScroll);
    _ctrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loading) return;
    if (_ctrl.position.pixels >= _ctrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFirst() async {
    setState(() => _loading = true);
    try {
      final res = await widget.fetchPage(limit: widget.pageSize);
      setState(() {
        _items = res.items;
        _lastDoc = res.lastDocument;
        _hasMore = res.hasMore;
      });
    } catch (e) {
      debugPrint('Error loading page: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final res = await widget.fetchPage(startAfter: _lastDoc, limit: widget.pageSize);
      setState(() {
        _items.addAll(res.items);
        _lastDoc = res.lastDocument ?? _lastDoc;
        _hasMore = res.hasMore;
      });
    } catch (e) {
      debugPrint('Error loading more: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading && _items.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            controller: _ctrl,
            shrinkWrap: widget.shrinkWrap,
            itemCount: _items.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _items.length) {
                return widget.itemBuilder(context, _items[index], index);
              }
              // load more indicator
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: _loading ? const CircularProgressIndicator() : TextButton(onPressed: _loadMore, child: const Text('Charger plus')),
                ),
              );
            },
          );
  }
}
