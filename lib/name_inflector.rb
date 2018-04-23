module NameInflector

  # Prefixes with mandatory succeeding capitals, eg.
  # the O' in O'Brian is always capitalized.
  MANDPREF = ["o'"]

  # Suffixes with mandatory capitalization
  MANDSUF = ["jr.", "sr.", "esq."]

  # Prefixes with optional succeeding capitals, eg.
  # Macintyre and MacIntyre are both valid
  OPTPREF = ["mac", "mc"]

  def self.capitalize(name)
    if name.include? "-"
      name.split("-").map{ |n| capitalize_name(n) }.join("-")
    else
      capitalize_name(name)
    end
  end

  private

  def self.capitalize_name(name)
    mandpref_match = longest_matching_prefix MANDPREF, name
    mandsuf_match = longest_matching_suffix MANDSUF, name
    optpref_match = longest_matching_prefix OPTPREF, name

    if mandpref_match.present?
      postprefix = remove_prefix name, mandpref_match
      name_fix = mandpref_match.capitalize + postprefix.capitalize

    elsif optpref_match.present?
      postprefix = remove_prefix name, optpref_match
      is_first_char_uppercase?(postprefix) ? name_fix = name : name_fix = name.capitalize

    else
      name_fix = name.capitalize
    end
    capitalize_suffix(name_fix, mandsuf_match) if mandsuf_match.present?
    return name_fix
  end

  def self.capitalize_suffix(name, suffix)
    name.sub!("#{suffix}", "#{suffix.capitalize}")
  end

  def self.is_first_char_uppercase?(string)
    ("A".."Z").cover? string.slice(0)
  end

  def self.longest_matching_prefix(prefixes, string)
    matches = prefixes.select{|p| string.downcase.start_with?(p)}
    return nil if matches.empty?
    longest = ""
    matches.each {|m| longest = m if m.length > longest.length }
    return longest
  end

  def self.longest_matching_suffix(suffixes, string)
    matches = suffixes.select{|s| string.downcase.end_with?(s)}
    return nil if matches.empty?
    longest = ""
    matches.each {|m| longest = m if m.length > longest.length }
    return longest
  end

  def self.remove_prefix(string, prefix)
    string.slice(prefix.length, string.length - prefix.length)
  end
end