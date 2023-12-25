/* created database "mithra"*/
/*The first CSV file is for ball-by-ball data and it has information of all the 193468 balls bowled between the years 2008 and 2020*/
/*The second file contains match-wise data and has data of 816 IPL matches. This table has 17 columns*/
/*created table IPL_matches and IPL_Balls using create table commands */
/* copied the values of the columns using copy command */
/* successfully executed the commands and retrieved the data from tables using select command*/

create table IPL_matches(id int,
				city varchar,
			    date1 date,
				player_of_match varchar,
			venue varchar,
				 neutral_venue varchar,
				 team1	varchar,
				 team2	varchar,
				 toss_winner varchar,	
				 toss_decision	varchar,
				 winner varchar,	
			result	varchar,
				 result_margin	int,
				 eliminator	varchar,
				 method	varchar,
				umpire1	varchar,
				 umpire2 varchar
);


copy IPL_matches from 'C:\Program Files\PostgreSQL\15\data\Dataset_IPL\IPL_Matches\IPL_matches.csv'csv header;

create table IPL_Ball(id int,
inning int,
over int,
ball int,
batsman varchar,
non_striker varchar,
bowler varchar,
batsman_runs int,
extra_runs int,
total_runs int,
is_wicket int,
dismissal_kind varchar,
player_dismissed varchar,
fielder varchar,
extras_type varchar,
batting_team varchar,
bowling_team varchar
);

copy IPL_Ball from 'C:\Program Files\PostgreSQL\15\data\Dataset_IPL\IPL_Ball\IPL_Ball.csv'csv header;
select *from IPL_Ball;
select* from IPL_matches;

/*Select the top 20 rows of the IPL_Ball table after ordering them by id, inning, over, ball in ascending order*/

select * from IPL_Ball
order by id, inning, over, ball asc
limit 20;

/*Select the top 20 rows of the IPL_matches table*/

select * from IPL_matches 
limit 20;

/*	Fetch data of all the matches played on 2nd May 2013 from the IPL_matches table*/

select * from IPL_matches where date1 = '2013-05-02';

/*Fetch data of all the matches where the result mode is ‘runs’ and margin of victory is more than 100 runs*/

select * from IPL_matches where result ='runs' and result_margin > 100;
 
/*Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date*/

select * from IPL_matches where result like 'tie'
order by date1 desc;

/*Get the count of cities that have hosted an IPL match*/

select count(city) from IPL_matches;

/*Create table deliveries_v02 with all the columns of the table ‘IPL_Ball’ 
and an additional column ball_result 
containing values boundary, dot or other depending on the total_run 
(boundary for >= 4, dot for 0 and other for any other number)*/

create table deliveries_v02 as
select *,
case 
when total_runs>=4 then 'boundary'
when total_runs=0 then 'dot'
else 'other'
end as ball_result from IPL_Ball;

/*Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table*/


select 
count(case when ball_result = 'boundary'then 1 end) as Total_Boundary ,
count(case when ball_result = 'dot'then 0 end) as Total_dot 
from deliveries_v02; 

/*Write a query to fetch the total number of boundaries 
scored by each team from the deliveries_v02 table and 
order it in descending order of the number of boundaries scored*/

select 
batting_team,
count(case when  ball_result ='boundary' then 1 end) as Boundaries_Scored
from deliveries_v02
Group By batting_team
Order by Boundaries_Scored desc;


/* Write a query to fetch the total number of dot balls 
bowled by each team and 
order it in descending order of the total number of dot balls bowled*/

select bowling_team,
count(case when ball_result like 'dot'then 1 end) as Total_dot_balls
from deliveries_v02
group by bowling_team
order by Total_dot_balls desc;


/* Write a query to fetch the total number of dismissals by dismissal kinds 
where dismissal kind is not NA */


select 
count(case when  dismissal_kind<>'NA' then 1 end) as Total_dismissals
from deliveries_v02;

/* Write a query to get the top 5 bowlers 
who conceded maximum extra runs from the deliveries table */

select *from deliveries_v02;

select bowler,
count(case when extra_runs <> 0 then 1 end)as extra_runs
from deliveries_v02
group by bowler
order by extra_runs desc
limit 5
;	

/ Write a query to create a table named deliveries_v03 
with all the columns of deliveries_v02 table 
and two additional column (named venue and match_date) 
of venue and date from table matches */

create table deliveries_v03 as
select 
d.*,m.venue, m.date1
from deliveries_v02 as d 
inner join ipl_matches as m 
on d.id=m.id;

/* Write a query to fetch the total runs scored for each venue 
and order it in the descending order of total runs scored*/

select 
venue,
count(total_runs) as Total_score
from deliveries_v03
group by venue
order by Total_score desc;


/* Write a query to fetch the year-wise total runs scored 
at Eden Gardens and order it in the descending order of total runs scored*/

select *from deliveries_v03;
select 
extract(year from deliveries_v03 .date1)as year,
count(case when venue like 'Eden Gardens' then 1 end) as Total_Eden
from deliveries_v03
group by year
order by Total_Eden desc;

/* Get unique team1 names from the matches table, 
we will notice that there are two entries for Rising Pune Supergiant 
one with Rising Pune Supergiant and another one with Rising Pune Supergiants.  
our task is to create a matches_corrected table 
with two additional columns team1_corr and team2_corr 
containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. 
Now analyse these newly created columns*/

select *from ipl_matches;

select distinct(team1) as team1 from IPL_matches;


create table matches_corrected as
select*,
case when team1 like 'Rising Pune Supergiants' then 'Rising Pune Supergiant' else team1 end as team1_corr,
case when team2 like 'Rising Pune Supergiants' then 'Rising Pune Supergiant' else team2 end as team2_corr
from IPL_matches;

select * from matches_corrected;

/* Create a new table deliveries_v04 
with the first column as ball_id 
containing information of match_id, inning, over and ball separated by ‘-’ 
(For ex. 335982-1-0-1 match_id-inning-over-ball) and 
rest of the columns same as deliveries_v03)*/


create table deliveries_v04 as
select
concat(id,'-',inning,'-',over,'-',ball)as ball_id,
deliveries_v03.* 
from deliveries_v03;

/* Compare the total count of rows and total count of distinct ball_id in deliveries_v04*/

select
(select count(*) from deliveries_v04)as Total_rows,
(select count(distinct ball_id)from deliveries_v04) as Total_distinct_ball_id
;

/*SQL Row_Number() function is used to sort and assign row numbers 
to data rows in the presence of multiple groups. 
For example, to identify the top 10 rows 
that have the highest order amount in each region,
we can use row_number to assign row numbers in each group (region) 
with any particular order (decreasing order of order amount) 
and then we can use this new column to apply filters. 
Using this knowledge, solving the following exercise. 
Create table deliveries_v05 with all columns of deliveries_v04 
and an additional column for row number partition over ball_id. 
*/

create table deliveries_v05 as
select*,
row_number() over (partition by ball_id ORDER BY (SELECT NULL))as r_num
from deliveries_v04;
		
/*Use the r_num created in deliveries_v05 
to identify instances where ball_id is repeating. */	

SELECT ball_id, COUNT(r_num) AS repetition_count
FROM deliveries_v05
GROUP BY ball_id
HAVING COUNT(r_num) > 1;

/*Use subqueries to fetch data of all the ball_id which are repeating. */

SELECT *
FROM deliveries_v05
WHERE ball_id IN (
    SELECT ball_id
    FROM deliveries_v05
    GROUP BY ball_id
    HAVING COUNT(r_num) > 1
);
