enum SelectedType { journal, grid, chain, jar, contract }

class SelectedItem {
  final SelectedType type;
  final int index;
  const SelectedItem(this.type, this.index);
}
