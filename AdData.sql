--individual ads data
SELECT 
    ad_id, ad_url, ad_type,
    CASE 
        WHEN ad_type LIKE 'Video' OR ad_type LIKE 'Audio' THEN 1
        ELSE 0 END AS has_audio,
    advertiser_id, advertiser_name, advertiser_candidate, 
    date_range_start, date_range_end, num_of_days, 
    impressions, low_bound_impressions, up_bound_impressions, 
    spend_usd, low_bound_spend, up_bound_spend, 
    age_targeting, low_age_target, high_age_target, age_not_targeted, age_unknown, 
    age_under_18, age_18_24, age_25_34, age_35_44, age_45_54, age_55_64, age_over_65,
    gender_targeting, gender_targeting_clean, gender_male, gender_female, gender_unknown,
    in_battleground_state, in_democrat_state, in_republican_state, 
    state_alabama, state_alaska, state_arizona, state_arkansas, state_california,
    state_colorado, state_connecticut, state_delaware, state_florida, state_georgia, state_hawaii, 
    state_idaho, state_illinois, state_indiana, state_iowa, state_kansas, state_kentucky, state_louisiana, 
    state_maine, state_maryland, state_massachusetts, state_michigan, state_minnesota, state_mississippi, 
    state_missouri, state_montana, state_nebraska, state_nevada, state_newHampshire, state_newJersey, 
    state_newMexico, state_newYork, state_northCarolina, state_northDakota, state_ohio, state_oklahoma, 
    state_oregon, state_pennsylvania, state_rhodeIsland, state_southCarolina, state_southDakota, 
    state_tennessee, state_texas, state_utah, state_vermont, state_virginia, state_washington, 
    state_westVirginia, state_wisconsin, state_wyoming, state_every, 
    CASE --Trim ending comma off of geo_targeting_clean list
        WHEN geo_targeting_clean LIKE '' THEN ''
        WHEN geo_targeting_clean LIKE 'USA' THEN 'USA'
        ELSE SUBSTRING(geo_targeting_clean, 1, CHAR_LENGTH(geo_targeting_clean) -2) 
        END AS geo_targeting_clean, 
    geo_targeting
