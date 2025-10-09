const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  passengerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Passenger ID is required']
  },
  vendorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Vendor ID is required']
  },
  taxiDriverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  items: [{
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Product',
      required: true
    },
    productName: {
      en: String,
      st: String
    },
    quantity: {
      type: Number,
      required: true,
      min: 1
    },
    price: {
      type: Number,
      required: true,
      min: 0
    }
  }],
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'ready', 'delivering', 'completed', 'cancelled'],
    default: 'pending'
  },
  totalAmount: {
    type: Number,
    required: [true, 'Total amount is required'],
    min: 0
  },
  deliveryFee: {
    type: Number,
    default: 0
  },
  isUrgent: {
    type: Boolean,
    default: false
  },
  // FIXED: Enhanced pickup location with coordinates
  pickupLocation: {
    address: {
      type: String,
      required: [true, 'Pickup location address is required']
    },
    coordinates: {
      latitude: Number,
      longitude: Number
    },
    vendorName: String,
    vendorPhone: String
  },
  // FIXED: Enhanced destination with coordinates
  destination: {
    address: {
      type: String,
      required: [true, 'Destination address is required']
    },
    coordinates: {
      latitude: Number,
      longitude: Number
    },
    instructions: String,
    passengerName: String,
    passengerPhone: String
  },
  payment: {
    method: {
      type: String,
      enum: ['cash', 'mpesa', 'ecocash'],
      default: 'cash'
    },
    status: {
      type: String,
      enum: ['pending', 'processing', 'completed', 'failed', 'refunded'],
      default: 'pending'
    },
    transactionId: String,
    phoneNumber: String,
    amount: Number,
    paymentDate: Date
  },
  notes: String,
  estimatedDelivery: Date,
  actualDelivery: Date,
  // FIXED: Add driver assignment tracking
  driverAssignedAt: Date,
  pickupConfirmedAt: Date,
  deliveryConfirmedAt: Date
}, {
  timestamps: true
});

// Indexes for better performance
orderSchema.index({ passengerId: 1 });
orderSchema.index({ vendorId: 1 });
orderSchema.index({ taxiDriverId: 1 });
orderSchema.index({ status: 1 });
orderSchema.index({ createdAt: -1 });
orderSchema.index({ 'payment.status': 1 });

// Pre-save middleware to calculate total amount
orderSchema.pre('save', function(next) {
  if (this.isModified('items')) {
    const itemsTotal = this.items.reduce((total, item) => {
      return total + (item.quantity * item.price);
    }, 0);
    this.totalAmount = itemsTotal + (this.deliveryFee || 0);
    
    // Set payment amount
    if (this.payment) {
      this.payment.amount = this.totalAmount;
    }
  }
  next();
});

const Order = mongoose.model('Order', orderSchema);

module.exports = Order;