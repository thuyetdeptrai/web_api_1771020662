const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(cors()); // Fix lỗi kết nối Web/App
app.use(express.json());

// --- 1. KẾT NỐI DATABASE ---
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'db_exam_1771020662', // Đảm bảo đúng tên DB của bạn
    dateStrings: true
});

db.connect(err => {
    if (err) console.error('❌ Lỗi kết nối DB:', err);
    else console.log('✅ Đã kết nối MySQL thành công!');
});

// --- 2. MIDDLEWARE CHECK ADMIN ---
const requireAdmin = (req, res, next) => {
    const userId = req.headers['user-id']; 
    if (!userId) return res.status(401).json({ message: 'Chưa đăng nhập (Thiếu user-id)' });

    db.query('SELECT role FROM customers WHERE id = ?', [userId], (err, results) => {
        if (err || results.length === 0) return res.status(401).json({ message: 'User không tồn tại' });
        if (results[0].role === 'admin') {
            next();
        } else {
            res.status(403).json({ message: '⛔ Cấm truy cập: Chỉ dành cho Admin' });
        }
    });
};

// ============================================
//                 API ROUTES
// ============================================

// --- AUTH (ĐĂNG KÝ / ĐĂNG NHẬP) ---
app.post('/api/auth/register', (req, res) => {
    const { email, password, full_name, phone_number, address } = req.body;
    const sql = `INSERT INTO customers (email, password, full_name, phone_number, address, role, loyalty_points) VALUES (?, ?, ?, ?, ?, 'customer', 0)`;
    db.query(sql, [email, password, full_name, phone_number, address], (err, result) => {
        if (err) return res.status(500).json(err);
        res.status(201).json({ message: 'Đăng ký thành công' });
    });
});

app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;
    db.query('SELECT * FROM customers WHERE email = ? AND password = ?', [email, password], (err, results) => {
        if (err || results.length === 0) return res.status(401).json({ message: 'Sai email hoặc mật khẩu' });
        
        const user = results[0];
        delete user.password;
        
        res.json({
            token: 'fake-jwt-token-' + user.id,
            user: user,
            student_id: '1771020662'
        });
    });
});

// --- QUẢN LÝ KHÁCH HÀNG ---
app.get('/api/customers/:id', (req, res) => {
    db.query('SELECT * FROM customers WHERE id = ?', [req.params.id], (err, results) => {
        if (err) return res.status(500).json(err);
        if (results.length === 0) return res.status(404).json({ message: 'User not found' });
        const user = results[0];
        delete user.password;
        res.json(user);
    });
});

app.put('/api/customers/:id', (req, res) => {
    const { full_name, phone_number, address } = req.body;
    db.query('UPDATE customers SET full_name = ?, phone_number = ?, address = ? WHERE id = ?', 
    [full_name, phone_number, address, req.params.id], (err) => {
        if (err) return res.status(500).json(err);
        res.json({ message: 'Cập nhật thành công' });
    });
});

