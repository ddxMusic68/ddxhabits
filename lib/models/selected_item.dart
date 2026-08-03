enum SelectedType { journal, grid, chain, jar, contract, timed }

class SelectedItem {
  final SelectedType type;
  final int index;
  const SelectedItem(this.type, this.index);
}
