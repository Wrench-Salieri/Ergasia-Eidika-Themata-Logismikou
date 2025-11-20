-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 20, 2025 at 03:03 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `car_eshop`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE accounts (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin','manager','payment_manager','customer') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`id`, `username`, `password`, `role`) VALUES
(1, 'admin', '$2a$12$N.YSKnQTfl5hIq9JmeTRHu/89KO7Q4zNLVQ.owr2YWXdDcMTbT0CC', 'admin'),
(2, 'manager1', '$2a$12$pXhaxibRiUkQXpSKiTrGBuWj3kCFqg0Nromos.XN2LRXFTxqCSQLC', 'manager'),
(3, 'payment1', '$2a$12$pXhaxibRiUkQXpSKiTrGBuWj3kCFqg0Nromos.XN2LRXFTxqCSQLC', 'payment_manager'),
(4, 'customer1', '$2a$12$pXhaxibRiUkQXpSKiTrGBuWj3kCFqg0Nromos.XN2LRXFTxqCSQLC', 'customer');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE customers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  account_id UNSIGNED INT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE employees (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  account_id UNSIGNED INT,
  name VARCHAR(100) NOT NULL,
  position VARCHAR(50),
  FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--
CREATE TABLE brands (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(25) NOT NULL UNIQUE,
  country VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `models`
--

CREATE TABLE models (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  brand_id INT UNSIGNED NOT NULL,
  name VARCHAR(25) NOT NULL,
  size ENUM('hatchback','sedan','coupe','suv','sport') DEFAULT 'hatchback',
  UNIQUE KEY ux_brand_model (brand_id, name, size),
  FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cars`
--

CREATE TABLE cars (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  model_id INT UNSIGNED NOT NULL,
  vin VARCHAR(17) UNIQUE,
  price DECIMAL(12,2) NOT NULL,
  mileage INT UNSIGNED DEFAULT 0,
  stock INT UNSIGNED DEFAULT 1,
  color ENUM('red','blue','green','black','white','silver','gray','yellow') DEFAULT 'black',
  status ENUM('available','sold','maintenance') DEFAULT 'available',
  transmission ENUM('manual','automatic') DEFAULT 'manual',
  fuel ENUM('diesel','petrol','hybrid','electric') DEFAULT 'diesel',
  make_year YEAR,
  description TEXT,
  FOREIGN KEY (model_id) REFERENCES models(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_price (price),
  INDEX idx_make_year (make_year),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table 'brands'
--

INSERT INTO `brands` (`id`, `name`, `country`) VALUES
(1, 'Ford', 'USA'),
(2, 'BMW', 'Germany'),
(3, 'Mazda', 'Japan');

--
-- Dumping data for table 'models'
--

INSERT INTO `models` (`id`, `brand_id`, `name`, `size`) VALUES
(1, 1, 'Focus', 'hatchback'),
(2, 1, 'Mustang', 'coupe'),
(3, 2, 'M3 E46', 'sedan'),
(4, 3, 'MX5', 'coupe');

--
-- Dumping data for table `cars`
--

INSERT INTO `cars` (`id`, `model_id`, `vin`, `price`, `mileage`, `stock`, `color`, `status`, `transmission`, `fuel`, `make_year`, `description`) VALUES
(1, 1, '1FAFP34N95W123456', 15000.00, 50000, 3, 'black', 'available', 'manual', 'diesel', 2007, 'Ford Focus MK2.'),
(2, 2, '1FAFP45X75W654321', 25000.00, 30000, 2, 'blue', 'available', 'automatic', 'petrol', 2015, 'Ford Mustang Shelby.'),
(3, 3, 'WBSBL93476JR12345', 35000.00, 40000, 1, 'silver', 'maintenance', 'manual', 'diesel', 2004, 'BMW M3 E46 with GTR Body Kit.'),
(4, 4, 'JM1NC2PF0F0123456', 20000.00, 25000, 4, 'red', 'sold', 'manual', 'petrol', 1999, 'Mazda Miata.');

--
-- Table structure for table `orders`
--

CREATE TABLE orders (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(64) NOT NULL UNIQUE,
  customer_id INT UNSIGNED NOT NULL,
  status ENUM('pending','processing','completed','cancelled','refunded') NOT NULL DEFAULT 'pending',
  total DECIMAL(12,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'EUR',
  payment_method VARCHAR(50),
  payment_status ENUM('unpaid','paid','failed','refunded') NOT NULL DEFAULT 'unpaid',
  shipping_address TEXT,
  note TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_customer_id (customer_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `order_items`
--

CREATE TABLE order_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id INT UNSIGNED NOT NULL,
  car_id INT UNSIGNED NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  line_total DECIMAL(14,2) AS (unit_price * quantity) STORED,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_order_id (order_id),
  INDEX idx_car_id (car_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

COMMIT;