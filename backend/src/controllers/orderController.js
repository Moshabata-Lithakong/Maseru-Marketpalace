const Order = require('../models/Order');
const Product = require('../models/Product');
const AppError = require('../utils/appError');
const catchAsync = require('../utils/catchAsync');
const APIFeatures = require('../utils/apiFeatures');

exports.getAllOrders = catchAsync(async (req, res, next) => {
  const features = new APIFeatures(Order.find(), req.query)
    .filter()
    .sort()
    .limitFields()
    .paginate();

  const orders = await features.query
    .populate('passengerId', 'profile')
    .populate('vendorId', 'profile vendorInfo')
    .populate('taxiDriverId', 'profile taxiDriverInfo');

  res.status(200).json({
    status: 'success',
    results: orders.length,
    data: {
      orders,
    },
  });
});

exports.getOrder = catchAsync(async (req, res, next) => {
  const order = await Order.findById(req.params.id)
    .populate('passengerId', 'profile')
    .populate('vendorId', 'profile vendorInfo')
    .populate('taxiDriverId', 'profile taxiDriverInfo')
    .populate('items.productId');

  if (!order) {
    return next(new AppError('No order found with that ID', 404));
  }

  // Check if user is authorized to view this order
  if (
    req.user.role !== 'admin' &&
    order.passengerId._id.toString() !== req.user.id &&
    order.vendorId._id.toString() !== req.user.id &&
    (order.taxiDriverId && order.taxiDriverId._id.toString() !== req.user.id)
  ) {
    return next(new AppError('You are not authorized to view this order', 403));
  }

  res.status(200).json({
    status: 'success',
    data: {
      order,
    },
  });
});

exports.createOrder = catchAsync(async (req, res, next) => {
  const { items, deliveryAddress, pickupLocation, notes, isUrgent } = req.body;

  console.log('Creating order for user:', req.user.id);
  console.log('Order items:', items);

  // Validate items and calculate total
  let totalAmount = 0;
  const orderItems = [];
  let vendorId = null;

  for (const item of items) {
    const product = await Product.findById(item.productId);
    
    if (!product) {
      return next(new AppError(`Product with ID ${item.productId} not found`, 404));
    }

    if (!product.available || product.stockQuantity < item.quantity) {
      return next(new AppError(`Product ${product.name.en} is not available in the requested quantity`, 400));
    }

    // Set vendorId from the first product (assuming all items from same vendor)
    if (!vendorId) {
      vendorId = product.vendorId;
    }

    totalAmount += product.price * item.quantity;

    orderItems.push({
      productId: product._id,
      productName: {
        en: product.name.en,
        st: product.name.st,
      },
      quantity: item.quantity,
      price: product.price,
    });

    // Update product stock
    product.stockQuantity -= item.quantity;
    await product.save();
  }

  // Calculate delivery fee
  const deliveryFee = isUrgent ? 25.0 : 15.0;
  totalAmount += deliveryFee;

  const orderData = {
    passengerId: req.user.id,
    vendorId: vendorId,
    items: orderItems,
    totalAmount,
    deliveryFee,
    isUrgent: isUrgent || false,
    deliveryAddress,
    pickupLocation,
    notes,
  };

  console.log('Order data:', orderData);

  const order = await Order.create(orderData);

  const populatedOrder = await Order.findById(order._id)
    .populate('passengerId', 'profile')
    .populate('vendorId', 'profile vendorInfo');

  console.log('Order created successfully:', order._id);

  // Emit real-time notification to vendor
  const io = req.app.get('io');
  if (io) {
    io.to(`vendor_${populatedOrder.vendorId._id}`).emit('new_order', populatedOrder);
  }

  res.status(201).json({
    status: 'success',
    data: {
      order: populatedOrder,
    },
  });
});

