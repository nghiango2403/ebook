enum BookStatus {
  completed("Hoàn thành"),
  ongoing("Còn tiếp"),
  onHold("Tạm ngưng");

  final String label;
  const BookStatus(this.label);

  static BookStatus fromString(String status) {
    return BookStatus.values.firstWhere(
          (e) => e.label == status || e.name == status,
      orElse: () => BookStatus.ongoing,
    );
  }
}