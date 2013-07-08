select
  a.given_name || ' ' || a.family_name as attendee_name,
  p.name as plan_name,
  min(apd._date) as first_date
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
order by attendee_name, a.id, plan_name, p.id
