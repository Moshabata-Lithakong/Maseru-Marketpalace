const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  vendorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Vendor ID is required']
  },
  name: {
    en: {
      type: String,
      required: [true, 'English product name is required'],
      trim: true
    },
    st: {
      type: String,
      required: [true, 'Sesotho product name is required'],
      trim: true
    }
  },
  description: {
    en: {
      type: String,
      required: [true, 'English description is required']
    },
    st: {
      type: String,
      required: [true, 'Sesotho description is required']
    }
  },
  category: {
    type: String,
    required: [true, 'Category is required'],
    enum: ['food', 'drinks', 'clothing', 'electronics', 'household', 'other']
  },
  price: {
    type: Number,
    required: [true, 'Price is required'],
    min: [0, 'Price cannot be negative']
  },
  currency: {
    type: String,
    default: 'LSL'
  },
  images: [{
    url: String,
    publicId: String
  }],
  tags: [String],
  available: {
    type: Boolean,
    default: true
  },
  stockQuantity: {
    type: Number,
    default: 0
  },
  priority: {
    type: Number,
    default: 1,
    min: 1,
    max: 10
  },
  ratings: {
    average: {
      type: Number,
      default: 0,
      min: 0,
      max: 5
    },
    count: {
      type: Number,
      default: 0
    }
  }
}, {
  timestamps: true
});

// Indexes for better performance
productSchema.index({ vendorId: 1 });
productSchema.index({ category: 1 });
productSchema.index({ available: 1 });
productSchema.index({ priority: -1 });
productSchema.index({ 'name.en': 'text', 'name.st': 'text', 'description.en': 'text', 'description.st': 'text' });

// Virtual for checking if product is in stock
productSchema.virtual('inStock').get(function() {
  return this.stockQuantity > 0;
});

productSchema.set('toJSON', { virtuals: true });
productSchema.set('toObject', { virtuals: true });

const Product = mongoose.model('Product', productSchema);

module.exports = Product;