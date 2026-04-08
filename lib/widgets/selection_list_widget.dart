import 'package:flutter/material.dart';

class SelectionItem {
  final String id;
  final String title;
  final String? emoji;
  final String? category;

  SelectionItem({
    required this.id,
    required this.title,
    this.emoji,
    this.category,
  });
}

class SelectionListWidget extends StatelessWidget {
  final List<SelectionItem> items;
  final List<String> selectedItems;
  final Function(String) onItemSelected;
  final Function(String) onItemDeselected;
  final bool singleSelection;

  const SelectionListWidget({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onItemSelected,
    required this.onItemDeselected,
    this.singleSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final isSelected = selectedItems.contains(item.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                if (isSelected) {
                  onItemDeselected(item.id);
                } else {
                  onItemSelected(item.id);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    if (item.emoji != null) ...[
                      Text(item.emoji!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
