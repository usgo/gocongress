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

-- count of plans
left join (
  select ap.attendee_id, count(ap.id) as n
  from attendee_plans ap
  where ap.year = :year
  group by ap.attendee_id
) plan_count on plan_count.attendee_id = attendees.id

where attendees.year = :year and attendees.cancelled = false

  -- must have at least one plan
  and plan_count.n > 0

  -- credits minus debits must be at least $70
  and coalesce(credits.total, 0) - coalesce(debits.total, 0) >= 7000

  -- exclude attendees under eighteen
  and attendees.birth_date < (:congress_start_date::date - interval '18 years')

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
