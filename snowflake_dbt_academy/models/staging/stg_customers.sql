

with source_data as (
    SELECT *
    FROM {{ source('raw_data', 'customers') }} c
),
cleaned as (
    SELECT
        customer_id::integer as customer_id,
        trim(upper(first_name)) AS first_name,
        trim(upper(last_name)) AS last_name,
        trim(lower(email)) AS email,
        COALESCE(trim(phone), 'N/A') AS phone_number,
        trim(upper(country)) AS country_code,
        CASE
            WHEN country IS NULL OR country = '' THEN 'UNKNOWN'
            WHEN country IN ('US', 'USA', 'United States', 'united states') THEN 'US'
            WHEN country IN ('UK', 'GB', 'United Kingdom', 'united kingdom', 'Great Britain') THEN 'UK'
            WHEN country IN ('CA', 'Canada', 'canada') THEN 'CA'
            WHEN country IN ('DE', 'Germany', 'germany') THEN 'DE'
            WHEN country IN ('FR', 'France', 'france') THEN 'FR'
            ELSE UPPER(country)
        END AS country_standardized,
        created_at::timestamp_ntz as created_at,
        
    FROM source_data 
    WHERE created_at IS NOT NULL
      AND email IS NOT NULL
      AND email LIKE '%@%'
    qualify row_number() over(
        partition by lower(trim(email))
        order by created_at desc
    ) =1    
)

select * form cleaned;
