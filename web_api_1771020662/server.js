// FILE: web_api_1771020662/server.js

const express = require('express');
const { Sequelize, DataTypes } = require('sequelize');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors()); 
app.use(bodyParser.json());

// --- KẾT NỐI DATABASE ---
const sequelize = new Sequelize('db_exam_1771020662', 'root', '', {
    host: 'localhost',
    dialect: 'mysql',
    logging: false
});

// --- MODELS ---
const Customer = sequelize.define('customer', {
    email: { type: DataTypes.STRING, unique: true, allowNull: false },
    password: { type: DataTypes.STRING, allowNull: false },
    full_name: { type: DataTypes.STRING, allowNull: false },
    phone_number: { type: DataTypes.STRING }, 
    loyalty_points: { type: DataTypes.INTEGER, defaultValue: 0 }
});

const MenuItem = sequelize.define('menu_item', {
    name: { type: DataTypes.STRING, allowNull: false },
    description: DataTypes.TEXT,
    category: { type: DataTypes.STRING }, 
    price: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    image_url: DataTypes.STRING,
    is_available: { type: DataTypes.BOOLEAN, defaultValue: true }
});

// (Các bảng khác giữ nguyên hoặc khai báo tối giản để chạy menu)
const Reservation = sequelize.define('reservation', { status: DataTypes.STRING });
Customer.hasMany(Reservation); Reservation.belongsTo(Customer);

// --- API ROUTES ---

app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await Customer.findOne({ where: { email } });
        if (!user || user.password !== password) return res.status(401).json({ message: "Sai thông tin" });
        res.json({ token: "token", user, student_id: "1771020662" });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/menu-items', async (req, res) => {
    const items = await MenuItem.findAll();
    res.json(items);
});

// --- API SEED DATA (ĐÃ SỬA LỖI VALIDATION ERROR) ---
app.get('/api/seed-data', async (req, res) => {
    try {
        // 1. Tạo User (Dùng findOrCreate để không bị lỗi nếu đã có)
        await Customer.findOrCreate({
            where: { email: 'a@gmail.com' },
            defaults: { 
                password: '123', 
                full_name: 'Nguyen Van A',
                phone_number: '0909123456'
            }
        });

        // 2. Tạo Menu (Kiểm tra nếu chưa có thì mới tạo)
        const menuCount = await MenuItem.count();
        if (menuCount === 0) {
            await MenuItem.bulkCreate([
                { name: 'Phở Bò', price: 50000, category: 'Main Course', description: 'Phở tái nạm' },
                { name: 'Bún Chả', price: 45000, category: 'Main Course', description: 'Hà Nội phố' },
                { name: 'Trà Đá', price: 5000, category: 'Beverage', description: 'Giải khát' },
                { name: 'Cơm Tấm', price: 60000, category: 'Main Course', description: 'Sài Gòn' }
            ]);
        }
        
        res.send("Đã nạp dữ liệu thành công! (Dù chạy nhiều lần cũng không lỗi)");
    } catch (e) { 
        res.send("Lỗi chi tiết: " + e.message); 
    }
});

// --- CHẠY SERVER ---
const PORT = 3000;
// force: false để giữ dữ liệu an toàn
sequelize.sync({ force: false }).then(() => {
    console.log("Server ready!");
    app.listen(PORT, () => console.log(`Run at http://localhost:${PORT}`));
});