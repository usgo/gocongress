select attendees.*
from attendees

-- get sum of credits (sales and comps)
left join (
  select t.user_id, sum(t.amount) as total
  from transactions t
  where t.trantype in ('C', 'A', 'P', 'S') and t.year = :year
  group by t.user_id
) credits on credits.user_id = attendees.user_id

-- get sum of debits (refunds)
left join (
  select t.user_id, sum(t.amount) as total
  from transactions t
  where t.trantype = 'R' and t.year = :year
  group by t.user_id
) debits on debits.user_id = attendees.user_id

-- sum of mandatory nondaily plan costs of attendee's user account
left join (
  select a.user_id, sum(p.price) as total
  from attendees a
  inner join attendee_plans ap on ap.attendee_id = a.id
  inner join plans p on p.id = ap.plan_id
  inner join plan_categories pc on pc.id = p.plan_category_id
  where a.year = :year
    and ap.year = :year
    and p.year = :year
    and p.daily = false
    and pc.year = :year
    and pc.mandatory
  group by a.user_id
) nondaily_plans on nondaily_plans.user_id = attendees.user_id

-- sum of mandatory daily plan costs of attendee's user account
left join (
  select a.user_id, sum(p.price) as total
  from attendees a
  inner join attendee_plans ap on ap.attendee_id = a.id
  inner join attendee_plan_dates apd on apd.attendee_plan_id = ap.id
  inner join plans p on p.id = ap.plan_id
  inner join plan_categories pc on pc.id = p.plan_category_id
  where a.year = :year
    and ap.year = :year
    and p.year = :year
    and pc.year = :year
    and pc.mandatory
  group by a.user_id
) daily_plans on daily_plans.user_id = attendees.user_id

-- count of plans
left join (
  select ap.attendee_id, count(ap.id) as n
  from attendee_plans ap
  where ap.year = :year
  group by ap.attendee_id
) plan_count on plan_count.attendee_id = attendees.id

where attendees.year = :year

  -- must have at least one plan
  and plan_count.n > 0

  -- credits minus debits must satisfy total of mandatory plan costs of attendee's user account
  and coalesce(credits.total, 0) - coalesce(debits.total, 0)
    >= coalesce(nondaily_plans.total, 0) + coalesce(daily_plans.total, 0)

  -- exclude cancelled attendees
  and not exists (
    select ap.attendee_id
    from attendee_plans ap
    inner join plans p on p.id = ap.plan_id
    where attendees.id = ap.attendee_id
      and ap.year = :year
      and p.year = :year
      and p.description like 'Cancellation'
  )
