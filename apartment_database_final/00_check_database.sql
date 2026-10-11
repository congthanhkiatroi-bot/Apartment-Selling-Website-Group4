-- ============================================================
-- 00_CHECK_DATABASE.SQL - chạy trong pgAdmin (Query Tool) SAU KHI chạy 01 và 02
-- ============================================================

-- 1. Phải có đủ 14 bảng
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;

-- 2. Số dòng từng bảng (không bảng nào được = 0 trừ khi bạn cố ý để trống)
SELECT 'users' AS bang, COUNT(*) AS so_dong FROM users
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'customer_locations', COUNT(*) FROM customer_locations
UNION ALL SELECT 'owners', COUNT(*) FROM owners
UNION ALL SELECT 'buildings', COUNT(*) FROM buildings
UNION ALL SELECT 'apartments', COUNT(*) FROM apartments
UNION ALL SELECT 'properties', COUNT(*) FROM properties
UNION ALL SELECT 'property_images', COUNT(*) FROM property_images
UNION ALL SELECT 'listings', COUNT(*) FROM listings
UNION ALL SELECT 'favorites', COUNT(*) FROM favorites
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL SELECT 'property_viewings', COUNT(*) FROM property_viewings;

-- 3. ĐÚNG những căn mà trang /properties sẽ hiển thị (đối chiếu với web)
SELECT p.property_id, p.title, p.price, p.status, a.area, a.bedrooms, a.bathrooms, b.district
FROM properties p
JOIN apartments a ON a.apartment_id = p.apartment_id
JOIN buildings  b ON b.building_id  = a.building_id
WHERE p.status = 'AVAILABLE'
ORDER BY p.created_at DESC;

-- 4. Đường dẫn ảnh (file phải có trong src/main/webapp/images/)
SELECT property_id, image_url, is_thumbnail FROM property_images ORDER BY property_id, is_thumbnail DESC;

-- 5. Trigger đã được tạo (kỳ vọng 9 dòng: 5 trigger goc + 4 trigger moi)
SELECT tgname AS trigger_name, tgrelid::regclass AS bang FROM pg_trigger WHERE NOT tgisinternal ORDER BY tgname;


-- 6. So luong lich xem theo trang thai
SELECT status, COUNT(*) AS so_lich
FROM property_viewings GROUP BY status ORDER BY status;

-- 7. Kiem tra khong co lich dang giu cho trung gio
SELECT a.viewing_id AS lich_1, b.viewing_id AS lich_2, a.property_id
FROM property_viewings a
JOIN property_viewings b ON a.property_id = b.property_id
 AND a.viewing_id < b.viewing_id
 AND tsrange(a.start_time, a.end_time, '[)') &&
     tsrange(b.start_time, b.end_time, '[)')
WHERE a.status IN ('PENDING','CONFIRMED')
  AND b.status IN ('PENDING','CONFIRMED');
-- Ky vong: 0 dong.

-- 8. Danh sach property da giu cho sau dat coc
SELECT p.property_id, p.title, p.status, t.transaction_code,
       t.status AS transaction_status
FROM properties p
LEFT JOIN listings l ON l.property_id = p.property_id
LEFT JOIN transactions t ON t.listing_id = l.listing_id
WHERE p.status = 'RESERVED'
ORDER BY p.property_id;