FROM ( --QUERY 2:
            --Group state columns into geo_targeting_clean
    SELECT 
        ad_id, ad_url, ad_type,
        advertiser_id, advertiser_name, advertiser_candidate, 
        date_range_start, date_range_end, num_of_days, 
        impressions, low_bound_impressions, up_bound_impressions, 
        spend_usd, low_bound_spend, up_bound_spend, 
        age_targeting, low_age_target, high_age_target, age_not_targeted, age_unknown, 
        age_under_18, age_18_24, age_25_34, age_35_44, age_45_54, age_55_64, age_over_65,
        gender_targeting, gender_targeting_clean, gender_male, gender_female, gender_unknown,
        in_battleground_state, in_democrat_state, in_republican_state, 
        state_alabama, state_alaska, state_arizona, state_arkansas, state_california,
        state_colorado, state_connecticut, state_delaware, state_florida, state_georgia, state_hawaii, 
        state_idaho, state_illinois, state_indiana, state_iowa, state_kansas, state_kentucky, state_louisiana, 
        state_maine, state_maryland, state_massachusetts, state_michigan, state_minnesota, state_mississippi, 
        state_missouri, state_montana, state_nebraska, state_nevada, state_newHampshire, state_newJersey, 
        state_newMexico, state_newYork, state_northCarolina, state_northDakota, state_ohio, state_oklahoma, 
        state_oregon, state_pennsylvania, state_rhodeIsland, state_southCarolina, state_southDakota, 
        state_tennessee, state_texas, state_utah, state_vermont, state_virginia, state_washington, 
        state_westVirginia, state_wisconsin, state_wyoming, state_every, 
        CASE 
            WHEN state_every = 1 THEN 'USA'
            ELSE --Create list of all states ad appears in
                CONCAT(IFNULL(alabama, ""), IFNULL(alaska, ""), IFNULL(arizona, ""), 
                IFNULL(arkansas, ""), IFNULL(california, ""), IFNULL(colorado, ""),  
                IFNULL(connecticut, ""), IFNULL(delaware, ""), "", IFNULL(florida, ""), "", 
                IFNULL(georgia, ""), "", IFNULL(hawaii, ""), "", IFNULL(idaho, ""), "", IFNULL(illinois, ""), "", 
                IFNULL(indiana, ""), "", IFNULL(iowa, ""), "", IFNULL(kansas, ""), "", IFNULL(kentucky, ""), "", 
                IFNULL(louisiana, ""), "", IFNULL(maine, ""), "", IFNULL(maryland, ""), "", 
                IFNULL(massachusetts, ""), "", IFNULL(michigan, ""), "", IFNULL(minnesota, ""), "", 
                IFNULL(mississippi, ""), "", IFNULL(missouri, ""), "", IFNULL(montana, ""), "", 
                IFNULL(nebraska, ""), "", IFNULL(nevada, ""), "", IFNULL(newHampshire, ""), "", 
                IFNULL(newJersey, ""), "", IFNULL(newMexico, ""), "", IFNULL(newYork, ""), "", 
                IFNULL(northCarolina, ""), "", IFNULL(northDakota, ""), "", IFNULL(ohio, ""), "", 
                IFNULL(oklahoma, ""), "", IFNULL(oregon, ""), "", IFNULL(pennsylvania, ""), "", 
                IFNULL(rhodeIsland, ""), "", IFNULL(southCarolina, ""), "", IFNULL(southDakota, ""), "", 
                IFNULL(tennessee, ""), "", IFNULL(texas, ""), "", IFNULL(utah, ""), "", 
                IFNULL(vermont, ""), "", IFNULL(virginia, ""), "", IFNULL(washington, ""), "", 
                IFNULL(westVirginia, ""), "", IFNULL(wisconsin, ""), "", IFNULL(wyoming, ""), "")
        END AS geo_targeting_clean,
        geo_targeting
    FROM (
        --QUERY 1:
        SELECT cstats.ad_id, --ad id,
            cstats.ad_url, --ad url
            cstats.ad_type, --video, image, text, etc
            cstats.advertiser_id, --id of advertiser
            cstats.advertiser_name,  --name of advertiser
            CASE --Candidate of advertiser
                WHEN advertiser_name IN ('DONALD J. TRUMP FOR PRESIDENT, INC.', 'TRUMP MAKE AMERICA GREAT AGAIN COMMITTEE') THEN 'Trump'
                ELSE 'Biden'
                END AS advertiser_candidate,
            cstats.date_range_start, --start date of ad
            cstats.date_range_end, --end run date of ad
            cstats.num_of_days, --num of days ad ran
            cstats.impressions, --num range of impressions
            CASE --extraced lower bound on impressions
                WHEN cstats.impressions LIKE '≤ 10k' THEN 0
                WHEN cstats.impressions LIKE '10k-100k' THEN 10000
                WHEN cstats.impressions LIKE '100k-1M' THEN 100000
                WHEN cstats.impressions LIKE '1M-10M' THEN 1000000
                WHEN cstats.impressions LIKE '> 10M' THEN 10000000
                END AS low_bound_impressions,
            CASE --extracted upper bound on impressions
                WHEN cstats.impressions LIKE '≤ 10k' THEN 10000
                WHEN cstats.impressions LIKE '10k-100k' THEN 100000
                WHEN cstats.impressions LIKE '100k-1M' THEN 1000000
                WHEN cstats.impressions LIKE '1M-10M' THEN 10000000
                WHEN cstats.impressions LIKE '> 10M' THEN 1000000000 --1 billion is practical upper bound, due to pop. of USA
                END AS up_bound_impressions, 
            cstats.spend_usd, --spend range of dollars
            CASE --lower bound for spend
                WHEN cstats.spend_usd LIKE '≤ 100' THEN 1 --Doesn't make sense to spend $0
                WHEN cstats.spend_usd LIKE '100-1k' THEN 100
                WHEN cstats.spend_usd LIKE '1k-50k' THEN 1000
                WHEN cstats.spend_usd LIKE '50k-100k' THEN 50000
                WHEN cstats.spend_usd LIKE '> 100k' THEN 100000
                END AS low_bound_spend,
            CASE --upper bound for spend
                WHEN cstats.spend_usd LIKE '≤ 100' THEN 100
                WHEN cstats.spend_usd LIKE '100-1k' THEN 1000
                WHEN cstats.spend_usd LIKE '1k-50k' THEN 50000
                WHEN cstats.spend_usd LIKE '50k-100k' THEN 100000
                WHEN cstats.spend_usd LIKE '> 100k' THEN 10000000 -- 10 million is practical upper bound?
                END AS up_bound_spend,
            cstats.age_targeting, --age ranges targeted
            CASE --lower bound for targeted age
                WHEN cstats.age_targeting LIKE '%≤18%' THEN '0'
                WHEN SUBSTRING(cstats.age_targeting, 0, 2) LIKE 'No' THEN NULL
                ELSE SUBSTRING(cstats.age_targeting, 0, 2)
                END AS low_age_target,
            CASE --upper bound for targeted age
                WHEN cstats.age_targeting LIKE '%≥65%' THEN '99'
                WHEN cstats.age_targeting LIKE '%Unknown age%' THEN SUBSTRING(cstats.age_targeting, -15, 2)
                WHEN SUBSTRING(cstats.age_targeting, -2, 2) LIKE 'ed' THEN NULL
                ELSE SUBSTRING(cstats.age_targeting, -2, 2)
                END AS high_age_target,
            CASE WHEN cstats.age_targeting LIKE '%≤18' THEN 1 ELSE 0 END AS age_under_18,
            CASE WHEN cstats.age_targeting LIKE '%18-24%' THEN 1 ELSE 0 END AS age_18_24,
            CASE WHEN cstats.age_targeting LIKE '%25-34%' THEN 1 ELSE 0 END AS age_25_34, 
            CASE WHEN cstats.age_targeting LIKE '%35-44%' THEN 1 ELSE 0 END AS age_35_44,
            CASE WHEN cstats.age_targeting LIKE '%45-54%' THEN 1 ELSE 0 END AS age_45_54,
            CASE WHEN cstats.age_targeting LIKE '%55-64%' THEN 1 ELSE 0 END AS age_55_64,
            CASE WHEN cstats.age_targeting LIKE '%≥65%' THEN 1 ELSE 0 END AS age_over_65,
            CASE WHEN cstats.age_targeting LIKE '%Unknown age%' THEN 1 ELSE 0 END AS age_unknown,
            CASE WHEN cstats.age_targeting LIKE '%Not targeted%' THEN 1 ELSE 0 END AS age_not_targeted,
            cstats.gender_targeting, --genders targeted
            CASE --gender targeting cleaned
                WHEN (LENGTH(cstats.gender_targeting) - LENGTH(REPLACE(cstats.gender_targeting, ',', ''))) = 2 THEN 'All'
                WHEN (LENGTH(cstats.gender_targeting) - LENGTH(REPLACE(cstats.gender_targeting, ',', ''))) = 1 
                    AND cstats.gender_targeting LIKE '%Male, Female%' THEN 'All'
            --Female was excluded here. They want males, and unknowns might be males:
                WHEN (LENGTH(cstats.gender_targeting) - LENGTH(REPLACE(cstats.gender_targeting, ',', ''))) = 1 
                    AND cstats.gender_targeting LIKE '%Male, Unknown gender%' THEN 'Male' 
            --Male was excluded here. They want females, and unknowns might be females:
                WHEN (LENGTH(cstats.gender_targeting) - LENGTH(REPLACE(cstats.gender_targeting, ',', ''))) = 1 
                    AND cstats.gender_targeting LIKE '%Female, Unknown gender%' THEN 'Female'
                WHEN cstats.gender_targeting LIKE '%Unknown gender%' THEN 'Unknown Gender'
                WHEN (LENGTH(cstats.gender_targeting) - LENGTH(REPLACE(cstats.gender_targeting, ',', ''))) >= 0 THEN gender_targeting
            END AS gender_targeting_clean, 
            CASE --is male targeted? (for machine learning)
                WHEN cstats.gender_targeting LIKE '%Male%' THEN 1
                WHEN cstats.gender_targeting LIKE '%Not targeted%' THEN NULL
                ELSE 0 END AS gender_male,
            CASE --is female targeted? (for machine learning)
                WHEN cstats.gender_targeting LIKE '%Female%' THEN 1 
                WHEN cstats.gender_targeting LIKE '%Not targeted%' THEN NULL
                ELSE 0 END AS gender_female,
            CASE --is unknown targeted? (for machine learning)
                WHEN cstats.gender_targeting LIKE '%Unknown%' THEN 1 
                WHEN cstats.gender_targeting LIKE '%Not targeted%' THEN NULL
                ELSE 0 END AS gender_unknown,   
            CASE --Does this ad appear in a Democrat state?
                WHEN 
                    cstats.geo_targeting_included LIKE '%CA%' OR cstats.geo_targeting_included LIKE '%California%'
                    OR cstats.geo_targeting_included LIKE '%CO%' OR cstats.geo_targeting_included LIKE '%Colorado%' 
                    OR cstats.geo_targeting_included LIKE '%CT%' OR cstats.geo_targeting_included LIKE '%Connecticut%'
                    OR cstats.geo_targeting_included LIKE '%DE%' OR cstats.geo_targeting_included LIKE '%Delaware%' 
                    OR cstats.geo_targeting_included LIKE '%HI%' OR cstats.geo_targeting_included LIKE '%Hawaii%'
                    OR cstats.geo_targeting_included LIKE '%IL%' OR cstats.geo_targeting_included LIKE '%Illinois%' 
                    OR cstats.geo_targeting_included LIKE '%ME%' OR cstats.geo_targeting_included LIKE '%Maine%'
                    OR cstats.geo_targeting_included LIKE '%MD%' OR cstats.geo_targeting_included LIKE '%Maryland%'
                    OR cstats.geo_targeting_included LIKE '%NV%' OR cstats.geo_targeting_included LIKE '%Nevada%'
                    OR cstats.geo_targeting_included LIKE '%NJ%' OR cstats.geo_targeting_included LIKE '%New Jersey%'  
                    OR cstats.geo_targeting_included LIKE '%NM%' OR cstats.geo_targeting_included LIKE '%New Mexico%'
                    OR cstats.geo_targeting_included LIKE '%NY%' OR cstats.geo_targeting_included LIKE '%New York%'
                    OR cstats.geo_targeting_included LIKE '%OR%' OR cstats.geo_targeting_included LIKE '%Oregon%'
                    OR cstats.geo_targeting_included LIKE '%RI%' OR cstats.geo_targeting_included LIKE '%Rhode Island%'
                    OR cstats.geo_targeting_included LIKE '%VT%' OR cstats.geo_targeting_included LIKE '%Vermont%'
                    OR cstats.geo_targeting_included LIKE '%VA%' OR cstats.geo_targeting_included LIKE '%Virginia%'
                    OR cstats.geo_targeting_included LIKE '%WA%' OR cstats.geo_targeting_included LIKE '%Washington%'
                    OR cstats.geo_targeting_included LIKE 'United States'
                    THEN 1 ELSE 0 END AS in_democrat_state,
            CASE --Does this ad appear in a Republican state?
                WHEN 
                    cstats.geo_targeting_included LIKE '%AL%' OR cstats.geo_targeting_included LIKE '%Alabama%'
                    OR cstats.geo_targeting_included LIKE '%AK%' OR cstats.geo_targeting_included LIKE '%Alaska%'
                    OR cstats.geo_targeting_included LIKE '%AR%' OR cstats.geo_targeting_included LIKE '%Arkansas%'
                    OR cstats.geo_targeting_included LIKE '%ID%' OR cstats.geo_targeting_included LIKE '%Idaho%'
                    OR cstats.geo_targeting_included LIKE '%IN%' OR cstats.geo_targeting_included LIKE '%Indiana%'
                    OR cstats.geo_targeting_included LIKE '%IA%' OR cstats.geo_targeting_included LIKE '%Iowa%'
                    OR cstats.geo_targeting_included LIKE '%KS%' OR cstats.geo_targeting_included LIKE '%Kansas%'
                    OR cstats.geo_targeting_included LIKE '%KY%' OR cstats.geo_targeting_included LIKE '%Kentucky%' 
                    OR cstats.geo_targeting_included LIKE '%LA%' OR cstats.geo_targeting_included LIKE '%Louisiana%'
                    OR cstats.geo_targeting_included LIKE '%MS%' OR cstats.geo_targeting_included LIKE '%Mississippi%'
                    OR cstats.geo_targeting_included LIKE '%MO%' OR cstats.geo_targeting_included LIKE '%Missouri%'
                    OR cstats.geo_targeting_included LIKE '%MT%' OR cstats.geo_targeting_included LIKE '%Montana%'
                    OR cstats.geo_targeting_included LIKE '%NE%' OR cstats.geo_targeting_included LIKE '%Nebraska%'
                    OR cstats.geo_targeting_included LIKE '%ND%' OR cstats.geo_targeting_included LIKE '%North Dakota%'
                    OR cstats.geo_targeting_included LIKE '%OH%' OR cstats.geo_targeting_included LIKE '%Ohio%'
                    OR cstats.geo_targeting_included LIKE '%OK%' OR cstats.geo_targeting_included LIKE '%Oklahoma%'
                    OR cstats.geo_targeting_included LIKE '%SC%' OR cstats.geo_targeting_included LIKE '%South Carolina%'
                    OR cstats.geo_targeting_included LIKE '%SD%' OR cstats.geo_targeting_included LIKE '%South Dakota%'
                    OR cstats.geo_targeting_included LIKE '%TN%' OR cstats.geo_targeting_included LIKE '%Tennessee%' 
                    OR cstats.geo_targeting_included LIKE '%UT%' OR cstats.geo_targeting_included LIKE '%Utah%' 
                    OR cstats.geo_targeting_included LIKE '%WV%' OR cstats.geo_targeting_included LIKE '%West Virginia%'
                    OR cstats.geo_targeting_included LIKE '%WY%' OR cstats.geo_targeting_included LIKE '%Wyoming%'
                    OR cstats.geo_targeting_included LIKE 'United States'
                    THEN 1 ELSE 0 END AS in_republican_state,
            CASE --Does this ad appear in a Battleground state?
                WHEN  
                    cstats.geo_targeting_included LIKE '%AZ%' OR cstats.geo_targeting_included LIKE '%Arizona%'
                    OR cstats.geo_targeting_included LIKE '%FL%' OR cstats.geo_targeting_included LIKE '%Florida%'
                    OR cstats.geo_targeting_included LIKE '%GA%' OR cstats.geo_targeting_included LIKE '%Georgia%'
                    OR cstats.geo_targeting_included LIKE '%MA%' OR cstats.geo_targeting_included LIKE '%Massachusetts%'
                    OR cstats.geo_targeting_included LIKE '%MI%' OR cstats.geo_targeting_included LIKE '%Michigan%'
                    OR cstats.geo_targeting_included LIKE '%MN%' OR cstats.geo_targeting_included LIKE '%Minnesota%'
                    OR cstats.geo_targeting_included LIKE '%NH%' OR cstats.geo_targeting_included LIKE '%New Hampshire%'
                    OR cstats.geo_targeting_included LIKE '%NC%' OR cstats.geo_targeting_included LIKE '%North Carolina%'
                    OR cstats.geo_targeting_included LIKE '%PA%' OR cstats.geo_targeting_included LIKE '%Pennsylvania%'
                    OR cstats.geo_targeting_included LIKE '%TX%' OR cstats.geo_targeting_included LIKE '%Texas%'
                    OR cstats.geo_targeting_included LIKE '%WI%' OR cstats.geo_targeting_included LIKE '%Wisconsin%'
                    OR cstats.geo_targeting_included LIKE 'United States'
                    THEN 1 ELSE 0 END AS in_battleground_state,
            --For machine learning. If state appears in geo_targeting, 1, else, 0. 
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Alabama%' THEN 1
                ELSE 0 END AS state_alabama,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Alaska%' THEN 1
                ELSE 0 END AS state_alaska,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Arizona%' THEN 1
                ELSE 0 END AS state_arizona,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Arkansas%' THEN 1
                ELSE 0 END AS state_arkansas, 
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%California%' THEN 1
                ELSE 0 END AS state_california,  
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Colorado%' THEN 1
                ELSE 0 END AS state_colorado,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Connecticut%' THEN 1
                ELSE 0 END AS state_connecticut,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Delaware%' THEN 1
                ELSE 0 END AS state_delaware,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Florida%'THEN 1
                ELSE 0 END AS state_florida,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Georgia%' THEN 1
                ELSE 0 END AS state_georgia,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Hawaii%'THEN 1
                ELSE 0 END AS state_hawaii,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Idaho%'THEN 1
                ELSE 0 END AS state_idaho,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Illinois%'THEN 1
                ELSE 0 END AS state_illinois,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Indiana%'THEN 1
                ELSE 0 END AS state_indiana,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Iowa%'THEN 1
                ELSE 0 END AS state_iowa,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Kansas%'THEN 1
                ELSE 0 END AS state_kansas,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Kentucky%'THEN 1
                ELSE 0 END AS state_kentucky,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Louisiana%'THEN 1
                ELSE 0 END AS state_louisiana,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Maine%'THEN 1
                ELSE 0 END AS state_maine,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Maryland%'THEN 1
                ELSE 0 END AS state_maryland,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Massachusetts%'THEN 1
                ELSE 0 END AS state_massachusetts,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Michigan%'THEN 1
                ELSE 0 END AS state_michigan,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Minnesota%'THEN 1
                ELSE 0 END AS state_minnesota,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Mississippi%'THEN 1
                ELSE 0 END AS state_mississippi,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Missouri%'THEN 1
                ELSE 0 END AS state_missouri,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Montana%'THEN 1
                ELSE 0 END AS state_montana,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Nebraska%'THEN 1
                ELSE 0 END AS state_nebraska,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Nevada%'THEN 1
                ELSE 0 END AS state_nevada,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%New Hampshire%'THEN 1
                ELSE 0 END AS state_newHampshire,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%New Jersey%'THEN 1
                ELSE 0 END AS state_newJersey,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%New Mexico%'THEN 1
                ELSE 0 END AS state_newMexico,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%New York%'THEN 1
                ELSE 0 END AS state_newYork,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%North Carolina%'THEN 1
                ELSE 0 END AS state_northCarolina,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%North Dakota%'THEN 1
                ELSE 0 END AS state_northDakota,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Ohio%' THEN 1
                ELSE 0 END AS state_ohio,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Oklahoma%'THEN 1
                ELSE 0 END AS state_oklahoma,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Oregon%'THEN 1
                ELSE 0 END AS state_oregon,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Pennsylvania%'THEN 1
                ELSE 0 END AS state_pennsylvania,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Rhode Island%'THEN 1
                ELSE 0 END AS state_rhodeIsland,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%South Carolina%'THEN 1
                ELSE 0 END AS state_southCarolina,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%South Dakota%'THEN 1
                ELSE 0 END AS state_southDakota,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Tennessee%'THEN 1
                ELSE 0 END AS state_tennessee,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Texas%'THEN 1
                ELSE 0 END AS state_texas,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Utah%'THEN 1
                ELSE 0 END AS state_utah,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Vermont%'THEN 1
                ELSE 0 END AS state_vermont,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Virginia%'THEN 1
                ELSE 0 END AS state_virginia,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Washington%'THEN 1
                ELSE 0 END AS state_washington,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%West Virginia%'THEN 1
                ELSE 0 END AS state_westVirginia,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Wisconsin%'THEN 1
                ELSE 0 END AS state_wisconsin,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Wyoming%'THEN 1
                ELSE 0 END AS state_wyoming,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' THEN 1
                ELSE 0 END AS state_every,
            --Temp fields to clean geo_targeting column. It will be removed in next query layer.
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Alabama%' THEN 'Alabama, '
                END AS alabama,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Alaska%' THEN 'Alaska, '
                END AS alaska,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Arizona%' THEN 'Arizona, '
                END AS arizona,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Arkansas%' THEN 'Arkansas, '
                END AS arkansas, 
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%California%' THEN 'California, '
                END AS california,  
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Colorado%' THEN 'Colorado, '
                END AS colorado,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Connecticut%' THEN 'Connecticut, '
                END AS connecticut,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Delaware%' THEN 'Delaware, '
                END AS delaware,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Florida%' THEN 'Florida, '
                END AS florida,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Georgia%' THEN 'Georgia, '
                END AS georgia,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Hawaii%' THEN 'Hawaii, '
                END AS hawaii,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Idaho%' THEN 'Idaho, '
                END AS idaho,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Illinois%' THEN 'Illinois, '
                END AS illinois,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Indiana%' THEN 'Indiana, '
                END AS indiana,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Iowa%' THEN 'Iowa, '
                END AS iowa,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Kansas%' THEN 'Kansas, '
                END AS kansas,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Kentucky%' THEN 'Kentucky, '
                END AS kentucky,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Louisiana%' THEN 'Louisiana, '
                END AS louisiana,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Maine%' THEN 'Maine, '
                END AS maine,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Maryland%' THEN 'Maryland, '
                END AS maryland,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Massachusetts%' THEN 'Massachusetts, '
                END AS massachusetts,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Michigan%' THEN 'Michigan, '
                END AS michigan,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Minnesota%' THEN 'Minnesota, '
                END AS minnesota,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Mississippi%' THEN 'Mississippi, '
                END AS mississippi,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Missouri%' THEN 'Missouri, '
                END AS missouri,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Montana%' THEN 'Montana, '
                END AS montana,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Nebraska%' THEN 'Nebraska, '
                END AS nebraska,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Nevada%' THEN 'Nevada, '
                END AS nevada,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%New Hampshire%' THEN 'New Hampshire, '
                END AS newHampshire,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%New Jersey%' THEN 'New Jersey, '
                END AS newJersey,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%New Mexico%' THEN 'New Mexico, '
                END AS newMexico,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%New York%' THEN 'New York, '
                END AS newYork,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%North Carolina%' THEN 'North Carolina, '
                END AS northCarolina,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%North Dakota%' THEN 'North Dakota, '
                END AS northDakota,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Ohio%' THEN 'Ohio, '
                END AS ohio,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Oklahoma%' THEN 'Oklahoma, '
                END AS oklahoma,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Oregon%' THEN 'Oregon, '
                END AS oregon,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Pennsylvania%' THEN 'Pennsylvania, '
                END AS pennsylvania,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Rhode Island%' THEN 'Rhode Island, '
                END AS rhodeIsland,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%South Carolina%' THEN 'South Carolina, '
                END AS southCarolina,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%South Dakota%' THEN 'South Dakota, '
                END AS southDakota,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Tennessee%' THEN 'Tennessee, '
                END AS tennessee,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Texas%' THEN 'Texas, '
                END AS texas,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Utah%' THEN 'Utah, '
                END AS utah,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Vermont%' THEN 'Vermont, '
                END AS vermont,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Virginia%' THEN 'Virginia, '
                END AS virginia,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Washington%' THEN 'Washington, '
                END AS washington,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%West Virginia%' THEN 'West Virginia, '
                END AS westVirginia,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Wisconsin%' THEN 'Wisconsin, '
                END AS wisconsin,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' OR cstats.geo_targeting_included LIKE '%Wyoming%' THEN 'Wyoming, '
                END AS wyoming,
            CASE WHEN cstats.geo_targeting_included LIKE 'United States' THEN 'USA'
                END AS unitedStates,
            cstats.geo_targeting_included AS geo_targeting, 
        FROM `bigquery-public-data.google_political_ads.creative_stats` cstats
        WHERE  
            (cstats.advertiser_name IN ('DONALD J. TRUMP FOR PRESIDENT, INC.', 'TRUMP MAKE AMERICA GREAT AGAIN COMMITTEE')
                OR cstats.advertiser_name IN ('BIDEN FOR PRESIDENT', 'BIDEN VICTORY FUND', 'RP4BIDEN')
        )
    )
);