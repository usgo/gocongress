select attendees.*
from attendees

-- get sum of credits (sales and comps)
left join (
  select t.user_id, sum(t.amount) as total
  from transactions t
  where t.trantype in ('C', 'S') and t.year = :year
  group by t.user_id
) credits on credits.user_id = attendees.user_id

-- get sum of debits (refunds)
left join (
  select t.user_id, sum(t.amount) as total
  from transactions t
  where t.trantype = 'R' and t.year = :year
  group by t.user_id
) debits on debits.user_id = attendees.user_id

-- sum of plan costs
left join (
  select ap.attendee_id, sum(p.price) as total
  from attendee_plans ap
  inner join plans p on p.id = ap.plan_id
  where ap.year = :year
    and p.year = :year
  group by ap.attendee_id
) plans on plans.attendee_id = attendees.id

-- sum of activity costs
left join (
  select aa.attendee_id, sum(a.price) as total
  from attendee_activities aa
  inner join activities a on a.id = aa.activity_id
  where aa.year = :year
    and a.year = :year
  group by aa.attendee_id
) activities on activities.attendee_id = attendees.id

where attendees.year = :year

  -- must have at least one plan
  and plans.total > 0

  -- credits minus debits must satisfy total of invoice
  and coalesce(credits.total, 0) - coalesce(debits.total, 0)
    >= coalesce(plans.total, 0) + coalesce(activities.total, 0)
