module NameInflector

  # Prefixes with mandatory succeeding capitals, eg.
  # the O' in O'Brian is always capitalized.
  MANDPREF = ["o'"]

  # Prefixes with optional succeeding capitals, eg.
  # Macintyre and MacIntyre are both valid
  OPTPREF = ["mac", "mc"]

  def self.capitalize(name)
    mandpref_match = longest_matching_prefix MANDPREF, name
    optpref_match = longest_matching_prefix OPTPREF, name

    if mandpref_match.present?
      postprefix = remove_prefix name, mandpref_match
      mandpref_match.capitalize + postprefix.capitalize

    elsif optpref_match.present?
      postprefix = remove_prefix name, optpref_match
      is_first_char_uppercase?(postprefix) ? name : name.capitalize

    elsif name.include? '-'
      name.split('-').map{|n| n.capitalize}.join('-')

    else
      name.capitalize
    end
  end

  private

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

  def self.remove_prefix(string, prefix)
    string.slice(prefix.length, string.length - prefix.length)
  end
end
