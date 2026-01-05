require('dotenv').config();
const path = require('path');
const express = require('express');
const mariadb = require('mariadb');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { Sequelize, DataTypes } = require('sequelize');

// Initialize Express app
const app = express();
app.use(cors());
app.use(express.json());
app.use('/images', express.static(path.join(__dirname, 'images')));


// Set up Sequelize (ORM) connection to MariaDB
const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  dialect: 'mariadb',
  logging: false, // Disable SQL logging
});

// Test the database connection
sequelize.authenticate()
  .then(() => {
    console.log('Connection to MariaDB has been established successfully.');
  })
  .catch(err => {
    console.error('Unable to connect to the database:', err);
  });

// Define an account model
const Account = sequelize.define('Account', {
  username: { type: DataTypes.STRING(50), allowNull: false, unique: true },
  password: { type: DataTypes.STRING(255), allowNull: false },
  role: { type: DataTypes.ENUM('admin','manager','payment_manager','customer'), allowNull: false }
}, { tableName: 'accounts', timestamps: false });

// Define the customer account type
const Customer = sequelize.define('Customer', {
  account_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false, unique: true },
  name: { type: DataTypes.STRING(100), allowNull: false },
  email: { type: DataTypes.STRING(100), allowNull: false, unique: true },
}, { tableName: 'customers', timestamps: false });

// Define the employee account type
const Employee = sequelize.define('Employee', {
  account_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false, unique: true },
  name: { type: DataTypes.STRING(100), allowNull: false },
  position: { type: DataTypes.STRING(50), allowNull: true },
}, { tableName: 'employees', timestamps: false });

// Define brands of cars
const Brand = sequelize.define('Brand', {
  name: { type: DataTypes.STRING(50), allowNull: false, unique: true },
  country: { type: DataTypes.STRING(50), allowNull: false },
}, { tableName: 'brands', timestamps: false });

// Define models of cars
const Model = sequelize.define('CarModel', {
  brand_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  name: { type: DataTypes.STRING(25), allowNull: false },
  size: { type: DataTypes.ENUM('hatchback','sedan','coupe','suv','sport','wagon'), allowNull: false, defaultValue: 'hatchback' },
}, { tableName: 'models', timestamps: false, indexes: [{name: 'ux_brand_model', unique: true, fields: ['brand_id', 'name', 'size']}] });

// Define cars
const Car = sequelize.define('Car', {
  model_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  vin: { type: DataTypes.STRING(17), allowNull: false, unique: true },
  price: { type: DataTypes.DECIMAL(10,2), allowNull: false },
  mileage: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  color: { type: DataTypes.ENUM('red','blue','green','black','white','silver','gray','yellow', 'orange', 'brown'), allowNull: false },
  status: { type: DataTypes.ENUM('available','sold','maintenance'), allowNull: false, defaultValue: 'available' },
  transmission: { type: DataTypes.ENUM('manual','automatic'), allowNull: false },
  fuel: { type: DataTypes.ENUM('petrol','diesel','electric','hybrid'), allowNull: false },
  make_year: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
}, { tableName: 'cars', timestamps: false });

// Define car photos
const CarPhoto = sequelize.define('CarPhoto', {
  car_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  photo_url: { type: DataTypes.STRING(255), allowNull: false },
  alt_text: { type: DataTypes.STRING(100), allowNull: true },
  is_primary: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: false },
}, { tableName: 'car_photos', timestamps: false });

// Define orders
const Order = sequelize.define('Order', {
  customer_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  car_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  order_date: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
  status: { type: DataTypes.ENUM('pending','completed','canceled'), allowNull: false, defaultValue: 'pending' },
}, { tableName: 'orders', timestamps: false });

// Define order payments
const OrderPayment = sequelize.define('OrderPayment', {
  order_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  amount: { type: DataTypes.DECIMAL(10,2), allowNull: false },
  payment_date: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
  payment_method: { type: DataTypes.ENUM('credit_card','debit_card','paypal','bank_transfer'), allowNull: false },
}, { tableName: 'order_items', timestamps: false });

// Define relationships
// Account
Account.hasOne(Customer, { foreignKey: 'account_id' });
Customer.belongsTo(Account, { foreignKey: 'account_id' });

Account.hasOne(Employee, { foreignKey: 'account_id' });
Employee.belongsTo(Account, { foreignKey: 'account_id' });

// Brand / Model
Brand.hasMany(Model, { foreignKey: 'brand_id' });
Model.belongsTo(Brand, { foreignKey: 'brand_id' });

// Model / Car
Model.hasMany(Car, { foreignKey: 'model_id' });
Car.belongsTo(Model, { foreignKey: 'model_id' });

// Car / CarPhoto
Car.hasMany(CarPhoto, { foreignKey: 'car_id' });
CarPhoto.belongsTo(Car, { foreignKey: 'car_id' });

// Customer / Order
Customer.hasMany(Order, { foreignKey: 'customer_id' });
Order.belongsTo(Customer, { foreignKey: 'customer_id' });

// Car / Order
Car.hasMany(Order, { foreignKey: 'car_id' });
Order.belongsTo(Car, { foreignKey: 'car_id' });

// Order / Payment
Order.hasOne(OrderPayment, { foreignKey: 'order_id' });
OrderPayment.belongsTo(Order, { foreignKey: 'order_id' });



// Sync models with the database (create tables if not exist)
sequelize.sync()
  .then(() => console.log('User model synced with database'))
  .catch(err => console.log('Error syncing models:', err));

// ----- AUTH -----
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return res.status(400).json({ error: 'Username & password required' });

  try {
    const user = await Account.findOne({ where: { username } });
    if (!user) return res.status(401).json({ error: 'Invalid credentials' });

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) return res.status(401).json({ error: 'Invalid credentials' });

    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.json({ token, role: user.role, userId: user.id, username: user.username });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// ----- CAR ----- //
app.get('/cars', async (req, res) => {
  try {
    const cars = await Car.findAll({
      where: { status: 'available' },
      include: [
        {
          model: Model,
          attributes: ['name'],
          include: [
            {
              model: Brand,
              attributes: ['name']
            }
          ]
        },
        {
          model: CarPhoto,
          attributes: ['photo_url', 'is_primary']
        }
      ]
    });

    const formattedCars = cars.map(car => ({
      id: car.id,
      vin: car.vin,
      price: car.price,
      mileage: car.mileage,
      color: car.color,
      status: car.status,
      transmission: car.transmission,
      fuel: car.fuel,
      make_year: car.make_year,

      brand: car.Model?.Brand?.name || null,
      model: car.Model?.name || null,
      image: car.CarPhotos.find(p => p.is_primary)
        ? `http://localhost:3001${car.CarPhotos.find(p => p.is_primary).photo_url}`
        : null
    }));

    res.json(formattedCars);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Could not fetch cars' });
  }
});



// ----------------- START SERVER -----------------
const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