// --- QUẢN LÝ MENU ---
app.get('/api/menu-items', (req, res) => {
    let sql = 'SELECT * FROM menu_items WHERE 1=1';
    if (req.query.search) sql += ` AND name LIKE '%${req.query.search}%'`;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

app.post('/api/menu-items', requireAdmin, (req, res) => {
    const { name, description, category, price, preparation_time, image_url } = req.body;
    const sql = `INSERT INTO menu_items (name, description, category, price, preparation_time, image_url) VALUES (?, ?, ?, ?, ?, ?)`;
    db.query(sql, [name, description, category, price, preparation_time, image_url], (err, result) => {
        if (err) return res.status(500).json(err);
        res.json({ message: 'Thêm món thành công', id: result.insertId });
    });
});

app.delete('/api/menu-items/:id', requireAdmin, (req, res) => {
    db.query('DELETE FROM menu_items WHERE id = ?', [req.params.id], (err) => {
        if (err) return res.status(500).json(err);
        res.json({ message: 'Đã xóa món ăn' });
    });
});

// --- QUẢN LÝ BÀN ---
app.get('/api/tables', requireAdmin, (req, res) => {
    let sql = 'SELECT * FROM tables';
    if (req.query.available_only === 'true') sql += ' WHERE is_available = 1';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

app.post('/api/tables', requireAdmin, (req, res) => {
    const { table_number, capacity } = req.body;
    db.query('INSERT INTO tables (table_number, capacity) VALUES (?, ?)', [table_number, capacity], (err) => {
        if (err) return res.status(500).json(err);
        res.json({ message: 'Thêm bàn thành công' });
    });
});

// --- QUẢN LÝ ĐẶT BÀN (RESERVATIONS) ---

// 1. Tạo đơn (Khách)
app.post('/api/reservations', (req, res) => {
    const { customer_id, reservation_date, number_of_guests, special_requests } = req.body;
    const resNumber = 'RES-' + Date.now();
    // Default status: pending, payment_status: unpaid
    const sql = `INSERT INTO reservations (customer_id, reservation_number, reservation_date, number_of_guests, special_requests, status, payment_status) VALUES (?, ?, ?, ?, ?, 'pending', 'unpaid')`;
    
    db.query(sql, [customer_id, resNumber, reservation_date, number_of_guests, special_requests], (err, result) => {
        if (err) return res.status(500).json(err);
        res.json({ message: 'Đặt bàn thành công', id: result.insertId });
    });
});

// 2. Thêm món vào đơn & Tự động tính tiền
app.post('/api/reservations/:id/items', (req, res) => {
    const reservationId = req.params.id;
    const { menu_item_id, quantity } = req.body;

    db.query('SELECT price FROM menu_items WHERE id = ?', [menu_item_id], (err, items) => {
        if (err || items.length === 0) return res.status(404).json({ message: 'Món không tồn tại' });
        const price = items[0].price;

        db.query('INSERT INTO reservation_items (reservation_id, menu_item_id, quantity, price_at_time) VALUES (?, ?, ?, ?)', 
        [reservationId, menu_item_id, quantity, price], (err) => {
            if (err) return res.status(500).json(err);

            // Tính lại tổng tiền
            const sqlSum = 'SELECT SUM(quantity * price_at_time) as subtotal FROM reservation_items WHERE reservation_id = ?';
            db.query(sqlSum, [reservationId], (err, result) => {
                const subtotal = result[0].subtotal || 0;
                const service = subtotal * 0.1;
                const total = subtotal + service;

                db.query('UPDATE reservations SET subtotal=?, service_charge=?, total=? WHERE id=?', [subtotal, service, total, reservationId], (err) => {
                    res.json({ message: 'Đã thêm món', total: total });
                });
            });
        });
    });
});

// 3. Xác nhận đơn (Admin duyệt bàn)
app.put('/api/reservations/:id/confirm', requireAdmin, (req, res) => {
    const { table_id } = req.body;
    db.query('SELECT is_available FROM tables WHERE id = ?', [table_id], (err, tables) => {
        if (err || tables.length === 0 || tables[0].is_available == 0) return res.status(400).json({ message: 'Bàn không trống hoặc không tồn tại' });
        
        db.query("UPDATE reservations SET status = 'confirmed', table_id = ? WHERE id = ?", [table_id, req.params.id], (err) => {
            if (err) return res.status(500).json(err);
            db.query('UPDATE tables SET is_available = 0 WHERE id = ?', [table_id]);
            res.json({ message: 'Đã xác nhận bàn!' });
        });
    });
});

// 4. Hủy đơn
app.delete('/api/reservations/:id', (req, res) => {
    const reservationId = req.params.id;
    
    db.query('SELECT * FROM reservations WHERE id = ?', [reservationId], (err, results) => {
        if (err || results.length === 0) return res.status(404).json({ message: 'Đơn không tồn tại' });

        const sql = "UPDATE reservations SET status = 'cancelled' WHERE id = ?";
        db.query(sql, [reservationId], (err) => {
            if (err) return res.status(500).json(err);
            
            if (results[0].table_id) {
                db.query('UPDATE tables SET is_available = 1 WHERE id = ?', [results[0].table_id]);
            }
            res.json({ message: 'Đã hủy đơn thành công' });
        });
    });
});
// 5. THANH TOÁN (PAYMENT - FIX LỖI CRASH DO NULL)
app.post('/api/reservations/:id/pay', (req, res) => {
    const reservationId = req.params.id;
    const { use_loyalty_points } = req.body;

    console.log(`>>> Đang xử lý thanh toán cho đơn: ${reservationId}`);

    // 1. Lấy thông tin đơn hàng
    const sqlGet = `SELECT r.*, c.loyalty_points 
                    FROM reservations r 
                    JOIN customers c ON r.customer_id = c.id 
                    WHERE r.id = ?`;

    db.query(sqlGet, [reservationId], (err, results) => {
        if (err) {
            console.error("Lỗi SQL Get:", err);
            return res.status(500).json(err);
        }
        if (results.length === 0) return res.status(404).json({ message: 'Đơn không tồn tại' });

        const order = results[0];

        // 2. Xử lý an toàn dữ liệu (Tránh lỗi NaN)
        let totalAmount = parseFloat(order.total);
        if (isNaN(totalAmount)) {
            // Nếu đơn cũ chưa có tổng tiền, gán tạm = 0 để không bị lỗi
            console.log("⚠️ Cảnh báo: Đơn hàng này chưa có tổng tiền (NULL). Gán tạm = 0.");
            totalAmount = 0; 
        }

        let currentPoints = parseInt(order.loyalty_points);
        if (isNaN(currentPoints)) currentPoints = 0;

        let pointsToUse = 0;
        let discountAmount = 0;

        // 3. Tính toán giảm giá
        if (use_loyalty_points === true && currentPoints > 0 && totalAmount > 0) {
            const maxDiscount = totalAmount * 0.5; // Tối đa 50%
            const pointValue = currentPoints * 1000;

            if (pointValue >= maxDiscount) {
                discountAmount = maxDiscount;
                pointsToUse = Math.floor(maxDiscount / 1000);
            } else {
                discountAmount = pointValue;
                pointsToUse = currentPoints;
            }
        }

        const finalTotal = totalAmount - discountAmount;
        const pointsEarned = Math.floor(finalTotal * 0.01); // Tích 1%
        const newPointBalance = currentPoints - pointsToUse + pointsEarned;

        console.log(`   - Tổng gốc: ${totalAmount}`);
        console.log(`   - Giảm giá: ${discountAmount}`);
        console.log(`   - Còn lại: ${finalTotal}`);
        console.log(`   - Điểm mới: ${newPointBalance}`);

        // 4. Cập nhật vào DB
        // Lưu ý: Dùng dấu ? chuẩn để tránh lỗi SQL Injection
        const sqlUpdate = `UPDATE reservations SET status = 'completed', payment_status = 'paid', total = ? WHERE id = ?`;
        
        db.query(sqlUpdate, [finalTotal, reservationId], (err) => {
            if (err) {
                console.error("❌ Lỗi Update Reservation:", err);
                return res.status(500).json({message: "Lỗi update đơn hàng", error: err});
            }

            // Cập nhật điểm khách
            db.query('UPDATE customers SET loyalty_points = ? WHERE id = ?', [newPointBalance, order.customer_id], (err) => {
                 if (err) console.error("❌ Lỗi Update Points:", err);
            });

            // Trả bàn trống
            if (order.table_id) {
                db.query('UPDATE tables SET is_available = 1 WHERE id = ?', [order.table_id]);
            }

            console.log("✅ Thanh toán thành công!");
            res.json({ 
                message: 'Thanh toán thành công',
                discount: discountAmount,
                final_total: finalTotal,
                new_balance: newPointBalance
            });
        });
    });
});

// 6. Lấy Lịch sử đặt bàn (Kèm món ăn)
app.get('/api/customers/:id/reservations', (req, res) => {
    // 1. Lấy đơn hàng
    const sql = `SELECT r.*, t.table_number 
                 FROM reservations r 
                 LEFT JOIN tables t ON r.table_id = t.id 
                 WHERE customer_id = ? 
                 ORDER BY created_at DESC`;
                 
    db.query(sql, [req.params.id], (err, reservations) => {
        if (err) return res.status(500).json(err);
        if (reservations.length === 0) return res.json([]); 

        // 2. Lấy món ăn
        const reservationIds = reservations.map(r => r.id);
        const sqlItems = `SELECT ri.*, m.name, m.image_url 
                          FROM reservation_items ri 
                          JOIN menu_items m ON ri.menu_item_id = m.id 
                          WHERE ri.reservation_id IN (?)`;

        db.query(sqlItems, [reservationIds], (err, items) => {
            if (err) return res.status(500).json(err); // Nếu lỗi SQL ở đây thì trả về mảng rỗng (đề phòng chưa có món)
            
            // 3. Ghép món vào đơn
            const result = reservations.map(r => {
                return {
                    ...r,
                    items: items ? items.filter(item => item.reservation_id === r.id) : []
                };
            });
            res.json(result);
        });
    });
});

// 7. Admin xem tất cả đơn
app.get('/api/admin/reservations', requireAdmin, (req, res) => {
    const sql = `SELECT r.*, c.full_name FROM reservations r JOIN customers c ON r.customer_id = c.id ORDER BY r.created_at DESC`;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

// --- START SERVER ---
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`✅ Server đang chạy tại: http://localhost:${PORT}`);
});