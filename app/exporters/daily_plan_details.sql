select
  a.user_id * $3 as user_id,
  a.id * $3 as attendee_id,
  a.family_name,
  a.given_name,
  d._date as apdate
from attendees a
inner join attendee_plans ap
  on ap.attendee_id = a.id
inner join attendee_plan_dates d
  on d.attendee_plan_id = ap.id
inner join plans p
  on p.id = ap.plan_id
where a.year = $1
  and p.year = $1
  and ap.year = $1
  and p.id = $2
  and p.daily = true
order by a.id, d._date

