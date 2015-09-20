select
  u.id as user_id,
  u.email as user_email,
  a.id as attendee_id,
  a.given_name,
  a.family_name,
  a.alternate_name,
  p.name as plan_name,

  /* Plan prices are stored in integer cents.  Convert to dollars. */
  (p.price::decimal(10,2) / 100)::decimal(10,2) as price,

  /* For the purposes of this report, the quantity of a daily-rate plan is
  the number of selected dates.  For regular, non-daily plans, the quantity
  is `attendee_plans.quantity`. */
  case when p.daily
    then coalesce(date_counts.ct, 0)
    else ap.quantity
  end as quantity

from users u
inner join attendees a on a.user_id = u.id
inner join attendee_plans ap on ap.attendee_id = a.id
inner join plans p on p.id = ap.plan_id
left join (
  select ap.attendee_id, ap.plan_id, count(*) as ct
  from attendee_plan_dates d
  inner join attendee_plans ap on ap.id = d.attendee_plan_id
  where ap.year = $1
  group by ap.attendee_id, ap.plan_id
) date_counts
  on date_counts.attendee_id = a.id
    and date_counts.plan_id = ap.plan_id
where u.year = $1
  and a.year = $1
  and ap.year = $1
  and p.year = $1
order by user_email, u.id, family_name, given_name, a.id, plan_name, p.id;
