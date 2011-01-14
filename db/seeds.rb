# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Event.delete_all
Event.create([
  { :evtdate => '2011-07-30', :evtname => "Hollywood Hop On Hop Off Tour", :evtdeparttime => 'Airport Pick Up Times', :evtstarttime => "Various times throughout the day", :evtprice => '' } \
,  { :evtdate => '2011-07-31', :evtname => 'Sunset Strip and Rodeo Drive', :evtdeparttime => '8:30 AM', :evtstarttime => '10:30 AM', :evtprice => '' } \
,  { :evtdate => '2011-07-31', :evtname => 'Museum of Flight', :evtdeparttime => '9:30 AM', :evtstarttime => '10:00 AM', :evtprice => '' } \
,  { :evtdate => '2011-07-31', :evtname => 'Sunset Strip and Rodeo Drive', :evtdeparttime => '12:30 PM', :evtstarttime => '2:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-07-31', :evtname => 'Chase Palm Park Arts & Crafts Show', :evtdeparttime => '1:30 PM', :evtstarttime => '2:00 PM', :evtprice => '' } \
,  { :evtdate => '2011-07-31', :evtname => 'Cafe Buenos Aires', :evtdeparttime => '5:00 PM', :evtstarttime => '5:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-01', :evtname => 'Santa Monica Beach', :evtdeparttime => '8:30 AM', :evtstarttime => '10:30 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-01', :evtname => 'Golf', :evtdeparttime => '9:00 AM', :evtstarttime => '9:30 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-01', :evtname => 'Ty Warner Sea Center', :evtdeparttime => '9:30 AM', :evtstarttime => '10 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-01', :evtname => 'Santa Monica Beach', :evtdeparttime => '12:30 PM', :evtstarttime => '2:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-01', :evtname => 'Golf', :evtdeparttime => '1:30 PM', :evtstarttime => '2:00 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-01', :evtname => 'Ty Warner Sea Center', :evtdeparttime => '2:30 PM', :evtstarttime => '3:00 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-01', :evtname => "Dargan's Irish Pub and Restaurant", :evtdeparttime => '5:00 PM', :evtstarttime => '5:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-02', :evtname => 'La Brea Tar Pits and Hollywood', :evtdeparttime => '8:30 AM', :evtstarttime => '10:30 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-02', :evtname => 'Museum of Art', :evtdeparttime => '10:30 AM', :evtstarttime => '11:00 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-02', :evtname => 'La Brea Tar Pits and Hollywood', :evtdeparttime => '9:30 AM', :evtstarttime => '10:00 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-02', :evtname => 'Museum of Natural History', :evtdeparttime => '1:30 PM', :evtstarttime => '2:00 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-02', :evtname => 'Roller Skating', :evtdeparttime => '1:30 PM', :evtstarttime => 'On Site', :evtprice => '' } \
,  { :evtdate => '2011-08-02', :evtname => 'Museum of Art', :evtdeparttime => '2:30 PM', :evtstarttime => '3:00 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-02', :evtname => 'EOS Lounge', :evtdeparttime => '5:00 PM', :evtstarttime => '5:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-02', :evtname => 'Special Shuttles to LA', :evtdeparttime => '7:30 PM', :evtstarttime => '9:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-03', :evtname => 'Los Angeles Grand Tour', :evtdeparttime => '8:30 AM', :evtstarttime => '10:30 AM', :evtprice => '90' } \
,  { :evtdate => '2011-08-03', :evtname => 'Universal Studios Hollywood', :evtdeparttime => '8:30 AM', :evtstarttime => '10:30 AM', :evtprice => '90' } \
,  { :evtdate => '2011-08-03', :evtname => 'Santa Monica Beach and Venice Beach', :evtdeparttime => '8:30 AM', :evtstarttime => '10:30 AM', :evtprice => '35' } \
,  { :evtdate => '2011-08-03', :evtname => 'Santa Barbara Shopping and August Days Festival', :evtdeparttime => 'Various Times', :evtstarttime => 'Various Times', :evtprice => 'TBA' } \
,  { :evtdate => '2011-08-03', :evtname => "Deep-Sea Fishing (Captain Jack's Santa Barbara Tours)", :evtdeparttime => '5:30 AM', :evtstarttime => '6:00 AM', :evtprice => '50' } \
,  { :evtdate => '2011-08-03', :evtname => "2 Hour Kayak Tour (Captain Jack's Santa Barbara Tours)", :evtdeparttime => '9:30 AM', :evtstarttime => '10:00 AM', :evtprice => '25' } \
,  { :evtdate => '2011-08-03', :evtname => "Horseback Riding Tour (Captain Jack's Santa Barbara Tours)", :evtdeparttime => '9:30 AM', :evtstarttime => '10:00 AM', :evtprice => '35' } \
,  { :evtdate => '2011-08-03', :evtname => 'WinEdventures', :evtdeparttime => '10:30 AM', :evtstarttime => '11:00 AM', :evtprice => '70' } \
,  { :evtdate => '2011-08-03', :evtname => "Beer Tasting Tour (Captain Jack's Santa Barbara Tours)", :evtdeparttime => '10:30 AM', :evtstarttime => '11:00 AM', :evtprice => '50' } \
,  { :evtdate => '2011-08-03', :evtname => 'Tandem Skydiving', :evtdeparttime => 'Contact for details', :evtstarttime => 'Contact for details', :evtprice => 'TBA' } \
,  { :evtdate => '2011-08-03', :evtname => 'Waverunner rental', :evtdeparttime => 'Contact for details', :evtstarttime => 'Contact for details', :evtprice => 'TBA' } \
,  { :evtdate => '2011-08-03', :evtname => 'Whale Watching', :evtdeparttime => 'Contact for details', :evtstarttime => 'Contact for details', :evtprice => 'TBA' } \
,  { :evtdate => '2011-08-04', :evtname => 'Universal Studios Hollywood', :evtdeparttime => '8:30 AM', :evtstarttime => '10:30 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-04', :evtname => 'Shopping', :evtdeparttime => '10:00 AM', :evtstarttime => '10:30 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-04', :evtname => 'Universal Studios Hollywood', :evtdeparttime => '12:30 PM', :evtstarttime => '2:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-04', :evtname => 'Santa Barbara Zoo', :evtdeparttime => '1:30 PM', :evtstarttime => '2:00 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-04', :evtname => 'Spa', :evtdeparttime => '1:30 PM', :evtstarttime => 'Spa is booked for the afternoon!', :evtprice => '' } \
,  { :evtdate => '2011-08-04', :evtname => 'Shopping', :evtdeparttime => '3:30 PM', :evtstarttime => '4:00 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-04', :evtname => 'Downtown Brewing Company', :evtdeparttime => '5:00 PM', :evtstarttime => '5:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-05', :evtname => 'Venice Beach', :evtdeparttime => '8:30 AM', :evtstarttime => '10:30 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-05', :evtname => 'Santa Barbara Mission', :evtdeparttime => '10:30 AM', :evtstarttime => '11:00 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-05', :evtname => 'Venice Beach', :evtdeparttime => '12:30 PM', :evtstarttime => '2:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-05', :evtname => 'Ceramics', :evtdeparttime => '1:30 PM', :evtstarttime => 'On Site', :evtprice => '' } \
,  { :evtdate => '2011-08-05', :evtname => 'Santa Barbara Mission', :evtdeparttime => '3:00 PM', :evtstarttime => '3:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-05', :evtname => "Ruby's Cafe", :evtdeparttime => '5:00 PM', :evtstarttime => '5:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-06', :evtname => 'Hollywood Hop on Hop off Tour', :evtdeparttime => '8:30 AM', :evtstarttime => '10:30 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-06', :evtname => 'Waterfront', :evtdeparttime => '9:30 AM', :evtstarttime => '10:00 AM', :evtprice => '' } \
,  { :evtdate => '2011-08-06', :evtname => 'Hollywood Hop on Hop off Tour', :evtdeparttime => '12:30 PM', :evtstarttime => '2:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-06', :evtname => 'Chase Park and Carousel', :evtdeparttime => '1:30 PM', :evtstarttime => '2:00 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-06', :evtname => 'Waterfront', :evtdeparttime => '3:00 PM', :evtstarttime => '3:30 PM', :evtprice => '' } \
,  { :evtdate => '2011-08-06', :evtname => 'Wildcat Lounge', :evtdeparttime => '10:00 PM', :evtstarttime => '10:30 PM', :evtprice => '' } \
])

