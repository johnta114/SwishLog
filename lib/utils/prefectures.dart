/// 日本の47都道府県一覧（JIS X 0401 順）
const List<String> japanPrefectures = [
  '北海道',
  '青森県',
  '岩手県',
  '宮城県',
  '秋田県',
  '山形県',
  '福島県',
  '茨城県',
  '栃木県',
  '群馬県',
  '埼玉県',
  '千葉県',
  '東京都',
  '神奈川県',
  '新潟県',
  '富山県',
  '石川県',
  '福井県',
  '山梨県',
  '長野県',
  '岐阜県',
  '静岡県',
  '愛知県',
  '三重県',
  '滋賀県',
  '京都府',
  '大阪府',
  '兵庫県',
  '奈良県',
  '和歌山県',
  '鳥取県',
  '島根県',
  '岡山県',
  '広島県',
  '山口県',
  '徳島県',
  '香川県',
  '愛媛県',
  '高知県',
  '福岡県',
  '佐賀県',
  '長崎県',
  '熊本県',
  '大分県',
  '宮崎県',
  '鹿児島県',
  '沖縄県',
];

/// 入力された都道府県表記を標準の47都道府県名に正規化するヘルパー関数
String? normalizePrefecture(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == '未設定') return null;

  if (japanPrefectures.contains(trimmed)) {
    return trimmed;
  }

  // "東京" -> "東京都", "大阪" -> "大阪府" などの表記揺れ対応
  for (final pref in japanPrefectures) {
    if (pref.startsWith(trimmed) || trimmed.startsWith(pref)) {
      return pref;
    }
  }

  return trimmed;
}
