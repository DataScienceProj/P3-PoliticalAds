-- specific advertiser info
SELECT *, 
    CASE  --Case Statement for status of state in election... Battleground, R, or D
        WHEN country_subdivision_primary IN 
            ('AZ', 'FL', 'GA', 'ME', 'MI', 'MN', 'NH', 'NC', 'PA', 'TX', 'WI') THEN 'Battleground'
        WHEN country_subdivision_primary IN 
            ('AL', 'AR', 'ID', 'IN', 'IA', 'KS', 'KY', 'LA', 'MS', 'MO', 
            'MT', 'NE', 'ND', 'OH', 'OK', 'SC', 'SD', 'TN', 'UT', 'WV', 'WY') THEN 'Republican'
        ELSE 'Democrat' 
        END AS state_status, 
    CASE --Case Statement for who won state in election, Trump or Biden
        WHEN country_subdivision_primary IN ('FL', 'NC', 'TX', 
            'AL', 'AK', 'AR', 'ID', 'IN', 'IA', 'KS', 'KY', 'LA', 'MS', 'MO', 
            'MT', 'NE', 'ND', 'OH', 'OK', 'SC', 'SD', 'TN', 'UT', 'WV', 'WY') THEN 'Trump'
        ELSE 'Biden'
        END AS winning_candidate,
    CASE --Case Statement for which advertisers belong to which candidate
        WHEN advertiser_name IN 
            ('DONALD J. TRUMP FOR PRESIDENT, INC.', 'TRUMP MAKE AMERICA GREAT AGAIN COMMITTEE') THEN 'Trump'
        ELSE 'Biden'
        END AS advertiser_candidate
FROM ( -- Joined tables --
    SELECT geo.advertiser_id, geo.advertiser_name, geo.country, geo.country_subdivision_primary, 
           week.election_cycle, week.week_start_date, geo.spend_usd
    FROM `bigquery-public-data.google_political_ads.advertiser_geo_spend` geo
        LEFT JOIN `bigquery-public-data.google_political_ads.advertiser_weekly_spend` week
            ON geo.advertiser_id = week.advertiser_id
    WHERE geo.advertiser_name IN ('DONALD J. TRUMP FOR PRESIDENT, INC.', 'TRUMP MAKE AMERICA GREAT AGAIN COMMITTEE')
        OR geo.advertiser_name IN ('BIDEN FOR PRESIDENT', 'BIDEN VICTORY FUND', 'RP4BIDEN') -- To get 2020 Presidential Election advertiser 
            --data
    );