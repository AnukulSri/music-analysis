Create Database Music
use Music;


Select * from album
Select * from artist
Select * from customer
Select * from employee

Select * from genre
Select * from invoice
Select * from invoice_line
Select * from media_type

Select * from playlist
Select * from playlist_track
Select * from track

-- Who is the senior most employee based on job title?

Select top 1 * from employee
order by levels desc

-- Which countries have the most Invoices?

Select Top 1 billing_country from invoice
group by billing_country
order by billing_country desc

Select count(*) as count_of_total_billing, billing_country from invoice
group by billing_country
order by count_of_total_billing desc

-- What are top 3 values of total invoice?

Select Top 3 * from invoice
order by total desc

-- Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

Select Top 1 billing_city,Sum(total) as invoice_total from invoice
group by billing_city
order by invoice_total desc

-- Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most moneySelect c.customer_id,sum(i.total) as total from customer cjoin invoice ion c.customer_id = i.customer_idgroup by c.customer_idorder by total desc
-- Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with ASelect Distinct email,first_name,last_name from customerjoin invoice on customer.customer_id = invoice.customer_idjoin invoice_line on invoice.invoice_id = invoice_line.invoice_idwhere track_id in (Select track_id from trackjoin genre on track.genre_id = genre.genre_idwhere genre.name Like 'Rock')order by email-- Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bandsSelect Top 10 a.artist_id, a.name, Count(a.artist_id) as number_of_song from track join album on album.album_id = track.album_idjoin artist a on album.album_id = a.artist_idjoin genre on genre.genre_id = track.genre_idwhere genre.name Like 'Rock'group by a.artist_id,a.nameorder by number_of_song desc-- Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

Select name,milliseconds from track
where milliseconds > (Select AVG(milliseconds) as average from track)
order by milliseconds desc

--Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

WITH best_selling_artist AS ( -- here we are creating a temporary table with name best_selling_artist using CTE(Common Table Expression)
	SELECT Top 1 artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id,artist.name
	ORDER BY 3 DESC
	
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY 5 DESC;

-- We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

WITH popular_genre AS 
(
    SELECT Top 1 COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	ORDER BY customer.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

-- Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

WITH Customter_with_country AS (
		SELECT Top 1 customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		ORDER BY billing_country ASC, total_spending desc)
SELECT * FROM Customter_with_country WHERE RowNo <= 1