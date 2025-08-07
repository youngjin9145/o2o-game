-- 서귀포 투자 게임 - 투자 상품 시드 데이터

-- 제주 유네스코 세계유산 (직접투자)
INSERT INTO investment_products (code, name, name_en, description, category, type, sub_type, base_price, current_price, icon, location, is_unesco_heritage, unesco_category, min_investment) VALUES

-- 🌋 세계자연유산 (3,000~5,000만원)
('HALLASAN', '한라산 천연보호구역', 'Hallasan Natural Reserve', '제주도의 상징이자 남한 최고봉인 한라산 천연보호구역', 'direct', 'unesco_heritage', 'natural_heritage', 50000000, 50000000, '🏔️', '제주시/서귀포시', true, 'natural', 1000000),
('SEONGSAN', '성산일출봉', 'Seongsan Ilchulbong', '제주 대표 관광명소이자 일출 명소', 'direct', 'unesco_heritage', 'natural_heritage', 40000000, 40000000, '🌅', '서귀포시 성산읍', true, 'natural', 1000000),
('GEOMUNOREUM', '거문오름 용암동굴계', 'Geomunoreum Lava Tube System', '세계에서 가장 긴 용암동굴 중 하나', 'direct', 'unesco_heritage', 'natural_heritage', 45000000, 45000000, '🕳️', '제주시 조천읍', true, 'natural', 1000000),

-- 🌍 세계지질공원 (1,500~3,000만원)
('MANJANGGUL', '만장굴', 'Manjanggul Cave', '세계 최장의 용암동굴', 'direct', 'unesco_heritage', 'geopark', 25000000, 25000000, '🌊', '제주시 구좌읍', true, 'geopark', 500000),
('CHEONJIYEON', '천지연폭포', 'Cheonjiyeon Falls', '제주 3대 폭포 중 하나', 'direct', 'unesco_heritage', 'geopark', 20000000, 20000000, '💧', '서귀포시', true, 'geopark', 500000),
('JUSANGJEOLLI', '중문 대포해안 주상절리대', 'Daepo Jusangjeolli Cliff', '화산활동으로 형성된 주상절리', 'direct', 'unesco_heritage', 'geopark', 22000000, 22000000, '🗿', '서귀포시 중문동', true, 'geopark', 500000),
('SEOGWIPO_LAYER', '서귀포층', 'Seogwipo Formation', '제주 지질사의 보고', 'direct', 'unesco_heritage', 'geopark', 18000000, 18000000, '🏜️', '서귀포시', true, 'geopark', 500000),
('SANBANGSAN', '산방산과 용머리해안', 'Sanbangsan & Yongmeori Coast', '종상화산과 해안절벽', 'direct', 'unesco_heritage', 'geopark', 23000000, 23000000, '⛰️', '서귀포시 안덕면', true, 'geopark', 500000),
('SUWOLBONG', '수월봉', 'Suwolbong Peak', '응회환과 화산쇄설층의 보고', 'direct', 'unesco_heritage', 'geopark', 15000000, 15000000, '🌋', '제주시 한경면', true, 'geopark', 500000),

-- 🌿 생물권보전지역 (800~1,500만원)
('GOTJAWAL', '곶자왈', 'Gotjawal Forest', '제주만의 독특한 원시림', 'direct', 'unesco_heritage', 'biosphere', 12000000, 12000000, '🌳', '제주 전역', true, 'biosphere', 300000),
('HALLASAN_OREUMS', '한라산 오름군', 'Hallasan Oreums', '한라산 주변의 기생화산들', 'direct', 'unesco_heritage', 'biosphere', 15000000, 15000000, '🏔️', '제주 전역', true, 'biosphere', 300000),
('CHUJADO', '추자도', 'Chuja Island', '제주 북쪽의 아름다운 섬', 'direct', 'unesco_heritage', 'biosphere', 8000000, 8000000, '🏝️', '제주시 추자면', true, 'biosphere', 300000);

-- 일반 투자 상품 (간접투자)
INSERT INTO investment_products (code, name, name_en, description, category, type, base_price, current_price, icon, min_investment) VALUES

-- 📈 주식 (100만원~1,000만원)
('AAPL', 'Apple Inc.', 'Apple Inc.', '미국 기술기업 애플', 'indirect', 'stock', 3000000, 3000000, '🍎', 100000),
('GOOGL', 'Alphabet Inc.', 'Alphabet Inc.', '구글 모회사 알파벳', 'indirect', 'stock', 4500000, 4500000, '🔍', 100000),
('TSLA', 'Tesla Inc.', 'Tesla Inc.', '전기차 선도기업 테슬라', 'indirect', 'stock', 2800000, 2800000, '⚡', 100000),
('MSFT', 'Microsoft Corp.', 'Microsoft Corp.', '소프트웨어 거대기업 마이크로소프트', 'indirect', 'stock', 3500000, 3500000, '💻', 100000),
('AMZN', 'Amazon.com Inc.', 'Amazon.com Inc.', '전자상거래 거대기업 아마존', 'indirect', 'stock', 3200000, 3200000, '📦', 100000),

-- 📊 ETF (200만원~800만원)
('SPY', 'SPDR S&P 500 ETF', 'SPDR S&P 500 ETF', 'S&P 500 지수 추종 ETF', 'indirect', 'etf', 5000000, 5000000, '📊', 200000),
('VTI', 'Vanguard Total Stock Market ETF', 'Vanguard Total Stock Market ETF', '미국 전체 주식시장 ETF', 'indirect', 'etf', 4200000, 4200000, '📈', 200000),
('QQQ', 'Invesco QQQ Trust', 'Invesco QQQ Trust', '나스닥 100 지수 ETF', 'indirect', 'etf', 3800000, 3800000, '💹', 200000),

-- 💰 채권 (500만원~2,000만원)
('KTB_3Y', '한국국고채 3년', 'Korea Treasury Bond 3Y', '한국 정부 발행 3년 만기 국채', 'indirect', 'bond', 10000000, 10000000, '🇰🇷', 500000),
('USB_10Y', '미국국채 10년', 'US Treasury Bond 10Y', '미국 정부 발행 10년 만기 국채', 'indirect', 'bond', 15000000, 15000000, '🇺🇸', 500000),

-- ₿ 가상자산 (100만원~1,500만원)
('BTC', 'Bitcoin', 'Bitcoin', '세계 최초 암호화폐 비트코인', 'indirect', 'crypto', 80000000, 80000000, '₿', 100000),
('ETH', 'Ethereum', 'Ethereum', '스마트 컨트랙트 플랫폼 이더리움', 'indirect', 'crypto', 4000000, 4000000, '⟠', 100000),
('ADA', 'Cardano', 'Cardano', '지속가능한 블록체인 카르다노', 'indirect', 'crypto', 800000, 800000, '🔷', 100000);