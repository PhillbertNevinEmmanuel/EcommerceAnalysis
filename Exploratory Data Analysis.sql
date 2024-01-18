/* 1.	Kita akan memberikan promosi untuk customer perempuan di kota Depok melalui email.
		Tolong berikan data ada berapa customer yang harus kita berikan promosi per masing-masing jenis email. */

-- mari kita lihat data yang akan kita gunakan terlebih dahulu
SELECT * FROM EcommerceDatasetRevoU.dbo.customer$

-- kita coba lihat berapa banyak customer berdasarkan email mereka menggunakan group by
SELECT email, COUNT(email) email_type FROM EcommerceDatasetRevoU.dbo.customer$
GROUP BY email

-- sekarang kita tambahkan where untuk kota depok dan gender female diatas aggregate function untuk mengecilkan scope yang ingin kita dapatkan
SELECT email, COUNT(email) email_type FROM EcommerceDatasetRevoU.dbo.customer$
WHERE city = 'Depok' AND gender = 'Female'
GROUP BY email

-- sekarang kita coba tambahkan aggregate function untuk gender
SELECT gender, email, COUNT(email) total_target_customers
FROM EcommerceDatasetRevoU.dbo.customer$
WHERE city = 'Depok' AND gender = 'Female'
GROUP BY gender, email

-- informasi yang didapat dari query --
-- total target customer (perempuan dan berdomisili depok) yang memiliki email berjenis gmail berjumlah 5941 orang
-- yahoo mail berjumlah 729 orang
-- hotmail berjumlah 728 orang

----------------------------------------------------------------------------------------------------------------------------------------------------------

/* 2.	Berikan saya 10 id customer dengan total pembelian overall terbesar. Mau dikasih diskon untuk campaign 9.9! */

-- coba kita pahami dulu tabel yang ingin kita kerjakan
SELECT * FROM EcommerceDatasetRevoU.dbo.transaction$

-- dengan mengasumsikan bahwa field total adalah total uang yang dibelanjakan customer, maka
SELECT TOP 10 customer_id, total
FROM EcommerceDatasetRevoU.dbo.transaction$
ORDER BY total DESC

-- totalnya berulang, kita ingin melakukan grouping berdasarkan customer id dan mengurutkannya berdasarkan total belanja customer tersebut selama lifetime
SELECT TOP 10 customer_id, SUM(total) total_income
FROM EcommerceDatasetRevoU.dbo.transaction$
GROUP BY customer_id
ORDER BY total_income DESC

-- 10 customer yang memiliki total pembayaran terbanyak adalah 258325, 182640, 176921, 201486, 258916, 333280, 245759, 272726, 178473, 178466

----------------------------------------------------------------------------------------------------------------------------------------------------------

/* 3.	Bro! Ada berapa produk ya di database kita yang punya harga kurang dari 1000? 
		Mau gue data nih buat flash sale. */

-- lihat tabel yang ingin kita gunakan
SELECT * FROM EcommerceDatasetRevoU.dbo.product$

-- kita ingin melihat berapa banyak item yang memiliki harga kurang dari 1000
SELECT COUNT(id) product_under_1k FROM EcommerceDatasetRevoU.dbo.product$
WHERE price <= 1000

-- sekarang kita gunakan OVER untuk menggabungkan id, price dan total item dibawah 1000 untuk melihat product id apa saja yang memiliki harga dibawah 1000 beserta brp banyak total itemnya
SELECT id, price, COUNT(DISTINCT id) OVER () total_product_under_1k
FROM EcommerceDatasetRevoU.dbo.product$
WHERE price <= 1000

-- ada 19 total product yang dibawah 1000

----------------------------------------------------------------------------------------------------------------------------------------------------------

/* 4.	Tolong list 5 product_id yang paling banyak dibeli dong, mau kita kasih diskon nih di campaign 11.11. */

-- melihat isi tabel transaksi dulu
SELECT * FROM EcommerceDatasetRevoU.dbo.transaction$

-- berdasarkan pertanyaan tersebut, kita ingin melakukan grouping product_id berdasarkan total quantity dari product id tersebut dan hanya 5 item teratas saja
SELECT TOP 5 product_id, SUM(quantity) total_quantity
FROM EcommerceDatasetRevoU.dbo.transaction$
GROUP BY product_id
ORDER BY total_quantity DESC

-- 5 produk yang dibelanjakan terbanyak adalah 49, 38, 39, 50, dan 58

----------------------------------------------------------------------------------------------------------------------------------------------------------

/* 5.	Berapa jumlah transaksi, pendapatan dan jumlah produk yang terjual di platform kita sekarang secara bulanan?
		Apakah terjadi kenaikan atau tidak? */
-- cek tabel transaksi
SELECT * FROM EcommerceDatasetRevoU.dbo.transaction$

-- kita coba lihat field created_at secara lebih spesifik
SELECT created_at FROM EcommerceDatasetRevoU.dbo.transaction$

-- field tersebut berisi data metrik per tahun dan per bulan yang dibutuhkan untuk melakukan analisa yang akan dibutuhkan, tetapi saya membutuhkannya
-- dalam bentuk yang terpisah dari format timestamp di created_at. saya ingin mencoba melakukan syntax untuk ekstrak tahun dan bulan
SELECT created_at, YEAR(created_at) year, MONTH(created_at) month, DAY(created_at) day
FROM EcommerceDatasetRevoU.dbo.transaction$

-- lakukan grouping terlebih dahulu,
SELECT YEAR(created_at) year_tran, MONTH(created_at) month_tran
FROM EcommerceDatasetRevoU.dbo.transaction$
-- GROUP BY year_tran, month_tran (agregat gunakan format ini saja)
GROUP BY YEAR(created_at), MONTH(created_at)

