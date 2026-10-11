-- CHAY SAU 01 va 02. Them 96 can ho cho thue vao buildings/apartments/properties/property_images/listings.
-- Anh la anh minh hoa. Chay tren database TEST truoc.

-- Import 96 rental apartment listings (separate from sale tables).
-- Safe to rerun: UPSERT by source_listing_code; images refreshed only for imported rentals.
-- Photos are shared illustrative photos, not verified actual unit photos.
BEGIN;
CREATE TABLE IF NOT EXISTS rental_apartments (
 rental_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 source_listing_code VARCHAR(50) NOT NULL UNIQUE,
 building_name VARCHAR(200) NOT NULL,
 title VARCHAR(250) NOT NULL,
 monthly_rent NUMERIC(18,2) NOT NULL CHECK (monthly_rent>=0),
 area NUMERIC(10,2) NOT NULL CHECK (area>0),
 bedrooms INTEGER NOT NULL CHECK (bedrooms>=0),
 bathrooms INTEGER NOT NULL CHECK (bathrooms>=0),
 street_address VARCHAR(500),
 ward VARCHAR(150),
 city VARCHAR(150),
 description TEXT,
 listing_type VARCHAR(10) NOT NULL DEFAULT 'RENT' CHECK (listing_type='RENT'),
 status VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE','HIDDEN','RENTED')),
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS rental_apartment_images (
 image_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 rental_id BIGINT NOT NULL REFERENCES rental_apartments(rental_id) ON DELETE CASCADE,
 image_url VARCHAR(500) NOT NULL,
 sort_order SMALLINT NOT NULL,
 is_thumbnail SMALLINT NOT NULL DEFAULT 0 CHECK (is_thumbnail IN (0,1)),
 is_illustrative BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE(rental_id,sort_order)
);
CREATE INDEX IF NOT EXISTS idx_rental_apartments_building ON rental_apartments(building_name);
CREATE INDEX IF NOT EXISTS idx_rental_apartments_rent ON rental_apartments(monthly_rent);

INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('CTG-101', 'City Garden', 'Căn 1PN City Garden Bình Thạnh thiết kế gợn sóng độc đáo', 20000000, 70.0, 1, 1, '59 Ngô Tất Tố', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN CITY GARDEN NGÔ TẤT TỐ DIỆN TÍCH 70M2
Địa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn 1PN diện tích lớn 70m2 với đường nét kiến trúc hình gợn sóng độc bản.
Đầy đủ trang thiết bị nội thất xịn xò, tone màu trầm ấm cúng tinh tế.
Mật độ xanh bao phủ lên tới 70%, tạo môi trường sống trong lành như resort.
Giá thuê: 20 Triệu/tháng.\nLiên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('CTG-102', 'City Garden', 'Căn 2PN City Garden tháp Crescent tầng cao view Landmark 81', 31000000, 105.0, 2, 2, '59 Ngô Tất Tố', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN CITY GARDEN THÁP CRESCENT 105M2
Địa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn hộ 2 phòng ngủ rộng rãi, ban công cong độc đáo ngắm trọn Landmark 81.
Nội thất thiết kế hiện đại sang trọng, trang bị máy rửa bát và tủ lạnh lớn.
Tiện ích: Hồ bơi tràn bờ 50m, nhà hàng cao cấp, mảng xanh bãi cỏ nội khu.
Giá thuê: 31 Triệu/tháng.
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('CTG-103', 'City Garden', 'Căn 3PN City Garden nội thất Châu Âu thiết kế cực sang', 46000000, 140.0, 3, 2, '59 Ngô Tất Tố', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN CITY GARDEN NGÔ TẤT TỐ DIỆN TÍCH 140M2
Địa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn 3PN thiết kế mở, khung cửa kính từ sàn đến trần đón trọn ánh sáng tự nhiên.
Đã chuẩn bị sẵn đầy đủ đồ dùng, chỉ việc xách vali vào ở ngay.
Vị trí đắc địa di chuyển sang trung tâm Bến Nghé chỉ mất 5 phút.
Giá thuê: 46 Triệu/tháng.
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('CTG-104', 'City Garden', 'Penthouse City Garden thiết kế Duplex đỉnh cao kiến trúc', 90000000, 220.0, 4, 4, '59 Ngô Tất Tố', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE DUPLEX CITY GARDEN DIỆN TÍCH 220M2
Địa chỉ: 59 Ngô Tất Tố, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn Penthouse thông tầng đẳng cấp sở hữu tầm nhìn 360 độ ôm trọn trung tâm TP.HCM.
Nội thất xa hoa được đặt riêng từng chi tiết từ các hãng thiết kế danh tiếng.
Sảnh thang máy thẻ từ bảo mật tuyệt đối.
Giá thuê: 90 Triệu/tháng.
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('DMI-101', 'Đảo Kim Cương (Diamond Island)', 'Căn 1PN tháp Hawaii Đảo Kim Cương view sông Sài Gòn êm đềm', 18000000, 55.0, 1, 1, 'Số 1 Đường số 104', 'Phường Bình Trưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN ĐẢO KIM CƯƠNG THÁP HAWAII DIỆN TÍCH 55M2
Địa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh
Căn hộ 1PN trên hòn đảo tự nhiên duy nhất tại TP.HCM, không gian sống nghỉ dưỡng tuyệt đối.
Đầy đủ nội thất nhập khẩu, ban công hướng sông mát mẻ quanh năm.
Tiện ích đặc quyền: Hồ bơi mặn 2.300m2, bến du thuyền riêng, công viên thủy cung.
Giá thuê: 18 Triệu/tháng.
Liên hệ: 097x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('DMI-102', 'Đảo Kim Cương (Diamond Island)', 'Căn 2PN tháp Bora Bora Đảo Kim Cương full nội thất hiện đại', 26000000, 88.0, 2, 2, 'Số 1 Đường số 104', 'Phường Bình Trưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN ĐẢO KIM CƯƠNG THÁP BORA BORA DIỆN TÍCH 88M2
Địa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh
Căn hộ 2 phòng ngủ tòa Bora Bora đón trọn bình minh ngập tràn sức sống.
Thiết kế tối giản tinh tế, sofa da bò, hệ thống bếp điện và lò nướng âm tủ.
Tận hưởng 86.5% mật độ mảng xanh và mặt nước bao phủ xung quanh đảo.
Giá thuê: 26 Triệu/tháng.
Liên hệ: 097x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('DMI-103', 'Đảo Kim Cương (Diamond Island)', 'Căn góc 3PN tháp Maldives Đảo Kim Cương view sông trực diện', 45000000, 125.0, 3, 2, 'Số 1 Đường số 104', 'Phường Bình Trưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN ĐẢO KIM CƯƠNG THÁP MALDIVES DIỆN TÍCH 125M2
Địa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh
Căn góc đắt giá nhất tháp Maldives, view nhìn 220 độ ôm trọn sông Sài Gòn và Bitexco.
Trang bị nội thất siêu xa hoa nhập khẩu hoàn toàn từ Châu Âu.
Không gian sống yên tĩnh hoàn hảo cách biệt hoàn toàn khỏi khói bụi.
Giá thuê: 45 Triệu/tháng.
Liên hệ: 097x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('DMI-104', 'Đảo Kim Cương (Diamond Island)', 'Căn Pool Villa Đảo Kim Cương sân vườn hồ bơi riêng xa xỉ', 100000000, 210.0, 4, 4, 'Số 1 Đường số 104', 'Phường Bình Trưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
POOL VILLA ĐẢO KIM CƯƠNG HỒ BƠI SÂN VƯỜN RIÊNG 210M2
Địa chỉ: Số 1 Đường số 104, Phường Bình Trưng, TP. Hồ Chí Minh
Căn hộ Pool Villa tầng trệt có hồ bơi riêng và sân vườn bao quanh nhà.
Mang đến sự riêng tư tối đa chuẩn resort đẳng cấp giữa lòng thành phố.
Đầy đủ trang thiết bị nội thất đạt chuẩn khách sạn 5 sao. 
Giá thuê: 100 Triệu/tháng.
Liên hệ: 097x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('EGR-101', 'Eco Green Sài Gòn', 'Căn 1PN Eco Green Sài Gòn Nguyễn Văn Linh full đồ xinh xắn', 12000000, 45.0, 1, 1, '39/1B Nguyễn Văn Linh', 'Phường Tân Thuận', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN ECO GREEN SÀI GÒN DIỆN TÍCH 45M2
Địa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh
Căn hộ 1PN thiết kế xinh xắn tối ưu không gian, ban công thoáng mát.
Đầy đủ nội thất: Sofa, tủ lạnh, tivi, máy giặt, bếp từ âm, máy lạnh Daikin.
Nằm ngay cạnh công viên Hương Tràm rộng 22ha cực kỳ xanh mát.
Giá thuê: 12 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('EGR-102', 'Eco Green Sài Gòn', 'Căn 2PN Eco Green Sài Gòn view công viên Hương Tràm 22ha', 16000000, 65.0, 2, 2, '39/1B Nguyễn Văn Linh', 'Phường Tân Thuận', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN ECO GREEN SÀI GÒN DIỆN TÍCH 65M2
Địa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh
Căn hộ 2PN 2WC thiết kế hợp lý, các phòng ngủ đều có cửa sổ đón sáng tự nhiên.
Trang bị kính khoang âm cản nhiệt cách âm tuyệt đối.
Tiện ích: Hồ bơi tràn bờ, trường tiểu học Kim Đồng ngay trong dự án, TTTM.
Giá thuê: 16 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('EGR-103', 'Eco Green Sài Gòn', 'Căn góc 3PN Eco Green Sài Gòn tầng cao view sông cầu Phú Mỹ', 22000000, 85.0, 3, 2, '39/1B Nguyễn Văn Linh', 'Phường Tân Thuận', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN ECO GREEN SÀI GÒN 85M2
Địa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh
Căn góc 3PN sở hữu tầm nhìn panorama tuyệt đẹp ngắm cầu Phú Mỹ lung linh về đêm.
Bàn giao thiết bị bếp Teka, thiết bị vệ sinh Duravit cao cấp.
Kết nối sang trung tâm Bến Nghé qua cầu Tân Thuận chỉ 5 phút.
Giá thuê: 22 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('EGR-104', 'Eco Green Sài Gòn', 'Căn 3PN Eco Green Sài Gòn full nội thất gỗ cao cấp', 24000000, 95.0, 3, 2, '39/1B Nguyễn Văn Linh', 'Phường Tân Thuận', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN ECO GREEN SÀI GÒN DIỆN TÍCH 95M2
Địa chỉ: 39/1B Nguyễn Văn Linh, Phường Tân Thuận, TP. Hồ Chí Minh
Căn 3PN diện tích lớn, thiết kế hiện đại sang trọng thích hợp cho gia đình ở dài hạn.
Trang bị full đồ gỗ tự nhiên, tivi 65 inch, tủ lạnh side-by-side.
Dịch vụ quản lý tòa nhà chuyên nghiệp an toàn 24/7.
Giá thuê: 24 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('EMP-101', 'Empire City', 'Căn 1PN Linden Empire City Thủ Thiêm full nội thất xịn', 23000000, 64.0, 1, 1, 'Khu đô thị mới Thủ Thiêm', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN LINDEN RESIDENCES EMPIRE CITY DIỆN TÍCH 64M2
Địa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh.
Căn hộ 1PN diện tích cực rộng 64m2 tại phân khu Linden Residences.
Thiết kế tinh tế, không gian bếp thoáng đạt kết nối trực tiếp ra ban công.
Tiện ích: Hồ bơi nước mặn 50m, phòng sauna khô/ướt, khu BBQ ngoài trời.
Giá thuê: 23 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('EMP-102', 'Empire City', 'Cho thuê căn 2PN Tilia Empire City tầng cao view nội khu mát mẻ', 34000000, 93.0, 2, 2, 'Khu đô thị mới Thủ Thiêm', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN TILIA RESIDENCES EMPIRE CITY DIỆN TÍCH 93M2
Địa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh
Căn hộ 2PN phân khu Tilia Residences, layout thiết kế vuông vức phong thủy tốt.
Đã trang bị đầy đủ đồ dùng sinh hoạt, máy giặt sấy, lò nướng âm tủ.
Môi trường sống chuẩn quốc tế, cư dân văn minh tri thức.
Giá thuê: 34 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('EMP-103', 'Empire City', 'Căn 3PN Cove Empire City view trực diện sông thang máy riêng', 70000000, 155.0, 3, 3, 'Khu đô thị mới Thủ Thiêm', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN COVE RESIDENCES EMPIRE CITY THANG MÁY RIÊNG 155M2
Địa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh
Căn hộ đắt giá thuộc tòa Cove Residences – tòa căn hộ sát sông nhất dự án Empire City.
Trang bị thang máy riêng mở thẳng vào căn hộ, tầm nhìn ôm trọn sông Sài Gòn.
Bàn giao nội thất cao cấp chuẩn resort 5 sao.
Giá thuê: 70 Triệu/tháng.\nLiên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('EMP-104', 'Empire City', 'Penthouse Empire City Thủ Thiêm tầng cao view 360 độ cực phẩm', 120000000, 220.0, 4, 4, 'Khu đô thị mới Thủ Thiêm', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE EMPIRE CITY THỦ THIÊM TẦNG CAO DIỆN TÍCH 220M2
Địa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh
Căn Penthouse thiết kế Duplex thông tầng đẳng cấp nhất tại dự án.
Ban công siêu rộng ôm trọn góc view 360 độ ngắm toàn cảnh sông Sài Gòn và thành phố.
Thang máy riêng biệt, hệ thống an ninh 3 lớp tuyệt đối bảo mật.
Giá thuê: 120 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('ESH-101', 'Estella Heights', 'Căn 1PN Estella Heights thiết kế nghỉ dưỡng full nội thất', 22000000, 60.0, 1, 1, '88 Xa Lộ Hà Nội', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN ESTELLA HEIGHTS PHONG CÁCH RESORT DIỆN TÍCH 60M2
Địa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh
Căn hộ 1PN ban công rộng hướng hồ bơi tràn bờ phong cách nghỉ dưỡng.
Bàn giao full nội thất cao cấp sang trọng chuẩn 5 sao.
Tiện ích đẳng cấp: Hồ bơi lướt sóng, đường chạy bộ trên cao, phòng gym hiện đại.
TTTM Estella Place ngay bên dưới cung cấp mọi nhu cầu mua sắm, ẩm thực.
Giá thuê: 22 Triệu/tháng.
Liên hệ: 091x.xxx.xxx"
  },') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('ESH-102', 'Estella Heights', 'Cho thuê căn 2PN Estella Heights tháp T3 view hồ bơi tràn bờ', 32000000, 90.0, 2, 2, '88 Xa Lộ Hà Nội', 'Phường Thảo Điền', 'TP. Thủ Đức', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN ESTELLA HEIGHTS THÁP T3 DIỆN TÍCH 90M2
Địa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh
Thiết kế phòng khách nối liền ban công kính tràn viền vô cùng thông thoáng.
Trang bị đầy đủ thiết bị điện tử cao cấp, sofa da, bàn ăn gỗ sồi.
Môi trường sống xanh, mát mẻ với mật độ cây xanh che phủ cao.
Giá thuê: 32 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('ESH-103', 'Estella Heights', 'Căn 3PN Estella Heights tầng cao view trọn thành phố lộng lẫy', 48000000, 130.0, 3, 2, '88 Xa Lộ Hà Nội', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN ESTELLA HEIGHTS TẦNG CAO DIỆN TÍCH 130M2
Địa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Thủ Đức
Căn 3 phòng ngủ rộng rãi, view tầng cao ngắm trọn bình minh và hoàng hôn thành phố.
Bếp đóng riêng biệt chống ám mùi, trang bị lò nướng và máy rửa bát cao cấp.
Quản lý vận hành bởi tập đoàn uy tín Keppel Land.
Giá thuê: 48 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('ESH-104', 'Estella Heights', 'Căn Penthouse Estella Heights sân vườn riêng đẳng cấp thượng lưu', 95000000, 250.0, 4, 4, '88 Xa Lộ Hà Nội', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE ESTELLA HEIGHTS SÂN VƯỜN RIÊNG DIỆN TÍCH 250M2
Địa chỉ: 88 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh
Căn Penthouse đỉnh cao sở hữu sân vườn riêng rộng lớn ngắm view 360 độ.
Thiết kế nội thất độc bản từ các nhà thiết kế hàng đầu, không gian xa hoa.
Thang máy thẻ từ riêng, dịch vụ chăm sóc căn hộ đặc quyền VIP.
Giá thuê: 95 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('GMS-101', 'Grand Marina Saigon', 'Căn 1PN Tòa Lake Grand Marina Saigon quản lý chuẩn Marriott', 38000000, 59.0, 1, 1, '2 Tôn Đức Thắng', 'Phường Bến Nghé', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ HÀNG HIỆU MARRIOTT GRAND MARINA SAIGON 59M2
Địa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh
Căn hộ dịch vụ hàng hiệu chuẩn Marriott International đầu tiên tại trung tâm Sài Gòn.
Bàn giao full nội thất nhập khẩu Ý, thiết bị bếp và vệ sinh Gaggenau & Duravit.
Dịch vụ quản gia, lễ tân và concierge tiêu chuẩn khách sạn 5 sao quốc tế 24/7.
Giá thuê: 38 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('GMS-102', 'Grand Marina Saigon', 'Cho thuê căn 2PN Grand Marina Saigon view sông cực đẹp', 58000000, 88.0, 2, 2, '2 Tôn Đức Thắng', 'Phường Bến Nghé', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN GRAND MARINA SAIGON VIEW SÔNG 88M2
Địa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh
Căn hộ 2PN view trực diện sông Sài Gòn và cầu Ba Sơn, ban công kính tràn viền siêu sang.
Tận hưởng các đặc quyền tiện ích: Hồ bơi mây trên tầng cao, rạp chiếu phim riêng, phòng họp VIP.
Môi trường sống tinh hoa tôn vinh đẳng cấp gia chủ.
Giá thuê: 58 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('GMS-103', 'Grand Marina Saigon', 'Căn 3PN Hàng hiệu Marriott Grand Marina view trung tâm Q1', 95000000, 133.0, 3, 3, '2 Tôn Đức Thắng', 'Phường Bến Nghé', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN MARRIOTT GRAND MARINA SAIGON 133M2
Địa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh
Căn 3PN góc 2 mặt thoáng ngắm toàn cảnh đại lộ Tôn Đức Thắng và sông Sài Gòn.
Thiết kế tỉ mỉ đến từng chi tiết nhỏ bởi các kiến trúc sư thế giới.
Bàn giao đầy đủ trang thiết bị nội thất xa hoa nhất.
Giá thuê: 95 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('GMS-104', 'Grand Marina Saigon', 'Căn Penthouse Masterise Grand Marina Bến Nghé siêu sang', 180000000, 220.0, 4, 4, '2 Tôn Đức Thắng', 'Phường Bến Nghé', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE GRAND MARINA SAIGON BẾN NGHÉ 220M2
Địa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh
Siêu căn hộ Penthouse hàng hiệu Marriott bậc nhất Việt Nam.
Sở hữu tầm nhìn kiệt tác ôm trọn dòng sông Sài Gòn và trung tâm đô thị.
Đặc quyền phục vụ riêng biệt theo chuẩn mực toàn cầu của tập đoàn Marriott. 
Giá thuê: 180 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('GTW-101', 'The Gateway Thảo Điền', 'Cho thuê căn 1PN Gateway Thảo Điền full nội thất hiện đại', 19000000, 52.0, 1, 1, '2 Trần Ngọc Diện', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN THE GATEWAY THẢO ĐIỀN DIỆN TÍCH 52M2
Địa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh.
Căn hộ 1PN thiết kế tinh tế, tối ưu từng khoảng không gian sống.
Nội thất nhập khẩu cao cấp, trang bị hệ thống Smart Home tiện lợi.
Tọa lạc tại khu phố tây Trần Ngọc Diện sầm uất với nhiều nhà hàng, cafe cao cấp.
Giá thuê: 19 Triệu/tháng.
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('GTW-102', 'The Gateway Thảo Điền', 'Căn 2PN Gateway Thảo Điền tầng cao view sông Sài Gòn tuyệt đẹp', 28000000, 85.0, 2, 2, '2 Trần Ngọc Diện', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN THE GATEWAY THẢO ĐIỀN VIEW SÔNG DIỆN TÍCH 85M2
Địa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh
Ban công kính tràn chiều cao ceiling 3.1m tạo sự thông thoáng vượt trội.
View sông Sài Gòn thơ mộng không bị che chắn.
Tiện ích: Hồ bơi nước mặn, phòng xông hơi, khu nướng BBQ ngoài trời.
 Giá thuê: 28 Triệu/tháng.
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('GTW-103', 'The Gateway Thảo Điền', 'Căn 3PN Gateway Thảo Điền thiết kế sang trọng nội thất cao cấp', 42000000, 122.0, 3, 2, '2 Trần Ngọc Diện', 'Phường Thảo Điền', 'TP. Thủ Đức', '=== MÔ TẢ CHI TIẾT ==
CĂN HỘ 3PN THE GATEWAY THẢO ĐIỀN DIỆN TÍCH 122M2
Địa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh
Căn 3PN diện tích lớn, thiết kế mở đón ánh sáng tự nhiên cho toàn bộ các phòng.
Bếp đảo hiện đại trang bị thiết bị SBG Bosch chất lượng cao.
Vị trí đắc địa gần các trường quốc tế BIS, ISHCMC.
Giá thuê 42 Triệutháng.
Liên hệ 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('GTW-104', 'The Gateway Thảo Điền', 'Căn Garden Villa Gateway Thảo Điền có sân vườn rộng thoáng', 75000000, 180.0, 4, 3, '2 Trần Ngọc Diện', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
GARDEN VILLA THE GATEWAY THẢO ĐIỀN DIỆN TÍCH 180M2
Địa chỉ: 2 Trần Ngọc Diện, Phường Thảo Điền, TP. Hồ Chí Minh
Căn hộ sân vườn đặc quyền tầng trệt mang đến không gian sống chuẩn biệt thự.
Sân vườn riêng xanh mát thích hợp tổ chức tiệc trà, BBQ gia đình.
Thiết kế 4 phòng ngủ riêng tư, nội thất siêu sang trọng.
Giá thuê: 75 Triệu/tháng.
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('HDC-101', 'Haado Centrosa Garden', 'Căn 1PN1WC Hà Đô Centrosa Garden full nội thất hiện đại', 15000000, 53.0, 1, 1, '200 3 Tháng 2', 'Phường Hòa Hưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN HÀ ĐÔ CENTROSA GARDEN 53M2
Địa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh
Căn hộ 1PN thiết kế thông minh + 1 phòng đa năng làm việc rộng rãi.
Full nội thất đẹp, tông màu tươi sáng, trang bị tivi, tủ lạnh, máy giặt.
Vị trí trung tâm kết nối giao thông đi các khu vực vô cùng thuận tiện.
Giá thuê: 15 Triệu/tháng.
Liên hệ: 097x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('HDC-102', 'Haado Centrosa Garden', 'Cho thuê căn 2PN2WC Hà Đô Centrosa tháp Orchid view hồ bơi', 20000000, 86.0, 2, 2, '200 3 Tháng 2', 'Phường Hòa Hưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN HÀ ĐÔ CENTROSA GARDEN ORCHID 86M2
Địa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh
Căn hộ 2PN 2WC tòa Orchid, ban công nhìn trực diện hồ bơi tràn tràn mây nội khu.
Đã được trang bị đầy đủ trang thiết bị nội thất xịn xò.
Tiện ích: 21 khu vườn treo trên không, hồ bơi tràn bờ, phòng gym, siêu thị.
Giá thuê: 20 Triệu/tháng.
Liên hệ: 097x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('HDC-103', 'Haado Centrosa Garden', 'Căn 2PN+1 Hà Đô Centrosa Garden góc 2 mặt thoáng cực rộng', 24000000, 107.0, 3, 2, '200 3 Tháng 2', 'Phường Hòa Hưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 2PN+1 HÀ ĐÔ CENTROSA GARDEN 107M2
Địa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh
Căn góc diện tích lớn 107m2 thiết kế 2PN lớn + 1 phòng đọc sách/làm việc.
Bếp riêng biệt nối liền ra logia phơi đồ kín đáo.
An ninh bảo vệ 3 lớp thẻ từ thang máy an toàn.
Giá thuê: 24 Triệu/tháng.
Liên hệ: 097x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('HDC-104', 'Haado Centrosa Garden', 'Căn 3PN Hà Đô Centrosa Garden tầng cao view trọn thành phố', 29000000, 123.0, 3, 2, '200 3 Tháng 2', 'Phường Hòa Hưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN HÀ ĐÔ CENTROSA GARDEN 123M2
Địa chỉ: 200 3 Tháng 2, Phường Hòa Hưng, TP. Hồ Chí Minh
Căn hộ 3PN diện tích lớn thích hợp cho gia đình nhiều thế hệ sinh sống.
Trang bị full nội thất cao cấp: Sofa da, bàn ăn 6 ghế, máy lạnh âm trần.
Giá thuê: 29 Triệu/tháng.
Liên hệ: 097x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('INF-101', 'The Infiniti at Riviera Point', 'Căn 1PN The Infiniti Riviera Point full nội thất mới 100%', 15000000, 58.0, 1, 1, '584 Huỳnh Tấn Phát', 'Phường Phú Thuận', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN THE INFINITI RIVIERA POINT 58M2
Địa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh
Căn hộ 1PN mang cảm hứng thiên nhiên Hawaii do Keppel Land phát triển.
Ban công hướng sông Cả Cấm vô cùng mát mẻ.
Tiện ích đột phá: Sân chơi nước nội khu lớn nhất TP.HCM, hồ bơi tràn bờ 50m.
Giá thuê: 15 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('INF-102', 'The Infiniti at Riviera Point', 'Cho thuê căn 2PN Riviera Point view sông thoáng mát', 21000000, 82.0, 2, 2, '584 Huỳnh Tấn Phát', 'Phường Phú Thuận', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN THE INFINITI RIVIERA POINT 82M2
Địa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh
Căn 2PN thiết kế vuông vức, không gian phòng khách nối liền ban công thông thoáng.
Trang bị đầy đủ thiết bị bếp, máy lạnh âm trần, nội thất gỗ hiện đại.
Kết nối sang trung tâm Phú Mỹ Hưng chỉ 2 phút qua cầu Phú Thuận.
Giá thuê: 21 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('INF-103', 'The Infiniti at Riviera Point', 'Căn góc 3PN Riviera Point tầng cao view toàn cảnh Quận 7', 30000000, 120.0, 3, 2, '584 Huỳnh Tấn Phát', 'Phường Phú Thuận', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN THE INFINITI RIVIERA POINT 120M2
Địa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh
Căn góc 3 phòng ngủ thoáng đạt, đón nắng và gió tự nhiên tràn ngập các phòng.
Bàn giao trọn bộ nội thất xịn xò chuẩn phong cách resort nghỉ dưỡng.
Giá thuê: 30 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('INF-104', 'The Infiniti at Riviera Point', 'Căn Duplex The Infiniti Riviera Point thiết kế thông tầng xa hoa', 48000000, 150.0, 3, 3, '584 Huỳnh Tấn Phát', 'Phường Phú Thuận', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ DUPLEX THE INFINITI RIVIERA POINT 150M2
Địa chỉ: 584 Huỳnh Tấn Phát, Phường Phú Thuận, TP. Hồ Chí Minh
Căn Duplex thông tầng ấn tượng với hệ kính cao kịch trần ngắm trọn view sông.
Nội thất xa hoa được đặt riêng phù hợp không gian sang trọng.
Quản lý vận hành chuẩn mực bởi Keppel Land.
Giá thuê: 48 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('LMN-101', 'Leman Luxury Apartments', 'Căn 2PN Leman Luxury Nguyễn Đình Chiểu full nội thất Thụy Sỹ', 32000000, 75.0, 2, 2, '117 Nguyễn Đình Chiểu', 'Phường Xuân Khánh', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN LEMAN LUXURY XUÂN KHÁNH DIỆN TÍCH 75M2
Địa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh
Căn hộ mang đậm kiến trúc Thụy Sỹ giữa tâm xanh thành phố.
Trang bị full nội thất cao cấp cổ điển pha lẫn hiện đại sang trọng.
Siêu thị Bon Grocer và chuỗi nhà hàng cao cấp ngay tại khối đế tòa nhà.
Giá thuê: 32 Triệu/tháng.
Liên hệ: 096x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('LMN-102', 'Leman Luxury Apartments', 'Cho thuê căn 3PN Leman Luxury không gian sống yên tĩnh đẳng cấp', 45000000, 96.0, 3, 2, '117 Nguyễn Đình Chiểu', 'Phường Xuân Khánh', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN LEMAN LUXURY APARTMENTS 96M2
Địa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh
Căn hộ 3PN thiết kế thông thoáng, ô cửa kính lớn đón nắng tự nhiên mát mẻ.
Đầy đủ tiện ích sinh hoạt, lò nướng, máy giặt sấy, giường nệm cao cấp.
Hồ bơi chân mây trên tầng mây ngắm trọn trung tâm thành phố.
Giá thuê: 45 Triệu/tháng.
Liên hệ: 096x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('LMN-103', 'Leman Luxury Apartments', 'Căn góc 3PN Leman Luxury ban công thoáng mát nội thất xịn', 52000000, 113.0, 3, 2, '117 Nguyễn Đình Chiểu', 'Phường Xuân Khánh', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN LEMAN LUXURY DIỆN TÍCH 113M2
Địa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh
Căn góc 2 mặt tiền đường Nguyễn Đình Chiểu - Trương Định vô cùng đắt giá.
Thiết kế nội thất sang trọng, trang thiết bị điện tử âm tường hiện đại.
Giá thuê: 52 Triệu/tháng.
Liên hệ: 096x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('LMN-104', 'Leman Luxury Apartments', 'Penthouse Leman Luxury tầng cao sân vườn riêng cực hiếm', 90000000, 200.0, 4, 4, '117 Nguyễn Đình Chiểu', 'Phường Xuân Khánh', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE LEMAN LUXURY SÂN VƯỜN RIÊNG 200M2
Địa chỉ: 117 Nguyễn Đình Chiểu, Phường Xuân Khánh, TP. Hồ Chí Minh
Penthouse đẳng cấp có khu sân vườn ngợp bóng mát ngay trên tầng cao.
Không gian sống thượng lưu riêng biệt hoàn toàn giữa lòng trung tâm.
Nội thất thiết kế độc bản siêu sang trọng. 
Giá thuê: 90 Triệu/tháng.
Liên hệ: 096x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MDT-101', 'Midtown Phú Mỹ Hưng', 'Căn 1PN The Grande Midtown Phú Mỹ Hưng thiết kế Nhật Bản', 17000000, 62.0, 1, 1, 'Đường Nguyễn Lương Bằng', 'Phường Tân Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN MIDTOWN PHÚ MỸ HƯNG 62M2
Địa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh
Căn 1PN thuộc phân khu The Grande, thiết kế tối giản chuẩn phong cách Nhật Bản.
Ban công đón ánh sáng tự nhiên, full nội thất gỗ cao cấp.
Công viên hoa anh đào Sakura Park ngay sát chân tòa nhà.
Giá thuê: 17 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MDT-102', 'Midtown Phú Mỹ Hưng', 'Cho thuê căn 2PN The Symphony Midtown view Sakura Park', 25000000, 89.0, 2, 2, 'Đường Nguyễn Lương Bằng', 'Phường Tân Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN THE SYMPHONY MIDTOWN PHÚ MỸ HƯNG 89M2
Địa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh
Căn 2PN view trực diện công viên hoa anh đào Sakura Park thơ mộng.
Đầy đủ thiết bị điện tử hiện đại, thiết bị vệ sinh Toto thông minh.
Tiện ích: Hồ bơi massage Jacuzzi, phòng sauna khô/ướt, phòng chơi trẻ em.
Giá thuê: 25 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MDT-103', 'Midtown Phú Mỹ Hưng', 'Căn góc 3PN The Signature Midtown tầng trung view sông biệt thự', 40000000, 121.0, 3, 2, 'Đường Nguyễn Lương Bằng', 'Phường Tân Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN THE SIGNATURE MIDTOWN 121M2
Địa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh
Căn góc đắt giá thuộc tòa The Signature có cầu đi bộ trên không biểu tượng.
View trực diện sông Cả Cấm và khu biệt thự Phú Mỹ Hưng sang trọng.
Trang bị full đồ gỗ tự nhiên nhập khẩu cao cấp.\n- Giá thuê: 40 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MDT-104', 'Midtown Phú Mỹ Hưng', 'Căn 4PN The Peak Midtown Phú Mỹ Hưng full nội thất cao cấp', 62000000, 160.0, 4, 3, 'Đường Nguyễn Lương Bằng', 'Phường Tân Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 4PN THE PEAK MIDTOWN PHÚ MỸ HƯNG 160M2
Địa chỉ: Đường Nguyễn Lương Bằng, Phường Tân Phú, TP. Hồ Chí Minh
Căn hộ 4PN thuộc phân khu đỉnh cao nhất The Peak Midtown.
Đầy đủ tiện ích thác nước vô cực, đài ngắm cảnh waterfall, phòng gym hiện đại.
Không gian sống xanh thư thái chuẩn mực đẳng cấp quốc tế.
Giá thuê: 62 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MST-101', 'Masteri Thảo Điền', 'Cho thuê căn Studio Masteri Thảo Điền T4 full nội thất xinh xắn', 13500000, 48.0, 1, 1, '159 Xa Lộ Hà Nội', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ STUDIO MASTERI THẢO ĐIỀN TÒA T4 DIỆN TÍCH 48M2
Địa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh
Căn hộ Studio tầng trung thiết kế tối ưu diện tích, đón ánh sáng tự nhiên tốt.
Đầy đủ nội thất cao cấp: Giường tủ, sofa, máy giặt, tủ lạnh, bếp từ.
Tiện ích nội khu: Hồ bơi ngoài trời, phòng Gym, TTTM Vincom Mega Mall ngay dưới chân nhà.
Kết nối giao thông thuận tiện qua tuyến Metro số 1 và đại lộ Xa Lộ Hà Nội.
Giá thuê: 13.5 Triệu/tháng.
Liên hệ: 090x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MST-102', 'Masteri Thảo Điền', 'Căn hộ 2PN2WC Masteri Thảo Điền T2 view sông Sài Gòn thoáng mát', 18000000, 68.0, 2, 2, '159 Xa Lộ Hà Nội', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN2WC MASTERI THẢO ĐIỀN VIEW SÔNG DIỆN TÍCH 68M2
Địa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh
Căn hộ 2 phòng ngủ tòa T2, ban công hướng Đông Bắc view trực diện sông lộng gió. 
Bàn giao đầy đủ trang thiết bị nội thất xịn, chỉ cần xách vali vào ở ngay.
Cộng đồng cư dân văn minh, nhiều chuyên gia nước ngoài sinh sống. 
An ninh 24/7, thẻ từ thang máy riêng biệt cho từng tầng.
Giá thuê: 18 Triệu/tháng.
Liên hệ: 090x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MST-103', 'Masteri Thảo Điền', 'Căn góc 3PN Masteri Thảo Điền T1 tầng cao view Vincom sang trọng', 26000000, 90.0, 3, 2, '159 Xa Lộ Hà Nội', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN MASTERI THẢO ĐIỀN TÒA T1 DIỆN TÍCH 90M2
Địa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh
Căn góc 2 mặt thoáng, tầm nhìn panorama ôm trọn khu Thảo Điền năng động.
Thiết kế 3PN rộng rãi, thích hợp cho gia đình đông thành viên hoặc nhóm chuyên gia.
Nội thất nhập khẩu phong cách hiện đại, tông màu ấm cúng.
Tiện ích cao cấp: Sân tennis, công viên nội khu, khu vui chơi trẻ em.
Giá thuê: 26 Triệu/tháng.
Liên hệ: 090x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MST-104', 'Masteri Thảo Điền', 'Cho thuê Duplex Masteri Thảo Điền thiết kế hiện đại, đầy đủ tiện nghi', 45000000, 130.0, 3, 3, '159 Xa Lộ Hà Nội', 'Phường Thảo Điền', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ DUPLEX MASTERI THẢO ĐIỀN THÔNG TẦNG DIỆN TÍCH 130M2
Địa chỉ: 159 Xa Lộ Hà Nội, Phường Thảo Điền, TP. Hồ Chí Minh
Căn Duplex thông tầng siêu rộng, trần cao thoáng đạt tạo cảm giác như biệt thự.
Trang bị hệ thống điều hòa âm trần, thiết bị bếp và vệ sinh chuẩn Châu Âu.
Tận hưởng không gian sống riêng tư, hiện đại ngay trung tâm Thảo Điền. 
Giá thuê: 45 Triệu/tháng.
Liên hệ: 090x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MTP-101', 'The Metropole Thủ Thiêm', 'Căn 1PN Galleria Metropole Thủ Thiêm full nội thất cao cấp', 25000000, 55.0, 1, 1, 'Khu đô thị mới Thủ Thiêm', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN THE METROPOLE THỦ THIÊM DIỆN TÍCH 55M2
Địa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh 
Căn hộ 1PN tại phân khu Galleria Residence, thiết kế tinh tế chuẩn phong cách Châu Âu.
Trang bị toàn bộ thiết bị nội thất thông minh tích hợp điều khiển giọng nói.
Ngay chân cầu Ba Sơn, kết nối sang trung tâm Bến Nghé chỉ 2 phút di chuyển.
Giá thuê: 25 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MTP-102', 'The Metropole Thủ Thiêm', 'Cho thuê căn 2PN The Crest Metropole view cầu Ba Sơn tuyệt đẹp', 38000000, 82.0, 2, 2, 'Khu đô thị mới Thủ Thiêm', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN THE CREST RESIDENCE METROPOLE DIỆN TÍCH 82M2
Địa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh
Căn hộ 2PN tầng trung ban công rộng view trực diện cầu Ba Sơn và tháp Bitexco.
Thiết kế sang trọng với thiết bị vệ sinh tự động, bếp từ Bosch cao cấp.
Tiện ích đỉnh cao: Hồ bơi vô cực tràn bờ, phòng tập Golf 3D giả lập.
Giá thuê: 38 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MTP-103', 'The Metropole Thủ Thiêm', 'Căn 3PN Opera Metropole Thủ Thiêm ban công rộng view sông', 60000000, 120.0, 3, 2, 'Khu đô thị mới Thủ Thiêm', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN THE OPERA RESIDENCE METROPOLE DIỆN TÍCH 120M2
Địa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh
Căn hộ thuộc phân khu Opera đắt giá nhất dự án, nằm sát Nhà hát Thành phố mới.
Ban công kính chạy dài view trực diện sông Sài Gòn lung linh về đêm.
Hệ thống lọc không khí và lọc nước trung tâm đạt chuẩn quốc tế.
Giá thuê: 60 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('MTP-104', 'The Metropole Thủ Thiêm', 'Căn 4PN VIP Metropole Thủ Thiêm thang máy riêng biệt xa hoa', 110000000, 170.0, 4, 4, 'Khu đô thị mới Thủ Thiêm', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 4PN VIP METROPOLE THỦ THIÊM THANG MÁY RIÊNG 170M2
Địa chỉ: Khu đô thị mới Thủ Thiêm, Phường Thủ Thiêm, TP. Hồ Chí Minh.
Căn hộ 4PN hạng sang trang bị sảnh thang máy riêng tư đi thẳng vào phòng khách.
Nội thất siêu xa hoa nhập khẩu nguyên chiếc từ Ý và Đức.
View sông ngắm toàn bộ skyline trung tâm thành phố.
Giá thuê: 110 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('PMC-101', 'Palm Heights / Palm City', 'Căn 1PN Palm Heights An Phú full nội thất xinh xắn', 14000000, 55.0, 1, 1, 'Đường Song Hành', 'Phường An Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN PALM HEIGHTS AN PHÚ DIỆN TÍCH 55M2
Địa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh
Căn hộ 1PN thiết kế thông minh, tối ưu diện tích đón gió tự nhiên từ sông Giồng Ông Tố.
Đầy đủ nội thất cao cấp: Sofa, tivi, tủ lạnh, bếp âm, giường tủ.
Quản lý vận hành bởi tập đoàn Keppel Land danh tiếng.
Giá thuê: 14 Triệu/tháng.
Liên hệ: 098x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('PMC-102', 'Palm Heights / Palm City', 'Căn 2PN Palm Heights view sông mát mẻ tầng cao', 18500000, 78.0, 2, 2, 'Đường Song Hành', 'Phường An Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN PALM HEIGHTS TẦNG CAO VIEW SÔNG 78M2
Địa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh
Ban công hướng Nam mát mẻ view sông trọn vẹn không bị che chắn.
Đã được trang bị full nội thất đẹp mắt, chỉ việc xách vali vào ở.
Tiện ích: Hồ bơi phong cách nghỉ dưỡng, phòng sauna, khu tiệc BBQ ngoài trời.
Giá thuê: 18.5 Triệu/tháng.
Liên hệ: 098x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('PMC-103', 'Palm Heights / Palm City', 'Căn góc 3PN Palm Heights diện tích rộng full đồ cao cấp', 25000000, 105.0, 3, 2, 'Đường Song Hành', 'Phường An Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN PALM HEIGHTS AN PHÚ DIỆN TÍCH 105M2
Địa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh
Căn góc 3 phòng ngủ thoáng đạt, các phòng ngủ đều có cửa sổ đón ánh sáng trực tiếp.
Nội thất thiết kế riêng hiện đại, trang bị đầy đủ máy giặt sấy, lò nướng.
Vị trí sát nút giao An Phú di chuyển thuận tiện về trung tâm.
Giá thuê: 25 Triệu/tháng.
Liên hệ: 098x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('PMC-104', 'Palm Heights / Palm City', 'Cho thuê căn Duplex Palm Garden không gian thoáng đãng', 42000000, 140.0, 3, 3, 'Đường Song Hành', 'Phường An Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ DUPLEX PALM GARDEN AN PHÚ DIỆN TÍCH 140M2
Địa chỉ: Đường Song Hành, Phường An Phú, TP. Hồ Chí Minh
Căn Duplex thông tầng siêu rộng rãi, không gian phòng khách trần cao cực kỳ sang trọng.
Trang bị hệ thống điện thông minh, nội thất chọn lọc cao cấp.
Tiện ích nội khu đầy đủ: Sân tennis, phòng tập gym, khu vui chơi trẻ em.
Giá thuê: 42 Triệu/tháng.
Liên hệ: 098x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SCV-101', 'Scenic Valley', 'Căn 2PN Scenic Valley Phú Mỹ Hưng full nội thất xinh xắn', 16000000, 70.0, 2, 2, 'Đường Tôn Dật Tiên', 'Phường Tân Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN SCENIC VALLEY PHÚ MỸ HƯNG 70M2
Địa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh
Căn hộ 2PN 2WC không gian thiết kế vuông vức, tối ưu hóa công năng.
Nội thất hiện đại đầy đủ: Tivi, tủ lạnh, máy giặt, máy lạnh các phòng.
Vị trí kế bên sân golf và bệnh viện FV, bệnh viện Tam Đức.
Giá thuê: 16 Triệu/tháng.
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SCV-102', 'Scenic Valley', 'Căn 2PN Scenic Valley view hồ bơi nội khu xanh mát', 18000000, 80.0, 2, 2, 'Đường Tôn Dật Tiên', 'Phường Tân Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN SCENIC VALLEY VIEW HỒ BƠI 80M2
Địa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh
Căn hộ tầng trung view trực diện hồ bơi ngoài trời xanh mát quanh năm.
Trang bị đồ dùng nội thất còn mới nguyên, xách vali vào ở ngay.
Cư dân tận hưởng trọn vẹn tiện ích đô thị Phú Mỹ Hưng.
Giá thuê: 18 Triệu/tháng.
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SCV-103', 'Scenic Valley', 'Căn 3PN Scenic Valley Phú Mỹ Hưng căn góc view sân Golf', 26000000, 110.0, 3, 2, 'Đường Tôn Dật Tiên', 'Phường Tân Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN SCENIC VALLEY VIEW SÂN GOLF 110M2
Địa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh
Căn góc 3PN tầm nhìn xanh ngút ngàn hướng thẳng ra sân Golf Phú Mỹ Hưng.
Thiết kế nội thất ấm cúng, phù hợp cho gia đình có trẻ nhỏ hoặc người già nghỉ dưỡng.
An ninh bảo vệ khép kín 24/7.
Giá thuê: 26 Triệu/tháng.
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SCV-104', 'Scenic Valley', 'Cho thuê căn 3PN Scenic Valley tầng cao thoáng mát full đồ', 28000000, 130.0, 3, 3, 'Đường Tôn Dật Tiên', 'Phường Tân Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN SCENIC VALLEY TẦNG CAO 130M2
Địa chỉ: Đường Tôn Dật Tiên, Phường Tân Phú, TP. Hồ Chí Minh
Căn 3PN diện tích lớn nhất dự án, ban công góc lộng gió cả ngày.
Trang bị đầy đủ nội thất gia đình cao cấp, tủ lạnh Side-by-side.
Hồ bơi trong nhà và hồ bơi ngoài trời sử dụng hoàn toàn miễn phí.
Giá thuê: 28 Triệu/tháng
Liên hệ: 092x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SRC-101', 'Sunrise City', 'Căn 1PN Sunrise City Central full nội thất đẹp giá tốt', 13000000, 56.0, 1, 1, '23 Brookside / Nguyễn Hữu Thọ', 'Phường Tân Hưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN SUNRISE CITY CENTRAL DIỆN TÍCH 56M2
Địa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh
Căn hộ 1PN khu Central đối diện siêu thị Lotte Mart Tân Hưng.
Đầy đủ nội thất sinh hoạt: Sofa, tivi, tủ lạnh, máy giặt, giường nệm.
Tiện ích: Hồ bơi tràn bờ, phòng gym, khu vui chơi trẻ em, nhà thuốc, ngân hàng.
Giá thuê: 13 Triệu/tháng.
Liên hệ: 098x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SRC-102', 'Sunrise City', 'Căn 2PN Sunrise City South tầng cao view trung tâm lộng lẫy', 17500000, 76.0, 2, 2, '23 Brookside / Nguyễn Hữu Thọ', 'Phường Tân Hưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN SUNRISE CITY SOUTH DIỆN TÍCH 76M2
Địa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh
Căn hộ 2PN khu South Towers chất lượng xây dựng kiên cố vượt trội.
Ban công hướng Bắc đón gió mát ngắm view thành phố lung linh.
Trang bị full đồ gỗ nội thất tự nhiên bền đẹp.
Giá thuê: 17.5 Triệu/tháng.
Liên hệ: 098x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SRC-103', 'Sunrise City', 'Căn góc 3PN Sunrise City North thiết kế rộng rãi thoáng mát', 23000000, 120.0, 3, 2, '23 Brookside / Nguyễn Hữu Thọ', 'Phường Tân Hưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN SUNRISE CITY NORTH 120M2
Địa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh
Căn góc 3 phòng ngủ thoáng mát, các không gian phòng đều ngập tràn ánh sáng.
Đã được trang bị full trang thiết bị đồ dùng gia đình.
Vị trí cửa ngõ Nam TP.HCM di chuyển sang trung tâm chỉ 10 phút.
Giá thuê: 23 Triệu/tháng.
Liên hệ: 098x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SRC-104', 'Sunrise City', 'Căn Penthouse Sunrise City South diện tích lớn view 360 độ', 55000000, 210.0, 4, 4, '23 Brookside / Nguyễn Hữu Thọ', 'Phường Tân Hưng', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE SUNRISE CITY SOUTH DIỆN TÍCH 210M2
Địa chỉ: 23 Brookside / Nguyễn Hữu Thọ, Phường Tân Hưng, TP. Hồ Chí Minh
Căn Penthouse không gian cực kỳ rộng rãi, ban công lớn ngắm toàn cảnh khu Nam Sài Gòn.
Trang bị nội thất sang trọng cổ điển cao cấp.
Thang máy bảo mật thẻ từ tầng riêng biệt.
Giá thuê: 55 Triệu/tháng.
Liên hệ: 098x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SSV-101', 'Serenity Sky Villas', 'Biệt thự trên không Serenity Sky Villas 2PN hồ bơi riêng 136m2', 90000000, 136.0, 2, 2, '259 Điện Biên Phủ', 'Phường Xuân Khánh', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
BIỆT THỰ TRÊN KHÔNG SIÊU SANG SERENITY SKY VILLAS DIỆN TÍCH 136M2
Địa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh
Biệt thự trên không độc bản chỉ có 45 căn duy nhất tại dự án.
Tích hợp hồ bơi riêng và sân vườn riêng ngay tại ban công từng căn hộ.
Chiều cao trần phòng khách thông tầng lên tới 7m, thiết kế siêu sang trọng.
Giá thuê: 90 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SSV-102', 'Serenity Sky Villas', 'Căn 3PN Serenity Sky Villas thông tầng trần cao 7m đẳng cấp', 120000000, 210.0, 3, 3, '259 Điện Biên Phủ', 'Phường Xuân Khánh', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
BIỆT THỰ TRÊN KHÔNG 3PN SERENITY SKY VILLAS 210M2
Địa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh
Căn hộ 3PN Duplex thiết kế đỉnh cao, hồ bơi riêng nước mặn ngoài ban công.
Bàn giao đầy đủ siêu nội thất nhập khẩu từ các thương hiệu xa xỉ nhất Châu Âu.
Thang máy nâng ô tô tận hộ và thang máy riêng vào nhà.
Giá thuê: 120 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SSV-103', 'Serenity Sky Villas', 'Căn 4PN Serenity Sky Villas không gian sống riêng tư tuyệt đối', 160000000, 330.0, 4, 4, '259 Điện Biên Phủ', 'Phường Xuân Khánh', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
SIÊU BIỆT THỰ TRÊN KHÔNG 4PN SERENITY SKY VILLAS 330M2
Địa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh
Căn biệt thự trên không 4PN diện tích cực đại 330m2.
Sân vườn xanh mát và hồ bơi vô cực riêng trải dài theo ban công căn hộ.
Khớp nối hoàn hảo giữa thiên nhiên và phong cách sống thượng lưu.
Giá thuê: 160 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SSV-104', 'Serenity Sky Villas', 'Penthouse Serenity Sky Villas kiệt tác thượng lưu số 1 Sài Gòn', 250000000, 500.0, 5, 5, '259 Điện Biên Phủ', 'Phường Xuân Khánh', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE SERENITY SKY VILLAS DIỆN TÍCH 500M2
Địa chỉ: 259 Điện Biên Phủ, Phường Xuân Khánh, TP. Hồ Chí Minh
Căn Penthouse độc bản đỉnh tháp Serenity Sky Villas, biểu tượng sống cao nhất của giới siêu giàu.
Hồ bơi riêng cực lớn, sân vườn riêng ôm trọn 4 mặt góc nhìn thành phố.
Dịch vụ quản gia concierge cá nhân hóa phục vụ 24/7.
Giá thuê: 250 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SWP-101', 'Sunwah Pearl', 'Căn 1PN Sunwah Pearl tháp White House full đồ siêu đẹp', 20000000, 56.0, 1, 1, '90 Nguyễn Hữu Cảnh', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN SUNWAH PEARL WHITE HOUSE DIỆN TÍCH 56M2
Địa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn hộ 1PN tháp White House thiết kế vuông vức, tông màu sáng hiện đại.
Bàn giao full trang thiết bị nội thất xịn, ban công hướng mát đón gió sông.
Vị trí đắc địa ngay chân cầu Thủ Thiêm, di chuyển sang trung tâm chỉ 3 phút.
Giá thuê: 20 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SWP-102', 'Sunwah Pearl', 'Cho thuê căn 2PN Sunwah Pearl tháp Silver House view sông cực phẩm', 30000000, 102.0, 2, 2, '90 Nguyễn Hữu Cảnh', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN SUNWAH PEARL SILVER HOUSE 102M2
Địa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn 2PN diện tích cực rộng 102m2, ban công góc view sông Sài Gòn và Bitexco đỉnh cao.
Thiết kế nội thất phong cách Châu Âu hiện đại sang trọng.
Tiện ích nội khu: Hồ bơi tràn bờ 1.000m2, công viên bến thuyền, phòng tập gym.
Giá thuê: 30 Triệu/tháng.\nLiên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SWP-103', 'Sunwah Pearl', 'Căn góc 3PN Sunwah Pearl tháp Golden House ngắm trọn Bason', 48000000, 128.0, 3, 2, '90 Nguyễn Hữu Cảnh', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN SUNWAH PEARL GOLDEN HOUSE 128M2
Địa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn góc đắt giá nhất tháp Golden House, các phòng ngủ đều ngắm trực diện sông.
Bếp kín hiện đại trang bị thiết bị Bosch âm tủ.
Cộng đồng cư dân cao cấp, an ninh bảo vệ khép kín 24/7.
Giá thuê: 48 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('SWP-104', 'Sunwah Pearl', 'Penthouse Sunwah Pearl tầm nhìn ôm trọn sông Sài Gòn', 110000000, 230.0, 4, 4, '90 Nguyễn Hữu Cảnh', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE SUNWAH PEARL TẦNG CAO DIỆN TÍCH 230M2
Địa chỉ: 90 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Siêu căn hộ Penthouse độc bản trên tầng cao nhất của dự án Sunwah Pearl.
Thiết kế hiện đại đẳng cấp, không gian sân vườn ban công siêu rộng ngắm toàn cảnh.
Trang bị sảnh thang máy riêng biệt bảo mật cao.
Giá thuê: 110 Triệu/tháng.
Liên hệ: 091x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TGC-101', 'The Global City', 'Căn 1PN Masteri Rise Mount The Global City thiết kế đẳng cấp', 18000000, 50.0, 1, 1, 'Đường Đỗ Xuân Hợp', 'Phường An Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN THE GLOBAL CITY DIỆN TÍCH 50M2
Địa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh
Căn hộ cao cấp nằm trong siêu đô thị biểu tượng do Foster & Partners thiết kế.
Thiết kế tối tân, ban công hướng Nam lộng gió ngắm kênh đào nhạc nước.
Đầy đủ tiện ích tiêu chuẩn quốc tế: TTTM 123.000m2, khu nhạc nước lớn nhất ĐNA.
Giá thuê: 18 Triệu/tháng.
Liên hệ: 096x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TGC-102', 'The Global City', 'Căn 2PN The Global City An Phú view kênh đào nhạc nước tuyệt đẹp', 27000000, 75.0, 2, 2, 'Đường Đỗ Xuân Hợp', 'Phường An Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN THE GLOBAL CITY AN PHÚ DIỆN TÍCH 75M2
Địa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh
Căn 2PN ban công cực rộng, không gian phòng khách hiện đại ngập tràn ánh sáng.
Nội thất nhập khẩu chuẩn Foster & Partners thiết kế riêng.
Cư dân tận hưởng trọn vẹn hạ tầng chuẩn Downtown mới của TP.HCM.
Giá thuê: 27 Triệu/tháng.
Liên hệ: 096x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TGC-103', 'The Global City', 'Căn góc 3PN The Global City thiết kế thông minh full tiện nghi', 38000000, 105.0, 3, 2, 'Đường Đỗ Xuân Hợp', 'Phường An Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN THE GLOBAL CITY DIỆN TÍCH 105M2
Địa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh
Căn góc 2 mặt thoáng view trọn khu nhà phố SOHO năng động và đường đua Go-kart.
Đầy đủ đồ dùng cao cấp, hệ thống thiết bị lọc khí thông minh.
Thuận tiện di chuyển qua cao tốc TP.HCM - Long Thành Dầu Giây.
Giá thuê: 38 Triệu/tháng.
Liên hệ: 096x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TGC-104', 'The Global City', 'Cho thuê Penthouse The Global City tầm nhìn biểu tượng vô tận', 85000000, 190.0, 4, 4, 'Đường Đỗ Xuân Hợp', 'Phường An Phú', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE THE GLOBAL CITY AN PHÚ DIỆN TÍCH 190M2
Địa chỉ: Đường Đỗ Xuân Hợp, Phường An Phú, TP. Hồ Chí Minh
Siêu phẩm Penthouse không gian thượng lưu, chiều cao trần phòng khách vượt trội.
Ban công kính vô cực ngắm trọn vẹn đại lộ mua sắm sầm uất.
Thang máy riêng, dịch vụ quản gia cao cấp riêng cho cư dân.
Giá thuê: 85 Triệu/tháng.
Liên hệ: 096x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TMQ-101', 'The Marq', 'Căn 1PN The Marq Nguyễn Đình Chiểu full nội thất hạng sang', 28000000, 52.0, 1, 1, '29B Nguyễn Đình Chiểu', 'Phường Đa Kao', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN THE MARQ NGUYỄN ĐÌNH CHIỂU 52M2
Địa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh
Căn hộ 1PN phân khu hạng sang trung tâm Đa Kao, trần cao 3.2m thoáng đạt.
Bàn giao sàn đá Cẩm Thạch (Marble) tự nhiên sang trọng.
Tiện ích tầng tầng mái The Sky Club: Hồ bơi vô cực 30m, Sky Bar, phòng Gym ngắm cảnh.
Giá thuê: 28 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TMQ-102', 'The Marq', 'Cho thuê căn 2PN The Marq Đa Kao view trung tâm thành phố', 40000000, 78.0, 2, 2, '29B Nguyễn Đình Chiểu', 'Phường Đa Kao', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN THE MARQ NGUYỄN ĐÌNH CHIỂU 78M2
Địa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh
Căn hộ 2PN thiết kế tối giản tinh tế theo phong cách Hongkong Land.
Trang bị đầy đủ nội thất nhập khẩu Châu Âu cao cấp, đồ dùng hiện đại.
Vị trí đắc địa gần các đại sứ quán và tòa nhà văn phòng hạng A.
Giá thuê: 40 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TMQ-103', 'The Marq', 'Căn 3PN The Marq sang trọng có sảnh thang máy riêng biệt', 65000000, 120.0, 3, 2, '29B Nguyễn Đình Chiểu', 'Phường Đa Kao', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN THE MARQ THANG MÁY RIÊNG 120M2
Địa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh
Căn 3PN sở hữu sảnh thang máy riêng biệt mở ra không gian sống đẳng cấp.
Bếp khô và bếp wet trang bị toàn bộ thiết bị Küppersbusch đỉnh cao.
Tầm nhìn ngắm toàn cảnh cây xanh mảng lớn trung tâm thành phố.
Giá thuê: 65 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TMQ-104', 'The Marq', 'Căn 4PN The Marq Đa Kao căn góc tầng cao cực đắt giá', 100000000, 146.0, 4, 3, '29B Nguyễn Đình Chiểu', 'Phường Đa Kao', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 4PN THE MARQ ĐA KAO DIỆN TÍCH 146M2
Địa chỉ: 29B Nguyễn Đình Chiểu, Phường Đa Kao, TP. Hồ Chí Minh
Căn góc 4PN xuất sắc nhất dự án The Marq với thiết kế trần cao và ban công kính lớn.
Trang bị sảnh thang máy riêng, nội thất đặt làm riêng thượng thượng thừa.
 An ninh bảo vệ nghiêm ngặt 24/24.
Giá thuê: 100 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TRV-101', 'The River Thủ Thiêm', 'Căn 1PN The River Thủ Thiêm full nội thất thiết kế hiện đại', 24000000, 57.0, 1, 1, 'Đại lộ Trống Đồng', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN THE RIVER THỦ THIÊM DIỆN TÍCH 57M2
Địa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh.
Căn hộ 1PN phân khu Seine Tower, thiết kế phong cách Châu Âu hiện đại.
Ban công hướng mát, nội thất nhập khẩu cao cấp đầy đủ tiện nghi.
Vị trí sát sông Sài Gòn, không khí xung quanh luôn trong lành thoáng mát.
Giá thuê: 24 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TRV-102', 'The River Thủ Thiêm', 'Căn 2PN The River Thủ Thiêm view trực diện sông lộng gió', 36000000, 84.0, 2, 2, 'Đại lộ Trống Đồng', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN THE RIVER THỦ THIÊM VIEW SÔNG 84M2
Địa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh
Thiết kế không gian mở tối đa không gian đón sáng, view sông trực diện đắt giá.
Trang bị đồ gỗ cao cấp, hệ thống điều hòa Daikin âm trần.
Tiện ích tiêu chuẩn 5 sao: Hồ bơi Olimpic 50m, phòng chiếu phim, xông hơi.
Giá thuê: 36 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TRV-103', 'The River Thủ Thiêm', 'Căn 3PN The River Thủ Thiêm thang máy riêng nội thất siêu sang', 62000000, 125.0, 3, 3, 'Đại lộ Trống Đồng', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN THE RIVER THỦ THIÊM THANG MÁY RIÊNG 125M2
Địa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh.
Căn hộ có sảnh thang máy riêng mang lại sự riêng tư riêng biệt cho gia chủ.
Bàn giao đầy đủ thiết bị bếp thương hiệu Miele (Đức).
Tầm nhìn ôm trọn công viên bờ sông và cầu Ba Sơn.
Giá thuê: 62 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('TRV-104', 'The River Thủ Thiêm', 'Căn Pool Villa The River Thủ Thiêm có hồ bơi riêng xa hoa', 130000000, 240.0, 4, 4, 'Đại lộ Trống Đồng', 'Phường Thủ Thiêm', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
POOL VILLA THE RIVER THỦ THIÊM HỒ BƠI RIÊNG 240M2
Địa chỉ: Đại lộ Trống Đồng, Phường Thủ Thiêm, TP. Hồ Chí Minh.
Siêu căn hộ Pool Villa sở hữu hồ bơi riêng ngoài ban công rộng lớn ngắm sông.
Thiết kế kiến trúc đỉnh cao, 4 phòng ngủ master trang bị phòng thay đồ riêng.
Dịch vụ quản lý tòa nhà chất lượng chuẩn quốc tế.\n- Giá thuê: 130 Triệu/tháng.
Liên hệ: 094x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VCP-101', 'Vinhomes Central Park', 'Căn 1PN Landmark 1 Vinhomes Central Park full nội thất cao cấp', 16500000, 54.0, 1, 1, '208 Nguyễn Hữu Cảnh', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN LANDMARK 1 VINHOMES CENTRAL PARK 54M2
Địa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn hộ 1PN tòa Landmark 1 ngay sát tháp Landmark 81 sầm uất.
Nội thất cao cấp hiện đại: Sofa da, tivi 55 inch, máy giặt sấy, tủ lạnh 2 cánh.
Bước vài bước chân ra công viên ven sông 14ha lộng gió.
Giá thuê: 16.5 Triệu/tháng.
Liên hệ: 090x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VCP-102', 'Vinhomes Central Park', 'Cho thuê căn 2PN Park 3 view trực diện công viên 14ha lộng gió', 23000000, 78.0, 2, 2, '208 Nguyễn Hữu Cảnh', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN PARK 3 VINHOMES CENTRAL PARK VIEW CÔNG VIÊN 78M2
Địa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn hộ 2PN 2WC tòa Park 3, ban công hướng Đông Nam ngắm trọn công viên ven sông 14ha.
Trang bị full nội thất nhập khẩu, nhà trống sẵn sàng bàn giao ngay.
Đầy đủ tiện ích: Bệnh viện Vinmec, trường Vinschool, bến du thuyền, TTTM.
Giá thuê: 23 Triệu/tháng.
Liên hệ: 090x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VCP-103', 'Vinhomes Central Park', 'Căn góc 3PN Central 2 Vinhomes Central Park nội thất nhập khẩu', 35000000, 115.0, 3, 2, '208 Nguyễn Hữu Cảnh', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN CENTRAL 2 VINHOMES CENTRAL PARK 115M2
Địa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Căn góc 3PN diện tích lớn, các phòng ngủ đều có cửa sổ lớn ngắm cảnh thành phố.
Trang bị dàn nội thất xịn xò nhập khẩu hoàn toàn từ Châu Âu.
Cư dân tận hưởng tiện ích hồ bơi, phòng gym, sân cờ ngoài trời hoàn toàn miễn phí.
Giá thuê: 35 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VCP-104', 'Vinhomes Central Park', 'Cho thuê căn 4PN Landmark 81 tầng cao view toàn cảnh thành phố', 70000000, 144.0, 4, 3, '208 Nguyễn Hữu Cảnh', 'Phường Thạnh Mỹ Tây', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 4PN LANDMARK 81 TẦNG CAO DIỆN TÍCH 144M2
Địa chỉ: 208 Nguyễn Hữu Cảnh, Phường Thạnh Mỹ Tây, TP. Hồ Chí Minh
Siêu căn hộ 4PN nằm trong tòa tháp cao nhất Việt Nam Landmark 81.
Tầm nhìn triệu đô ngắm toàn cảnh thành phố lung linh về đêm từ độ cao ấn tượng.
Dịch vụ quản gia, sảnh chờ VIP đẳng cấp hàng đầu.
Giá thuê: 70 Triệu/tháng.\nLiên hệ: 090x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VGP-101', 'Vinhomes Grand Park', 'Cho thuê căn Studio The Rainbow Vinhomes Grand Park full đồ', 6500000, 33.0, 1, 1, 'Đường Nguyễn Xiển', 'Phường Long Bình', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ STUDIO VINHOMES GRAND PARK DIỆN TÍCH 33M2
Địa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh
Căn hộ Studio nhỏ gọn thiết kế thông minh, tối ưu diện tích sử dụng.
Đầy đủ nội thất: Sofa, tủ lạnh, máy giặt, máy lạnh, bếp từ.
Miễn phí sử dụng công viên ánh sáng 36ha, biển nhân tạo, sân thể thao ngoài trời.
Giá thuê: 6.5 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VGP-102', 'Vinhomes Grand Park', 'Căn 2PN1WC The Origami Vinhomes Grand Park nội thất Nhật Bản', 9000000, 59.0, 2, 1, 'Đường Nguyễn Xiển', 'Phường Long Bình', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN1WC THE ORIGAMI VINHOMES GRAND PARK 59M2
Địa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh
Căn hộ phân khu The Origami phong cách chuẩn Nhật, view công viên vườn tùng.
Thiết kế 2PN xinh xắn, nội thất gỗ ấm cúng nhẹ nhàng.
Hệ thống xe bus điện VinBus đưa đón cư dân miễn phí kết nối trung tâm.
Giá thuê: 9 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VGP-103', 'Vinhomes Grand Park', 'Căn 2PN2WC Masteri Centre Point Vinhomes Grand Park cực sang', 14000000, 72.0, 2, 2, 'Đường Nguyễn Xiển', 'Phường Long Bình', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN2WC MASTERI CENTRE POINT GRAND PARK 72M2
Địa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh
Căn hộ thuộc phân khu compound cao cấp nhất đại đô thị Vinhomes Grand Park.
Bàn giao nội thất chuẩn cao cấp: Bếp Hafele, kính Kohler, hệ điều hòa âm trần.
Hồ bơi phi thuyền 2 tầng và sảnh đón sang trọng như khách sạn.
Giá thuê: 14 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VGP-104', 'Vinhomes Grand Park', 'Căn 3PN The Beverly Vinhomes Grand Park view trực diện công viên 36ha', 20000000, 100.0, 3, 2, 'Đường Nguyễn Xiển', 'Phường Long Bình', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 3PN THE BEVERLY VINHOMES GRAND PARK 100M2
Địa chỉ: Đường Nguyễn Xiển, Phường Long Bình, TP. Hồ Chí Minh
Căn hộ phân khu The Beverly đắt giá đối diện TTTM Vincom Mega Mall lớn nhất miền Nam.
Ban công trực diện công viên 36ha ngắm trọn biển hồ nhân tạo.
Trang bị toàn bộ thiết bị nội thất xịn xò nhập khẩu.
Giá thuê: 20 Triệu/tháng.
Liên hệ: 095x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VGR-101', 'Vinhomes Golden River (Ba Son)', 'Căn 1PN Aqua 1 Vinhomes Golden River full đồ sang trọng', 21000000, 50.0, 1, 1, '2 Tôn Đức Thắng', 'Phường Bến Nghé', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 1PN AQUA 1 VINHOMES GOLDEN RIVER 50M2
Địa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh
Căn hộ 1PN tòa Aqua 1 ngay trung tâm Bến Nghé, kính Low-E cản nhiệt phủ toàn bộ mặt ngoài.
Trang bị hệ thống Smarthome, thiết bị vệ sinh Duravit và thiết bị bếp Bosch.
Tầm nhìn view sông Sài Gòn và kênh Thị Nghè mát mẻ.
Giá thuê: 21 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VGR-102', 'Vinhomes Golden River (Ba Son)', 'Cho thuê căn 2PN Lux 6 Vinhomes Golden River view trực diện sông', 32000000, 78.0, 2, 2, '2 Tôn Đức Thắng', 'Phường Bến Nghé', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN HỘ 2PN LUX 6 VINHOMES GOLDEN RIVER VIEW SÔNG 78M2
Địa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh
Căn hộ 2PN tòa Luxury 6 đắt giá, ban công ngắm trực diện sông Sài Gòn và thảo cầm viên.
Nội thất hiện đại nhập khẩu full Option.
Tiện ích: Ga Metro Ba Son ngay nội khu, đường chạy bộ ven sông, bến du thuyền 5 sao.
Giá thuê: 32 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VGR-103', 'Vinhomes Golden River (Ba Son)', 'Căn góc 3PN Aqua 2 Vinhomes Golden River nội thất xa xỉ', 50000000, 110.0, 3, 2, '2 Tôn Đức Thắng', 'Phường Bến Nghé', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
CĂN GÓC 3PN AQUA 2 VINHOMES GOLDEN RIVER 110M2
Địa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh
Căn góc 3PN diện tích rộng, view ôm trọn cầu Ba Sơn và tháp Bitexco.
Đã chuẩn bị sẵn sàng toàn bộ trang thiết bị sinh hoạt cao cấp nhất.
Vị trí kim cương ngay trái tim trung tâm thành phố.
Giá thuê: 50 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
INSERT INTO rental_apartments (source_listing_code, building_name, title, monthly_rent, area, bedrooms, bathrooms, street_address, ward, city, description) VALUES ('VGR-104', 'Vinhomes Golden River (Ba Son)', 'Căn 4PN Penthouse Vinhomes Golden River đẳng cấp đỉnh cao', 95000000, 160.0, 4, 3, '2 Tôn Đức Thắng', 'Phường Bến Nghé', 'TP. Hồ Chí Minh', '=== MÔ TẢ CHI TIẾT ===
PENTHOUSE 4PN VINHOMES GOLDEN RIVER BA SON 160M2
Địa chỉ: 2 Tôn Đức Thắng, Phường Bến Nghé, TP. Hồ Chí Minh
Penthouse tầng cao tầm nhìn panorama không giới hạn ngắm toàn cảnh sông nước Sài Gòn.
Không gian sống riêng tư, thượng lưu dành cho các chủ nhân thành đạt.
An ninh bảo vệ 24/7 với hệ thống camera AI hiện đại.
Giá thuê: 95 Triệu/tháng.
Liên hệ: 093x.xxx.xxx') ON CONFLICT (source_listing_code) DO UPDATE SET building_name=EXCLUDED.building_name, title=EXCLUDED.title, monthly_rent=EXCLUDED.monthly_rent, area=EXCLUDED.area, bedrooms=EXCLUDED.bedrooms, bathrooms=EXCLUDED.bathrooms, street_address=EXCLUDED.street_address, ward=EXCLUDED.ward, city=EXCLUDED.city, description=EXCLUDED.description;
DELETE FROM rental_apartment_images WHERE rental_id IN (SELECT rental_id FROM rental_apartments WHERE source_listing_code IN ('LMN-102', 'ESH-102', 'EMP-101', 'EGR-103', 'ESH-103', 'MST-101', 'LMN-104', 'VCP-103', 'ESH-104', 'EGR-101', 'EGR-102', 'EMP-102', 'EGR-104', 'EMP-103', 'MTP-104', 'EMP-104', 'VCP-102', 'VCP-101', 'VCP-104', 'MTP-103', 'ESH-101', 'MTP-101', 'MTP-102', 'INF-102', 'LMN-103', 'LMN-101', 'MST-104', 'MST-103', 'MST-102', 'GMS-102', 'GMS-104', 'SRC-104', 'GMS-101', 'TMQ-104', 'GMS-103', 'INF-101', 'TMQ-101', 'SRC-103', 'SRC-102', 'TMQ-102', 'SRC-101', 'TMQ-103', 'INF-104', 'CTG-101', 'CTG-104', 'TGC-102', 'INF-103', 'CTG-102', 'CTG-103', 'TRV-104', 'DMI-103', 'DMI-102', 'DMI-101', 'DMI-104', 'TRV-102', 'SWP-103', 'GTW-103', 'SCV-102', 'SCV-101', 'PMC-102', 'SCV-103', 'SCV-104', 'PMC-101', 'TRV-103', 'TRV-101', 'PMC-103', 'SWP-102', 'TGC-104', 'TGC-103', 'SWP-104', 'TGC-101', 'SWP-101', 'GTW-101', 'GTW-102', 'GTW-104', 'PMC-104', 'VGP-104', 'VGP-102', 'SSV-102', 'SSV-101', 'VGP-101', 'MDT-102', 'VGR-104', 'VGP-103', 'SSV-104', 'MDT-101', 'MDT-103', 'MDT-104', 'VGR-103', 'SSV-103', 'VGR-101', 'HDC-101', 'HDC-103', 'HDC-104', 'VGR-102', 'HDC-102'));
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_22.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_01.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_08.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_28.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_18.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_13.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_22.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'CTG-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_03.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'DMI-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'DMI-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_21.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'DMI-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_18.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'DMI-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'DMI-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_30.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'DMI-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'DMI-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_14.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'DMI-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'DMI-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_21.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'EGR-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_25.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EGR-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_27.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'EGR-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_17.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EGR-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_20.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EGR-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_11.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'EGR-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EGR-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_06.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'EGR-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_23.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EGR-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_28.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_18.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_08.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_02.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_19.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_21.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_04.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_18.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'EMP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_13.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'ESH-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_26.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'ESH-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_09.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'ESH-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_12.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'ESH-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'ESH-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_24.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'ESH-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_28.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'ESH-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'ESH-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_05.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'ESH-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_11.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'GMS-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_10.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GMS-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'GMS-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_26.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GMS-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_13.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GMS-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_23.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'GMS-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_25.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GMS-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_06.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'GMS-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_23.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GMS-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_30.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_05.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_21.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_04.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_03.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_14.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'GTW-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_17.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'HDC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_20.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'HDC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_28.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'HDC-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_24.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'HDC-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_02.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'HDC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_01.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'HDC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_08.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'HDC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_11.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'HDC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_10.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'HDC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_19.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'INF-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'INF-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_17.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'INF-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_27.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'INF-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_20.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'INF-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_09.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'INF-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_12.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'INF-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_04.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'INF-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_21.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'INF-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_02.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_08.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_01.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_03.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_13.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_26.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_27.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_20.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_17.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'LMN-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_09.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MDT-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_12.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MDT-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MDT-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_14.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MDT-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MDT-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_30.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MDT-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MDT-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MDT-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_05.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MDT-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_23.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MST-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_06.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MST-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_24.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MST-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_28.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MST-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MST-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_22.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MST-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MST-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_11.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MST-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_10.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MST-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_25.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_04.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_21.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_19.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_14.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_22.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'MTP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_28.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'PMC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_24.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'PMC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'PMC-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_05.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'PMC-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_23.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'PMC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_25.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'PMC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_06.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'PMC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_11.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'PMC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_10.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'PMC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SCV-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_19.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SCV-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SCV-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_30.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SCV-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SCV-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_08.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SCV-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_02.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SCV-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_12.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SCV-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_09.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SCV-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_26.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_13.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_03.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_20.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_27.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_01.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_08.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_02.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SRC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_28.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SSV-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_18.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SSV-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SSV-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_30.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SSV-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_25.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SSV-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_23.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SSV-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_06.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SSV-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_20.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SSV-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_17.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SSV-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_08.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SWP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_01.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SWP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SWP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_18.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SWP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_05.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SWP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_24.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SWP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_28.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SWP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_27.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'SWP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_20.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'SWP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_03.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_14.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_10.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_11.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_13.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_26.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_18.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_04.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_21.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TGC-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_19.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TMQ-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TMQ-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_09.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TMQ-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_12.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TMQ-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_22.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TMQ-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TMQ-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TMQ-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_06.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TMQ-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_23.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TMQ-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_03.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TRV-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TRV-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TRV-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TRV-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_22.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TRV-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_10.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TRV-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_11.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TRV-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_25.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'TRV-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_21.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'TRV-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_18.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_19.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_07.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_05.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_20.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_17.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_26.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_13.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VCP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_29.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VGP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_14.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGP-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_21.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VGP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_04.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGP-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_20.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VGP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_27.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_17.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGP-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_24.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VGP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_28.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGP-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_02.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VGR-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_08.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGR-101';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_15.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VGR-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_30.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGR-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_16.jpg', 3, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGR-102';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_08.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VGR-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_01.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGR-103';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_12.jpg', 1, 1, TRUE FROM rental_apartments WHERE source_listing_code = 'VGR-104';
INSERT INTO rental_apartment_images (rental_id,image_url,sort_order,is_thumbnail,is_illustrative) SELECT rental_id, 'images/rentals/rental_09.jpg', 2, 0, TRUE FROM rental_apartments WHERE source_listing_code = 'VGR-104';
COMMIT;
SELECT COUNT(*) AS imported_rentals FROM rental_apartments WHERE source_listing_code IN ('LMN-102', 'ESH-102', 'EMP-101', 'EGR-103', 'ESH-103', 'MST-101', 'LMN-104', 'VCP-103', 'ESH-104', 'EGR-101', 'EGR-102', 'EMP-102', 'EGR-104', 'EMP-103', 'MTP-104', 'EMP-104', 'VCP-102', 'VCP-101', 'VCP-104', 'MTP-103', 'ESH-101', 'MTP-101', 'MTP-102', 'INF-102', 'LMN-103', 'LMN-101', 'MST-104', 'MST-103', 'MST-102', 'GMS-102', 'GMS-104', 'SRC-104', 'GMS-101', 'TMQ-104', 'GMS-103', 'INF-101', 'TMQ-101', 'SRC-103', 'SRC-102', 'TMQ-102', 'SRC-101', 'TMQ-103', 'INF-104', 'CTG-101', 'CTG-104', 'TGC-102', 'INF-103', 'CTG-102', 'CTG-103', 'TRV-104', 'DMI-103', 'DMI-102', 'DMI-101', 'DMI-104', 'TRV-102', 'SWP-103', 'GTW-103', 'SCV-102', 'SCV-101', 'PMC-102', 'SCV-103', 'SCV-104', 'PMC-101', 'TRV-103', 'TRV-101', 'PMC-103', 'SWP-102', 'TGC-104', 'TGC-103', 'SWP-104', 'TGC-101', 'SWP-101', 'GTW-101', 'GTW-102', 'GTW-104', 'PMC-104', 'VGP-104', 'VGP-102', 'SSV-102', 'SSV-101', 'VGP-101', 'MDT-102', 'VGR-104', 'VGP-103', 'SSV-104', 'MDT-101', 'MDT-103', 'MDT-104', 'VGR-103', 'SSV-103', 'VGR-101', 'HDC-101', 'HDC-103', 'HDC-104', 'VGR-102', 'HDC-102');
SELECT COUNT(*) AS illustrative_images FROM rental_apartment_images WHERE image_url LIKE 'images/rentals/%';
SELECT r.source_listing_code,r.building_name,r.monthly_rent,COUNT(i.image_id) AS images FROM rental_apartments r LEFT JOIN rental_apartment_images i ON i.rental_id=r.rental_id GROUP BY r.rental_id ORDER BY r.source_listing_code LIMIT 12;


-- TICH HOP VAO BANG GOC
-- Migration: map existing 96 rental_apartments to core buildings/apartments/properties/property_images/listings.
-- Run AFTER 01_create_tables_pg.sql, 02_insert_data_pg.sql and 07_import_rental_apartments.sql.
-- Run against apartment_selling_test_v2 first. Idempotent for repeated runs.
BEGIN;

-- Explicitly distinguish rental prices (per month) from sale prices.
ALTER TABLE properties ADD COLUMN IF NOT EXISTS listing_type VARCHAR(10) NOT NULL DEFAULT 'SALE';
ALTER TABLE listings ADD COLUMN IF NOT EXISTS listing_type VARCHAR(10) NOT NULL DEFAULT 'SALE';
ALTER TABLE properties ADD COLUMN IF NOT EXISTS is_illustrative BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE properties DROP CONSTRAINT IF EXISTS ck_properties_listing_type;
ALTER TABLE properties ADD CONSTRAINT ck_properties_listing_type CHECK (listing_type IN ('SALE','RENT'));
ALTER TABLE listings DROP CONSTRAINT IF EXISTS ck_listings_listing_type;
ALTER TABLE listings ADD CONSTRAINT ck_listings_listing_type CHECK (listing_type IN ('SALE','RENT'));

-- Guard against missing rental source tables or absent owner accounts.
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='rental_apartments') THEN
   RAISE EXCEPTION 'Missing rental_apartments. Run 07_import_rental_apartments.sql first.';
 END IF;
 IF NOT EXISTS (SELECT 1 FROM owners) THEN
   RAISE EXCEPTION 'Missing owners. Run 02_insert_data_pg.sql first.';
 END IF;
END $$;

-- A building record is created for each new development. Unknown floor count uses
-- 1 only as a schema-required placeholder, NOT a verified building specification.
INSERT INTO buildings (building_code, building_name, address, ward, district, city,
                       total_floors, total_apartments, description, status)
SELECT 'RENT-' || upper(substr(md5(r.building_name),1,12)), r.building_name,
       COALESCE(NULLIF(max(r.street_address),''),'Chưa xác định'),
       max(r.ward), NULL, max(r.city), 1, 0,
       'Dữ liệu căn hộ cho thuê. Số tầng tòa nhà chưa được xác minh; 1 là giá trị kỹ thuật tạm thời.', 'ACTIVE'
FROM rental_apartments r
WHERE NOT EXISTS (SELECT 1 FROM buildings b WHERE lower(b.building_name)=lower(r.building_name))
GROUP BY r.building_name
ON CONFLICT (building_code) DO NOTHING;

-- Unit codes are the original source codes; floor 0 denotes unknown.
INSERT INTO apartments (building_id, apartment_code, floor_number, room_number,
                        area, bedrooms, bathrooms, legal_status, status)
SELECT b.building_id, r.source_listing_code, 0, NULL,
       r.area, r.bedrooms, r.bathrooms, 'PENDING', 'AVAILABLE'
FROM rental_apartments r
JOIN buildings b ON lower(b.building_name)=lower(r.building_name)
WHERE NOT EXISTS (
  SELECT 1 FROM apartments a WHERE a.building_id=b.building_id AND a.apartment_code=r.source_listing_code
)
ON CONFLICT (building_id, apartment_code) DO NOTHING;

-- Price is MONTHLY RENT for RENT rows, SALE PRICE for SALE rows.
INSERT INTO properties (apartment_id, title, price, price_per_m2, description, address,
                        status, listing_type, is_illustrative)
SELECT a.apartment_id, left(r.title,200), r.monthly_rent, NULL,
       r.description || E'\n[Ảnh minh họa; có thể được sử dụng cho nhiều căn hộ.]',
       r.street_address, 'AVAILABLE', 'RENT', TRUE
FROM rental_apartments r
JOIN buildings b ON lower(b.building_name)=lower(r.building_name)
JOIN apartments a ON a.building_id=b.building_id AND a.apartment_code=r.source_listing_code
ON CONFLICT (apartment_id) DO UPDATE
SET title=EXCLUDED.title, price=EXCLUDED.price, price_per_m2=NULL,
    description=EXCLUDED.description, address=EXCLUDED.address,
    listing_type='RENT', is_illustrative=TRUE;

-- Images in property_images follow the existing naming convention images/...
-- Refresh ONLY images for mapped rental properties; leave existing sale images untouched.
DELETE FROM property_images pi
USING properties p, apartments a, rental_apartments r
WHERE pi.property_id=p.property_id AND p.apartment_id=a.apartment_id
  AND a.apartment_code=r.source_listing_code AND p.listing_type='RENT';

INSERT INTO property_images (property_id, image_url, is_thumbnail)
SELECT p.property_id, ri.image_url, ri.is_thumbnail
FROM rental_apartments r
JOIN rental_apartment_images ri ON ri.rental_id=r.rental_id
JOIN apartments a ON a.apartment_code=r.source_listing_code
JOIN properties p ON p.apartment_id=a.apartment_id AND p.listing_type='RENT'
JOIN buildings b ON b.building_id=a.building_id AND lower(b.building_name)=lower(r.building_name)
ORDER BY r.source_listing_code, ri.sort_order;

-- Every rental is a regular listing, attached to an existing demo owner.
-- Ownership is a technical demo assignment, NOT proof of actual ownership.
INSERT INTO listings (listing_code, owner_id, property_id, listing_title, asking_price,
                      description, expiry_date, status, listing_type)
SELECT 'RENT-' || r.source_listing_code,
       (SELECT min(owner_id) FROM owners), p.property_id,
       left(r.title,200), r.monthly_rent,
       'Giá thuê theo tháng. Ảnh minh họa. Chủ sở hữu là tài khoản demo; chưa xác minh.',
       CURRENT_TIMESTAMP + interval '365 days', 'ACTIVE', 'RENT'
FROM rental_apartments r
JOIN buildings b ON lower(b.building_name)=lower(r.building_name)
JOIN apartments a ON a.building_id=b.building_id AND a.apartment_code=r.source_listing_code
JOIN properties p ON p.apartment_id=a.apartment_id AND p.listing_type='RENT'
ON CONFLICT (listing_code) DO UPDATE
SET property_id=EXCLUDED.property_id, listing_title=EXCLUDED.listing_title,
    asking_price=EXCLUDED.asking_price, description=EXCLUDED.description,
    listing_type='RENT';

COMMIT;

SELECT 'buildings' AS table_name, count(*) AS total FROM buildings
UNION ALL SELECT 'apartments', count(*) FROM apartments
UNION ALL SELECT 'properties', count(*) FROM properties
UNION ALL SELECT 'property_images', count(*) FROM property_images
UNION ALL SELECT 'listings', count(*) FROM listings;

SELECT l.listing_code, b.building_name, a.apartment_code,
       p.title, p.price AS monthly_rent, count(pi.image_id) AS images
FROM listings l JOIN properties p ON p.property_id=l.property_id
JOIN apartments a ON a.apartment_id=p.apartment_id
JOIN buildings b ON b.building_id=a.building_id
LEFT JOIN property_images pi ON pi.property_id=p.property_id
WHERE l.listing_type='RENT'
GROUP BY l.listing_code,b.building_name,a.apartment_code,p.title,p.price
ORDER BY l.listing_code LIMIT 12;
