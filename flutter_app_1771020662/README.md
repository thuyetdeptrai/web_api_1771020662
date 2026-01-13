🍽️ HỆ THỐNG QUẢN LÝ NHÀ HÀNG (Restaurant Management System)
Mã Sinh Viên: 1771020662

Công nghệ: Node.js (Express), MySQL, Flutter.

📋 1. YÊU CẦU HỆ THỐNG (PREREQUISITES)
Để chạy được dự án, máy tính cần cài đặt:

Node.js (v14 trở lên).

Flutter SDK (v3.0 trở lên).

XAMPP/WAMP/MySQL Workbench (Để chạy Database MySQL).

Postman (Để Admin quản lý hệ thống).

Trình duyệt Web (Chrome/Edge) hoặc Android Emulator.

⚙️ 2. CÀI ĐẶT & CHẠY DỰ ÁN
🗄️ Bước 1: Cấu hình Database
Mở phpMyAdmin (thường là http://localhost/phpmyadmin).

Tạo cơ sở dữ liệu mới tên: db_exam_1771020662.

Import file .sql (được đính kèm trong source code) vào database này.

Lưu ý: Đảm bảo tài khoản Admin mặc định đã có trong bảng customers:

Email: admin@nhahang.com

Password: 123 (hoặc mật khẩu bạn đã tạo)

Role: admin

🚀 Bước 2: Chạy Backend (Server API)
Mở Terminal (CMD/VS Code), trỏ vào thư mục web_api_1771020662.

Cài đặt thư viện:

Bash

npm install
Chạy server:

Bash

node server.js
✅ Nếu thành công sẽ báo: Server đang chạy tại: http://localhost:3000

📱 Bước 3: Chạy Frontend (Flutter App)
Mở thư mục flutter_app_1771020662 bằng VS Code.

Mở file lib/constants.dart, kiểm tra địa chỉ IP:

Nếu chạy Web: static const String baseUrl = 'http://localhost:3000/api';

Nếu chạy Máy ảo Android: static const String baseUrl = 'http://10.0.2.2:3000/api';

Chạy lệnh:

Bash

flutter pub get
flutter run -d chrome  # Hoặc chọn thiết bị giả lập
👨‍💻 3. HƯỚNG DẪN SỬ DỤNG CHO ADMIN (VIA POSTMAN)
Do ứng dụng Flutter chỉ dành cho Khách hàng, Admin sẽ sử dụng Postman để quản lý (Thêm món, Duyệt bàn, Thêm bàn...).

🔑 QUY TẮC QUAN TRỌNG
Hầu hết các API của Admin đều yêu cầu xác thực quyền. Bạn cần gửi kèm Header sau trong mỗi request Postman:

Key: user-id

Value: [2] (Lấy ID này sau khi đăng nhập tài khoản admin).

🛠️ CÁC THAO TÁC ADMIN THƯỜNG DÙNG
1. Đăng nhập (Để lấy ID Admin)
Method: POST

URL: http://localhost:3000/api/auth/login

Body (JSON):

JSON

{
    "email": "admin@nhahang.com",
    "password": "123"
}
💡 Kết quả: Copy lại id của user trả về để dùng cho các bước sau.

2. Duyệt Đơn Đặt Bàn (Gán bàn cho khách)
Đây là bước quan trọng nhất để khách có thể gọi món.

Method: PUT

URL: http://localhost:3000/api/reservations/:id/confirm

(Thay :id bằng ID của đơn đặt bàn cần duyệt)

Headers:

user-id: 1 (Ví dụ ID admin là 1)

Body (JSON):

JSON

{
    "table_id": 1
}
(Gán đơn này vào bàn số 1)

3. Thêm Món Ăn Mới (Vào Menu)
Method: POST

URL: http://localhost:3000/api/menu-items

Headers: user-id: 1

Body (JSON):

JSON

{
    "name": "Bún Bò Huế",
    "description": "Đặc sản Huế cay nồng",
    "category": "Món nước",
    "price": 55000,
    "preparation_time": 15,
    "image_url": "https://example.com/bunbo.jpg"
}
4. Xem Tất Cả Đơn Đặt Bàn (Để quản lý)
Method: GET

URL: http://localhost:3000/api/admin/reservations

Headers: user-id: 1

5. Thêm Bàn Mới
Method: POST

URL: http://localhost:3000/api/tables

Headers: user-id: 1

Body (JSON):

JSON

{
    "table_number": "T10",
    "capacity": 6
}
📱 4. HƯỚNG DẪN SỬ DỤNG APP (KHÁCH HÀNG)
Khách hàng sử dụng App Flutter với các chức năng trọn gói:

Đăng ký/Đăng nhập: Tạo tài khoản mới hoặc đăng nhập.

Đặt Bàn: Chọn ngày, giờ, số người -> Bấm xác nhận.

Gọi Món:

Sau khi đặt bàn, hệ thống tự động gợi ý gọi món.

Hoặc vào Lịch Sử, bấm nút "Gọi món".

Hệ thống tự động tính tổng tiền (Giá món + 10% VAT).

Quản lý Đơn:

Xem trạng thái đơn (Đang chờ, Đã duyệt...).

Hủy đơn: Chỉ hủy được khi chưa ăn.

Thanh toán: Bấm nút thanh toán để hoàn tất đơn hàng.

Cập nhật thông tin: Trong menu hồ sơ cá nhân.

📬 Liên hệ
Sinh viên thực hiện: ...