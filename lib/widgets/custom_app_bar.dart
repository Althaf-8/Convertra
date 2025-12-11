import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showSearch;
  final bool showMenu;
  final VoidCallback? onSearchPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.showSearch = false,
    this.showMenu = false,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[700],
      foregroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      centerTitle: centerTitle,
      actions:
          actions ??
          [
            if (showSearch)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: onSearchPressed,
              ),
            if (showMenu)
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Add menu functionality
                },
              ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
