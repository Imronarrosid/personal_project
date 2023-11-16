String? validateNoWhitespace(String? value) {
  if (value!.contains(RegExp(r'\s'))) {
    return 'Nama pengguna tidak boleh menggunakan spasi.';
  } else if (value.isEmpty) {
    return 'Nama Pengguna tidak boleh kosong.';
  } else if (value.trim().isEmpty) {
    return 'Nama pengguna tidak boleh diawali spasi.';
  }
  return null; // Return null if the input is valid
}
