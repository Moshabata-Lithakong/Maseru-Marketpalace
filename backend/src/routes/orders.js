const express = require('express');
const { protect, restrictTo } = require('../middleware/auth');
const {
  getAllOrders,
  getOrder,
  createOrder,
  updateOrderStatus,
  assignDriver,
  getUserOrders,
  getOrderStats,
} = require('../controllers/orderController');

const router = express.Router();

// Protect all routes after this middleware
router.use(protect);

// User-specific orders
router.get('/my-orders', getUserOrders); // For passengers
router.get('/vendor/my-orders', restrictTo('vendor'), getUserOrders);
router.get('/driver/available', restrictTo('taxi_driver'), getUserOrders);
router.get('/stats/stats', restrictTo('admin'), getOrderStats);

// Order management
router.route('/')
  .get(restrictTo('admin'), getAllOrders)
  .post(restrictTo('passenger'), createOrder);

router.route('/:id')
  .get(getOrder);

router.patch('/:id/status', updateOrderStatus);
router.patch('/:id/accept', restrictTo('taxi_driver'), updateOrderStatus);
router.patch('/:id/complete', restrictTo('taxi_driver'), updateOrderStatus);
router.patch('/:id/assign-driver', restrictTo('vendor', 'admin'), assignDriver);

module.exports = router;