class BadgeCsvExporter
  # Order of columns must match `header_array`
  def self.attendee_array(atnd)
    # Get AGA Info from TD List
    aga_info = AGATDList.data(atnd.aga_id)

    [
      atnd.alternate_name,
      atnd.given_name,
      atnd.family_name,

      # Change "non-player" to blank for the purpose of badges
      atnd.rank_name === "Non-player" ? "" : atnd.rank_name,

      atnd.user_email,
      atnd.aga_id,
      aga_info[:club],
      state_name(aga_info[:state]),
      country_name(atnd.country),
      atnd.birth_date,
      banquet(atnd),
      plan_quantities(atnd),
    ].flatten.map { |v| blank_to_nil(v) }
  end

  # Order must match `attendee_array`
  def self.header_array(year)
    ['alternate_name', 'given_name', 'family_name', 'rank', 'email', 'aga_id', 'club', 'state', 'country', 'birth_date', 'banquet'] + plan_names(year)
  end

  def self.csv_enumerator(year, attendees)
    @csv_enumerator ||= Enumerator.new do |yielder|
      yielder << header_array(year).to_csv
      attendees.find_each do |atnd|
        yielder << CSV.generate_line(attendee_array(atnd))
      end
    end
  end

  private

  def self.blank_to_nil(obj)
    obj.blank? ? nil : obj
  end

  def self.banquet(atnd)
    pqh = atnd.plan_qty_hash

    banquet = false
    Plan.yr(atnd.year).find_each { |p|
      if (p.name.include? 'Banquet' and !p.name.include? 'No Banquet')
        if (pqh[p.id] === 1)
          banquet = true
        end
      end
    }

    # "T" is the character we want to use for the particular bullet that will
    # indicate a banquet purchase

    # In Adobe InDesign, you can't perform logic on field values, so we have to
    # have the exact character in the CSV that we want displayed on the badge
    banquet ? 'T' : ''
  end

  def self.plan_quantities(atnd)
    pqh = atnd.plan_qty_hash
    plans(atnd.year).map { |p|
      # Turn the plan that indicates first-time attendees into the desired text
      if (p.name === 'Yes 1st')
        pqh[p.id] === 1 ? "First Congress" : ""
      else
        pqh[p.id].to_i
      end
    }
  end

  def self.plans(year)
    Plan.yr(year).alphabetical.select do |plan|
      # List any plan names that should be included in the badge export
      ['Yes 1st'].any? { |s|
        plan.name.include? s
      }
    end
  end

  def self.plan_names(year)
    plans(year).map { |p|
      # Turn plan names like "Yes 1st" to "plan_yes-1st"
      "plan_" + safe_for_csv(p.name).parameterize
    }
  end

  def self.safe_for_csv(str)
    str.tr(',"', '')
  end

  # Turn state abbreviations into names
  def self.state_name(abbreviation)
    states = {
      AK: "Alaska",
      AL: "Alabama",
      AR: "Arkansas",
      AS: "American Samoa",
      AZ: "Arizona",
      CA: "California",
      CO: "Colorado",
      CT: "Connecticut",
      DC: "District of Columbia",
      DE: "Delaware",
      FL: "Florida",
      GA: "Georgia",
      GU: "Guam",
      HI: "Hawaii",
      IA: "Iowa",
      ID: "Idaho",
      IL: "Illinois",
      IN: "Indiana",
      KS: "Kansas",
      KY: "Kentucky",
      LA: "Louisiana",
      MA: "Massachusetts",
      MD: "Maryland",
      ME: "Maine",
      MI: "Michigan",
      MN: "Minnesota",
      MO: "Missouri",
      MS: "Mississippi",
      MT: "Montana",
      NC: "North Carolina",
      ND: "North Dakota",
      NE: "Nebraska",
      NH: "New Hampshire",
      NJ: "New Jersey",
      NM: "New Mexico",
      NV: "Nevada",
      NY: "New York",
      OH: "Ohio",
      OK: "Oklahoma",
      OR: "Oregon",
      PA: "Pennsylvania",
      PR: "Puerto Rico",
      RI: "Rhode Island",
      SC: "South Carolina",
      SD: "South Dakota",
      TN: "Tennessee",
      TX: "Texas",
      UT: "Utah",
      VA: "Virginia",
      VI: "Virgin Islands",
      VT: "Vermont",
      WA: "Washington",
      WI: "Wisconsin",
      WV: "West Virginia",
      WY: "Wyoming"
    }

    abbreviation ? states[abbreviation.to_sym] : ''
  end

  # Generate a friendly country name for badges
  def self.country_name(alpha_2)
    code = IsoCountryCodes.find(alpha_2)

    # Use USA for Americans (United States of America is SO verbose) who also
    # have state information from the AGA TD List, but use full names for
    # everyone else
    alpha_2 == 'US' ? code.alpha3 : code.name
  end
end
