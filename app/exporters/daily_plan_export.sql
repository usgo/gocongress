select
  a.user_id as user_id,
  a.id as attendee_id,
  a.family_name,
  a.given_name,
  a.alternate_name,
  p.name as plan_name,
  min(apd._date) as first_date,
  max(apd._date) as last_date
from attendees a
cross join plans p
inner join attendee_plans ap
  on ap.attendee_id = a.id
    and ap.plan_id = p.id
inner join attendee_plan_dates apd
  on apd.attendee_plan_id = ap.id
where a.year = $1
  and p.daily = true
group by a.id, p.id
order by a.family_name, a.given_name, a.id, plan_name, p.id
