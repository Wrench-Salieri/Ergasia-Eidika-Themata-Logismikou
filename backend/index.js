const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { Sequelize, DataTypes } = require('sequelize');

// Initialize Express app
const app = express();
app.use(cors());
app.use(express.json());

// Set up Sequelize (ORM) connection to MariaDB
const sequelize = new Sequelize('car_eshop', 'root', '', {
  host: 'localhost',
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

// Define a User model for authentication example
const User = sequelize.define('User', {
  username: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  }
});

// Sync models with the database (create tables if not exist)
sequelize.sync()
  .then(() => console.log('User model synced with database'))
  .catch(err => console.log('Error syncing models:', err));

// ----------------- START SERVER -----------------
const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
