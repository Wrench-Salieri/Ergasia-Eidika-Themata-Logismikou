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
  account_id INT UNSIGNED UNIQUE NOT NULL,
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
  account_id INT UNSIGNED UNIQUE NOT NULL,
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
  size ENUM('hatchback','sedan','coupe','suv','sport', 'wagon') DEFAULT 'hatchback',
  UNIQUE KEY ux_brand_model (brand_id, name, size),
  FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cars`
--

CREATE TABLE cars (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  model_id INT UNSIGNED NOT NULL,
  vin VARCHAR(17) UNIQUE NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  mileage INT UNSIGNED DEFAULT 0,
  stock INT UNSIGNED DEFAULT 1,
  color ENUM('red','blue','green','black','white','silver','gray','yellow', 'orange', 'brown') DEFAULT 'black',
  status ENUM('available','sold','maintenance') DEFAULT 'available',
  transmission ENUM('manual','automatic') DEFAULT 'manual',
  fuel ENUM('diesel','petrol','hybrid','electric') DEFAULT 'diesel',
  make_year YEAR,
  description TEXT,
  FOREIGN KEY (model_id) REFERENCES models(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_price (price),
  INDEX idx_make_year (make_year),
  INDEX idx_ssstatus (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `car_photos`
--

CREATE TABLE car_photos (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  car_id INT UNSIGNED NOT NULL,
  photo_url VARCHAR(255) NOT NULL,
  alt_text VARCHAR(100),
  is_primary BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_car_id (car_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table 'brands'
--

INSERT INTO `brands` (`id`, `name`, `country`) VALUES
(1, 'Ford', 'USA'),
(2, 'BMW', 'Germany'),
(3, 'Mazda', 'Japan'),
(4, 'Chery', 'China'),
(5, 'Volkswagen', 'Germany'),
(6, 'Nissan', 'Japan'),
(7, 'Audi', 'Germany'),
(8, 'Lexus', 'Japan'),
(9, 'Dacia', 'Romania'),
(10, 'Subaru', 'Japan'),
(11, 'Cupra', 'Spain'),
(12, 'Hyundai', 'South Korea'),
(13, 'Peugeot', 'Fra*ce'),
(14,'Mercedes-Benz', 'Germany'),
(15, 'Volvo', 'Sweden'),
(16, 'NIO', 'China'),
(17, 'Changan', 'China'),
(18, 'Zeekr', 'China'),
(19, 'MG', 'UK'),
(20, 'Kia', 'South Korea'),
(21, 'Bentley', 'UK'),
(22, 'Opel', 'Germany'),
(23, 'Chevrolet', 'USA');

--
-- Dumping data for table 'models'
--

INSERT INTO `models` (`id`, `brand_id`, `name`, `size`) VALUES
(1, 1, 'Focus', 'hatchback'),
(2, 1, 'Mustang', 'coupe'),
(3, 2, 'M3 E46', 'sedan'),
(4, 3, 'MX5', 'coupe'),
(5, 4, 'TIGGO 4', 'suv'),
(6, 5, 'Tayron', 'suv'),
(7, 6, 'Qashqai', 'suv'),
(8, 7, 'S5 Avant', 'wagon'),
(9, 8, 'UX', 'suv'),
(10, 9, 'Duster', 'suv'),
(11, 10, 'Crosstrek', 'suv'),
(12, 10, 'Impreza', 'sedan'),
(13, 2, 'M5', 'sedan'),
(14, 11, 'Leon', 'hatchback'),
(15, 12, 'i30 5d', 'hatchback'),
(16, 13, '208', 'hatchback'),
(17, 14, 'GLC Coupe', 'coupe'),
(18, 15, 'XC60', 'suv'),
(19, 8, 'LS', 'sedan'),
(20, 16, 'Firefly', 'suv'),
(21, 17, 'Deepal S07', 'suv'),
(22, 18, '7X', 'suv'),
(23, 7, 'S6 Sportback e-tron', 'sedan'),
(24, 19, 'Cyberster', 'coupe'),
(25, 20, 'EV3', 'suv'),
(26, 11, 'Tavascan', 'suv'),
(27, 10, 'Solterra', 'suv'),
(28, 7, 'A3', 'hatchback'),
(29, 13, '308', 'hatchback'),
(30, 2, '318', 'sedan'),
(31, 2, '118', 'sedan'),
(32, 14, 'G 63 AMG', 'suv'),
(33, 21, 'Continental GT', 'sedan'),
(34, 6, 'GT-R', 'coupe'),
(35, 14, 'A 45 AMG', 'hatchback'),
(36, 7, 'S3', 'hatchback'),
(37, 22, 'Mokka', 'suv'),
(38, 5, 'T-Cross', 'suv'),
(39, 23, 'Camaro', 'coupe');



--
-- Dumping data for table `cars`
--

INSERT INTO `cars` (`id`, `model_id`, `vin`, `price`, `mileage`, `color`, `status`, `transmission`, `fuel`, `make_year`, `description`) VALUES
(1, 1, '1FAFP34N95W123456', 15000.00, 50000, 'black', 'available', 'manual', 'diesel', 2007, 'Ford Focus MK2.'),
(2, 2, '1FAFP45X75W654321', 25000.00, 30000, 'blue', 'available', 'manual', 'petrol', 2015, 'Ford Mustang Shelby.'),
(3, 3, 'WBSBL93476JR12345', 35000.00, 40000, 'silver', 'maintenance', 'manual', 'diesel', 2004, 'BMW M3 E46 with GTR Body Kit.'),
(4, 4, 'JM1NC2PF0F0123456', 20000.00, 25000, 'red', 'sold', 'manual', 'petrol', 1999, 'Mazda Miata.'),
(5, 5, '2GNALAEK7E6137910', 30000.00, 50000, 'gray', 'maintenance', 'automatic', 'hybrid', 2025, 'Temp'),
(6, 6, '2G2WR524751101680', 40000.00, 50000, 'white', 'available', 'automatic', 'hybrid', 2024, 'Temp'),
(7, 7, '3FADP0L39BR104403', 45000.00, 50000, 'gray', 'sold', 'automatic', 'hybrid', 2025, 'Temp'),
(8, 8, 'JNKCV54E43M250919', 88950.00, 50000, 'gray', 'sold', 'automatic', 'hybrid', 2025, 'Temp'),
(9, 9, 'JTHBJ46G172063090', 32846.00, 50000, 'blue', 'maintenance', 'automatic', 'hybrid', 2025, 'Temp'),
(10, 10, 'JN8AS5MT7AW018367', 25150.00, 50000, 'gray', 'available', 'automatic', 'hybrid', 2025, 'Temp'),
(11, 11, '2G1WB5E36E1147772', 21800.00, 50000, 'orange', 'maintenance', 'automatic', 'hybrid', 2013, 'Temp'),
(12, 12, 'JN8AE2KP4B9016216', 36000.00, 50000, 'blue', 'sold', 'manual', 'diesel', 2009, 'Temp'),
(13, 13, '2G1WW12E629197622', 120000.00, 50000, 'blue', 'available', 'automatic', 'hybrid', 2024, 'Temp'),
(14, 14, '1GNKRGKDXEJ289730', 47000.00, 50000, 'gray', 'maintenance', 'automatic', 'hybrid', 2024, 'Temp'),
(15, 15, '4T1BF1FKXFU890462', 18000.00, 50000, 'gray', 'sold', 'automatic', 'hybrid', 2021, 'Temp'),
(16, 16, '1GNSCAE09DR264907', 27000.00, 50000, 'green', 'sold', 'automatic', 'hybrid', 2024, 'Temp'),
(17, 17, '1G6EL12Y6YB739298', 40000.00, 50000, 'white', 'available', 'automatic', 'hybrid', 2023, 'Temp'),
(18, 18, '2C4RC1BG6DR723636', 55000.00, 50000, 'gray', 'available', 'automatic', 'hybrid', 2020, 'Temp'),
(19, 19, '1FMCU93GX9KC20693', 107600.00, 50000, 'gray', 'available', 'automatic', 'hybrid', 2025, 'Temp'),
(20, 20, '1GYS3GEF4BR108166', 31900.00, 50000, 'silver', 'available', 'automatic', 'electric', 2026, 'Temp'),
(21, 21, 'JM1BL1L72C1621365', 44900.00, 50000, 'orange', 'available', 'automatic', 'electric', 2025, 'Temp'),
(22, 22, '3D7TP2CTXAG157919', 55000.00, 50000, 'gray', 'available', 'automatic', 'electric', 2025, 'Temp'),
(23, 23, 'JA3AP47H1RY038613', 104000.00, 50000, 'green', 'available', 'automatic', 'electric', 2025, 'Temp'),
(24, 24, '1GCHC29D67E161932', 77000.00, 50000, 'red', 'available', 'automatic', 'electric', 2024, 'Temp'),
(25, 25, '1FTRW08L51KA41024', 44000.00, 50000, 'white', 'available', 'automatic', 'electric', 2024, 'Temp'),
(26, 26, '1FTFW1ET5EFB86544', 49000.00, 50000, 'silver', 'available', 'automatic', 'electric', 2024, 'Temp'),
(27, 27, '1FTYR14V7XPB06760', 47000.00, 50000, 'silver', 'available', 'automatic', 'electric', 2023, 'Temp'),
(28, 28, 'JN8AS5MT0DW500473', 15000.00, 50000, 'silver', 'available', 'automatic', 'diesel', 2016, 'Temp'),
(29, 29, '1G11B5SLXEF140816', 15000.00, 50000, 'brown', 'available', 'automatic', 'diesel', 2018, 'Temp'),
(30, 30, '1G1PA5SG5E7219367', 19000.00, 50000, 'white', 'available', 'automatic', 'diesel', 2016, 'Temp'),
(31, 31, '1GCEC14X28Z242421', 8000.00, 50000, 'white', 'available', 'automatic', 'diesel', 2007, 'Temp'),
(32, 32, '5YFBU4EE5DP115648', 550000.00, 50000, 'white', 'available', 'manual', 'diesel', 2023, 'Temp'),
(33, 33, 'JKBVNAP112A004380', 277000.00, 50000, 'silver', 'available', 'automatic', 'diesel', 2021, 'Temp'),
(34, 34, '1FAHP2F88DG123068', 23000.00, 50000, 'blue', 'available', 'manual', 'diesel', 2017, 'Temp'),
(35, 35, '1N4BA41E87C890916', 37000.00, 50000, 'yellow', 'available', 'manual', 'diesel', 2016, 'Temp'),
(36, 36, '1FM5K8D88FGB61934', 36000.00, 50000, 'red', 'available', 'automatic', 'diesel', 2015, 'Temp'),
(37, 37, 'JM1BL1VG0B1438994', 36000.00, 50000, 'black', 'available', 'automatic', 'diesel', 2025, 'Temp'),
(38, 28, '5FNYF4H52CB007675', 26000.00, 50000, 'blue', 'available', 'automatic', 'diesel', 2024, 'Temp'),
(39, 39, '5NPDH4AEXFH526773', 29900.00, 50000, 'yellow', 'available', 'manual', 'petrol', 2010, 'Chevrolet Camaro Bumblebee edition');

--
-- Dumping data for table `car_photos`
--

INSERT INTO `car_photos` (`car_id`, `photo_url`, `alt_text`, `is_primary`) VALUES
(1, '/images/cars/focus.jpg', 'temp', TRUE),
(2, '/images/cars/mustang.jpg', 'temp', TRUE),
(3, '/images/cars/m3e46.jpg', 'temp', TRUE),
(4, '/images/cars/mx5.jpg', 'temp', TRUE),
(5, '/images/cars/tiggo4.jpg', 'temp', TRUE),
(6, '/images/cars/tayron.jpg', 'temp', TRUE),
(7, '/images/cars/qashqai.jpg', 'temp', TRUE),
(8, '/images/cars/s5avant.jpg', 'temp', TRUE),
(9, '/images/cars/ux.jpg', 'temp', TRUE),
(10, '/images/cars/duster.jpg', 'temp', TRUE),
(11, '/images/cars/crosstrek.jpg', 'temp', TRUE),
(12, '/images/cars/impreza.jpg', 'temp', TRUE),
(13, '/images/cars/m5.jpg', 'temp', TRUE),
(14, '/images/cars/leon.jpg', 'temp', TRUE),
(15, '/images/cars/i30.jpg', 'temp', TRUE),
(16, '/images/cars/208.jpg', 'temp', TRUE),
(17, '/images/cars/glccoupe.jpg', 'temp', TRUE),
(18, '/images/cars/xc60.jpg', 'temp', TRUE),
(19, '/images/cars/ls.jpg', 'temp', TRUE),
(20, '/images/cars/firefly.jpg', 'temp', TRUE),
(21, '/images/cars/deepals07.jpg', 'temp', TRUE),
(22, '/images/cars/7x.jpg', 'temp', TRUE),
(23, '/images/cars/s6etron.jpg', 'temp', TRUE),
(24, '/images/cars/cyberster.jpg', 'temp', TRUE),
(25, '/images/cars/ev3.jpg', 'temp', TRUE),
(26, '/images/cars/tavascan.jpg', 'temp', TRUE),
(27, '/images/cars/solterra.jpg', 'temp', TRUE),
(28, '/images/cars/a3.jpg', 'temp', TRUE),
(29, '/images/cars/308.jpg', 'temp', TRUE),
(30, '/images/cars/318.jpg', 'temp', TRUE),
(31, '/images/cars/118.jpg', 'temp', TRUE),
(32, '/images/cars/g63.jpg', 'temp', TRUE),
(33, '/images/cars/continentalgt.jpg', 'temp', TRUE),
(34, '/images/cars/gtr.jpg', 'temp', TRUE),
(35, '/images/cars/a45.jpg', 'temp', TRUE),
(36, '/images/cars/s3.jpg', 'temp', TRUE),
(37, '/images/cars/mokka.jpg', 'temp', TRUE),
(38, '/images/cars/tcross.jpg', 'temp', TRUE),
(39, '/images/cars/camaro.jpg', 'temp', TRUE);

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