Job.delete_all
Job.create([
  { :jobname => 'Office Manager/TD Coordinator' } \
, { :jobname => 'Deputy Office Manager' } \
, { :jobname => 'Registrar' } \
, { :jobname => 'Deputy Registrar' } \
, { :jobname => 'Registration Volunteers' } \
, { :jobname => 'Treasurer' } \
, { :jobname => 'Equipment Manager' } \
, { :jobname => 'Equipment Volunteers' } \
, { :jobname => 'Deputy Youth Coordinator' } \
, { :jobname => 'Handbook Preparer' } \
, { :jobname => 'Professional Coordinator' } \
, { :jobname => 'Written Translators (Korean, Japanese, and Chinese)' } \
, { :jobname => 'Verbal Translators (Korean, Japanese, and Chinese)' } \
, { :jobname => 'Tournament Directors: US Open' } \
, { :jobname => 'Tournament Directors: North American Masters Championship' } \
, { :jobname => 'Tournament Directors: North American Masters Open' } \
, { :jobname => 'Tournament Director: Self-Paired Tournament' } \
, { :jobname => 'Tournament Director: Pair Go Tournament' } \
, { :jobname => 'Assistant Tournament Director: Pair Go Tournament' } \
, { :jobname => 'Tournament Director: Lightning Tournament' } \
, { :jobname => 'Tournament Director: 9 x 9 Tournament' } \
, { :jobname => 'Tournament Director: 13 x 13 Tournament' } \
, { :jobname => 'Tournament Director: Club Team Tournament' } \
, { :jobname => 'Tournament Director: Crazy Go' } \
])
