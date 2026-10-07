/// Pure helper function to resolve active language code with fallbacks.
///
/// Priority:
/// 1. Saved preference (if valid: 'en' or 'vi')
/// 2. Platform locale languageCode (returns 'vi' if platform starts with 'vi')
/// 3. Default fallback: 'en'
String resolveLanguageCode({String? saved, String? platformLanguageCode}) {
  if (saved != null && (saved == 'en' || saved == 'vi')) {
    return saved;
  }
  if (platformLanguageCode != null &&
      platformLanguageCode.toLowerCase().startsWith('vi')) {
    return 'vi';
  }
  return 'en';
}
