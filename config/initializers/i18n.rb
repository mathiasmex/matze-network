LOCALES_AVAILABLE = I18n.load_path.collect do |locale_file|
  File.basename(File.basename(locale_file, ".yml"), ".rb")
end.uniq.sort
