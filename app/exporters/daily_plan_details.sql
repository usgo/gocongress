select
  a.user_id as user_id,
  a.id as attendee_id,
  a.family_name,
  a.given_name,
  a.alternate_name,
  p.name as plan_name,
  ap.id as attendee_plan_id,
  d._date as apdate
from attendees a
inner join attendee_plans ap
  on ap.attendee_id = a.id
inner join attendee_plan_dates d
  on d.attendee_plan_id = ap.id
inner join plans p
  on p.id = ap.plan_id
where a.year = $1
  and a.cancelled = false
  and p.year = $1
  and ap.year = $1
  and p.daily = true
order by p.id, a.id, d._date
