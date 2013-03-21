select a.*
from attendees a

-- get count of attendees on the same user
inner join (
  select user_id, count(*) as cnt
  from attendees
  where year = :year
  group by user_id
) attendee_counts on attendee_counts.user_id = a.user_id

-- get sum of credits (sales and comps)
left join (
  select t.user_id, sum(t.amount) as total
  from transactions t
  where t.trantype in ('C', 'S') and t.year = :year
  group by t.user_id
) credits on credits.user_id = a.user_id

-- get sum of debits (refunds)
left join (
  select t.user_id, sum(t.amount) as total
  from transactions t
  where t.trantype = 'R' and t.year = :year
  group by t.user_id
) debits on debits.user_id = a.user_id

where a.year = :year

  -- must have at least one plan
  and a.id in (select distinct attendee_id from attendee_plans where year = :year)

  -- user must pay required deposit for each attendee
  and coalesce(credits.total, 0) - coalesce(debits.total, 0)
    >= attendee_counts.cnt * :deposit
