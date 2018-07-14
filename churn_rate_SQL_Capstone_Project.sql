-- question 1 and 2
SELECT *
 FROM subscriptions
LIMIT 100;
 
 SELECT MAX(subscription_start), 
 MIN(subscription_start)
 FROM subscriptions;
 -- We can calculate churn rate using 1st Dec 2016 till 30th Mar 2017

-- question 3, 4, 5, 6, 7 and 8
WITH 
months AS
		(SELECT
      '2016-12-01' AS 'first_day',
      '2016-12-31' AS 'last_day'
  	 UNION
     SELECT
      '2017-01-01' AS 'first_day',
      '2017-01-31' AS 'last_day'
    UNION
    SELECT
      '2017-02-01' AS 'first_day',
      '2017-02-28' AS 'last_day'
    UNION
    SELECT
     '2017-03-01' AS 'first_day',
     '2017-03-31' AS 'last_day'
    FROM subscriptions),
    
 cross_join AS
 		(SELECT *
     FROM subscriptions
     CROSS JOIN months),
     
 status AS
     (SELECT id, first_day as month, 
       CASE
      		WHEN segment = 87
     	 AND ((subscription_start < first_day)
           AND (subscription_end >= first_day
                OR subscription_end IS NULL))
               THEN 1
            ELSE 0
       END AS 'is_active_87',
       CASE 
          WHEN segment = 87
       AND ((subscription_start < first_day)
       		 AND (subscription_end BETWEEN first_day AND last_day))
               THEN 1
          ELSE 0
       END AS 'is_canceled_87',
       CASE 
      		WHEN segment = 30
       AND ((subscription_start < first_day) 
           AND (subscription_end >= first_day
                OR subscription_end IS NULL))
               THEN 1
          ELSE 0
       END AS 'is_active_30',
       CASE 
          WHEN segment = 30
       AND ((subscription_start < first_day)
       		 AND (subscription_end BETWEEN first_day AND last_day))
								THEN 1
          ELSE 0
       END AS 'is_canceled_30'
                FROM cross_join),
                
status_aggregate AS 
      (SELECT month, sum(is_active_87) AS sum_active_87, sum(is_canceled_87) AS sum_canceled_87, sum(is_active_30) AS sum_active_30, sum(is_canceled_30) AS sum_canceled_30
       FROM status
      GROUP BY month),

-- question 9      
test_status AS 
 (SELECT first_day, segment, 
1.0* SUM(CASE 
          WHEN
       (subscription_start < first_day)
       		 AND (subscription_end BETWEEN first_day AND last_day)
               THEN 1
          ELSE 0
       END) /
  SUM(CASE
      		WHEN 
     	  (subscription_start < first_day)
           AND (subscription_end >= first_day
                OR subscription_end IS NULL)
               THEN 1
            ELSE 0
       END) AS churn_rate
 FROM cross_join
 GROUP BY segment, first_day)
  
SELECT month,
1.0 * sum_canceled_87 / sum_active_87 AS churn_rate_87,
1.0 * sum_canceled_30 / sum_active_30 AS churn_rate_30
FROM status_aggregate;

 -- segment 30 has a lower churn rate for all three months from January to March 2018, with 
 -- January - 0.251 (segment87) -  0.076 (segment30) = 0.175
 -- February - 0.317 (segment87) - 0.0734 (segment30) = 0.244
 -- March - 0.477 (segment 87) - 0.117 (segment30) = 0.36