exports.updateOrderStatus = catchAsync(async (req, res, next) => {
  const { status } = req.body;
  const validStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivering', 'completed', 'cancelled'];

  if (!validStatuses.includes(status)) {
    return next(new AppError('Invalid status value', 400));
  }

  const order = await Order.findById(req.params.id);

  if (!order) {
    return next(new AppError('No order found with that ID', 404));
  }

  // Authorization check
  if (
    req.user.role !== 'admin' &&
    order.vendorId.toString() !== req.user.id &&
    (order.taxiDriverId && order.taxiDriverId.toString() !== req.user.id)
  ) {
    return next(new AppError('You are not authorized to update this order', 403));
  }

  // Status transition validation
  const statusFlow = {
    pending: ['confirmed', 'cancelled'],
    confirmed: ['preparing', 'cancelled'],
    preparing: ['ready', 'cancelled'],
    ready: ['delivering'],
    delivering: ['completed'],
    completed: [],
    cancelled: [],
  };

  if (!statusFlow[order.status].includes(status)) {
    return next(new AppError(`Invalid status transition from ${order.status} to ${status}`, 400));
  }

  // Handle cancellation - restore product stock
  if (status === 'cancelled' && order.status !== 'cancelled') {
    for (const item of order.items) {
      const product = await Product.findById(item.productId);
      if (product) {
        product.stockQuantity += item.quantity;
        await product.save();
      }
    }
  }

  order.status = status;
  
  // Set timestamps for certain status changes
  if (status === 'delivering') {
    order.estimatedDelivery = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes from now
  } else if (status === 'completed') {
    order.actualDelivery = new Date();
  }

  await order.save();

  const updatedOrder = await Order.findById(order._id)
    .populate('passengerId', 'profile')
    .populate('vendorId', 'profile vendorInfo')
    .populate('taxiDriverId', 'profile taxiDriverInfo');

  // Emit real-time status update
  const io = req.app.get('io');
  if (io) {
    io.to(`order_${order._id}`).emit('order_updated', updatedOrder);
  }

  res.status(200).json({
    status: 'success',
    data: {
      order: updatedOrder,
    },
  });
});

exports.assignDriver = catchAsync(async (req, res, next) => {
  const { driverId } = req.body;

  const order = await Order.findById(req.params.id);

  if (!order) {
    return next(new AppError('No order found with that ID', 404));
  }

  if (order.vendorId.toString() !== req.user.id && req.user.role !== 'admin') {
    return next(new AppError('You are not authorized to assign a driver to this order', 403));
  }

  if (order.status !== 'ready') {
    return next(new AppError('Order must be ready before assigning a driver', 400));
  }

  order.taxiDriverId = driverId;
  order.status = 'delivering';
  order.estimatedDelivery = new Date(Date.now() + 30 * 60 * 1000);

  await order.save();

  const updatedOrder = await Order.findById(order._id)
    .populate('passengerId', 'profile')
    .populate('vendorId', 'profile vendorInfo')
    .populate('taxiDriverId', 'profile taxiDriverInfo');

  // Notify driver
  const io = req.app.get('io');
  if (io) {
    io.to(`driver_${driverId}`).emit('delivery_assigned', updatedOrder);
  }

  res.status(200).json({
    status: 'success',
    data: {
      order: updatedOrder,
    },
  });
});

exports.getUserOrders = catchAsync(async (req, res, next) => {
  let query = {};

  // For passengers, show their orders
  if (req.user.role === 'passenger') {
    query = { passengerId: req.user.id };
  }
  // For vendors, show their orders
  else if (req.user.role === 'vendor') {
    query = { vendorId: req.user.id };
  }
  // For taxi drivers, show their deliveries
  else if (req.user.role === 'taxi_driver') {
    query = { taxiDriverId: req.user.id };
  }
  // For admin, show all orders
  else if (req.user.role === 'admin') {
    query = {};
  }

  console.log(`Getting orders for ${req.user.role}: ${req.user.id}`);

  const features = new APIFeatures(Order.find(query), req.query)
    .filter()
    .sort()
    .limitFields()
    .paginate();

  const orders = await features.query
    .populate('passengerId', 'profile')
    .populate('vendorId', 'profile vendorInfo')
    .populate('taxiDriverId', 'profile taxiDriverInfo');

  res.status(200).json({
    status: 'success',
    results: orders.length,
    data: {
      orders,
    },
  });
});

exports.getOrderStats = catchAsync(async (req, res, next) => {
  const stats = await Order.aggregate([
    {
      $match: {
        createdAt: { 
          $gte: new Date(new Date().setDate(new Date().getDate() - 30)) 
        }
      }
    },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
        count: { $sum: 1 },
        totalRevenue: { $sum: '$totalAmount' },
        avgOrderValue: { $avg: '$totalAmount' }
      }
    },
    {
      $sort: { _id: 1 }
    }
  ]);

  const statusStats = await Order.aggregate([
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 }
      }
    }
  ]);

  const totalOrders = await Order.countDocuments();
  const revenueToday = await Order.aggregate([
    {
      $match: {
        createdAt: { $gte: new Date(new Date().setHours(0, 0, 0, 0)) },
        status: 'completed'
      }
    },
    {
      $group: {
        _id: null,
        total: { $sum: '$totalAmount' }
      }
    }
  ]);

  res.status(200).json({
    status: 'success',
    data: {
      dailyStats: stats,
      statusStats,
      totalOrders,
      revenueToday: revenueToday.length > 0 ? revenueToday[0].total : 0,
    },
  });
});