-- urutkan secara ascending
SELECT YEAR(created_at) year_tran, MONTH(created_at) month_tran
FROM EcommerceDatasetRevoU.dbo.transaction$
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year_tran, month_tran ASC

-- dari data tersebut, bisa kita lihat bahwa data tersebut merupakan data semua transaksi yang dilakukan pada bulan 5 hingga bulan 12 di tahun 2018
-- syntax untuk mengekstrak data dari timestampnya sudah tepat, sekarang saya ingin menghitung total transaksi, total pendapatan dan total item yang dibelanjakan
SELECT COUNT(DISTINCT id) total_transaction, SUM(total) income, SUM(quantity) total_items_bought
FROM EcommerceDatasetRevoU.dbo.transaction$

-- syntax sudah mendapatkan totalnya sudah tepat, sekarang kita coba pisahkan total transaksi, total pendapatan dan total item yang laku per bulan dan per tahunnya
-- kita gabungkan kedua query diatas menjadi satu query
SELECT 
	YEAR(created_at) year_tran, MONTH(created_at) month_tran, COUNT(DISTINCT id) total_transaction, SUM(total) income, SUM(quantity) total_items_bought
FROM EcommerceDatasetRevoU.dbo.transaction$
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year_tran, month_tran ASC

-- berdasarkan informasi yang didapat dari query tersebut, bisa kita simpulkan bahwa 
-- total transaksi stabil mengalami penurunan setelah fluktuatif di bulan 6, dan meningkat drastis di kuartal 4 menjelang akhir tahun, paling tinggi di bulan november
-- income dan total item yang terjual berbanding lurus dengan total transaksi

----------------------------------------------------------------------------------------------------------------------------------------------------------

/* 6.	Saya ingin melakukan pemerataan marketing di perusahaan kita. Boleh saya minta info Total belanja 
		dan rata-rata belanja dari customer kita per kota? */

-- pertama kita lihat kedua tabel yang ingin kita gunakan
SELECT * FROM EcommerceDatasetRevoU.dbo.customer$
SELECT * FROM EcommerceDatasetRevoU.dbo.transaction$

-- kemudian kita coba lakukan grouping customer berdasarkan kotanya, total customer yang ingin kita hitung adalah customer yang melakukan transaksi,
-- jadi kita menggunakan id customer yang berada di tabel transaction$
SELECT city, COUNT(DISTINCT customer_id) total_customer_per_city
FROM EcommerceDatasetRevoU.dbo.customer$ cust
JOIN EcommerceDatasetRevoU.dbo.transaction$ tra
ON cust.id = tra.customer_id
GROUP BY city

-- setelah querynya sesuai, baru kita melakukan perhitungan total belanja beserta rata-ratanya per kota
SELECT city, COUNT(DISTINCT tra.customer_id) total_customer_per_city, SUM(total) total_income_per_city, AVG(total) avg_income_per_city
FROM EcommerceDatasetRevoU.dbo.customer$ cust
JOIN EcommerceDatasetRevoU.dbo.transaction$ tra
ON cust.id = tra.customer_id
GROUP BY city

-- kita sesuaikan query dengan informasi yang ingin didapatkan saja, urutkan berdasarkan alfabet kota
SELECT city, SUM(total) total_income_per_city, AVG(total) avg_income_per_city
FROM EcommerceDatasetRevoU.dbo.customer$ cust
JOIN EcommerceDatasetRevoU.dbo.transaction$ tra
ON cust.id = tra.customer_id
GROUP BY city
ORDER BY city

-- total pendapatan dari customer di kota Bogor berjumlah 2593747093, rata-rata belanjanya 72668.2288684056
-- total pendapatan dari customer di kota Depok berjumlah 5337714240, rata-rata belanjanya 72853.9054950454
-- total pendapatan dari customer di kota Bogor berjumlah 2635133863, rata-rata belanjanya 73043.9589477769
-- total pendapatan dari customer di kota Bogor berjumlah 2644908252, rata-rata belanjanya 72758.2595730634

----------------------------------------------------------------------------------------------------------------------------------------------------------

/* 7.	Ada berapa customer yang memiliki total belanja keseluruhan lebih dari > 200000 ? Tolong di breakdown by
		tipe storenya ya! */

-- kita lihat kedua tabel yang ingin kita gunakan terlebih dahulu
SELECT * FROM EcommerceDatasetRevoU.dbo.transaction$
SELECT * FROM EcommerceDatasetRevoU.dbo.store$

-- kita coba gabungkan kedua tabel tersebut untuk mencari total customer per toko menggunakan join dan group by, kemudian kita tambahkan where untuk
-- mempersempit pencarian menjadi customer yang memiliki total belanja keseluruhan diatas 200000
SELECT type, COUNT(DISTINCT customer_id) total_cust_by_store_mt_200000 FROM EcommerceDatasetRevoU.dbo.transaction$ tra
JOIN EcommerceDatasetRevoU.dbo.store$ sto ON tra.store_id = sto.id
-- WHERE SUM(total) > 200000
GROUP BY type

-- untuk mengakali where clause, kita gunakan having dimana akan menghitung total customer yang memiliki total belanja keseluruhan lebih dari 200000
SELECT type, COUNT(DISTINCT customer_id) total_cust_by_store_mt_200000 FROM EcommerceDatasetRevoU.dbo.transaction$ tra
JOIN EcommerceDatasetRevoU.dbo.store$ sto ON tra.store_id = sto.id
GROUP BY type
HAVING SUM(total) > 200000

-- jumlah customer yang memilki total belanja > 200000 berdasarkan type store event adalah 1295
-- offline store adalah 4942
-- online store adalah 32025
-- dan partnership adlaah 685