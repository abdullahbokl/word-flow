enum WordSort {
  frequencyDesc('Frequency (High to Low)'),
  frequencyAsc('Frequency (Low to High)'),
  recent('Recently Updated'),
  alphabetical('Alphabetical (A-Z)');

  const WordSort(this.label);
  final String label;
}
