class Insert2014Record < ActiveRecord::Migration
  def up
    # Inserts a new year record for the 2014 event.  This
    # code is very similar to the code in db/seeds.rb.  The
    # code must bypass mass assignment security or there
    # will be a "Can't mass-assign protected attributes"
    # error.
    Year.create(
      {
        city:                  'TBD',
        date_range:            'TBD',
        day_off_date:          Date.new(2014, 8, 2),
        ordinal_number:        30,
        registration_phase:    'closed',
        reply_to_email:        'rcristal3@netscape.net',
        start_date:            Date.new(2014, 8, 1),
        state:                 'TBD',
        timezone:              'Eastern Time (US & Canada)',
        year:                  2014
      },
      :without_protection => true
    )
  end

  def down
    # Deletes the 2014 record, which should be the last
    # record in the years table after migrating.
    Year.last.destroy
  end
end
