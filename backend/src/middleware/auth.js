const jwt = require('jsonwebtoken');
const User = require('../models/User');
const AppError = require('../utils/appError');

// Protect routes - user must be logged in
exports.protect = async (req, res, next) => {
  try {
    let token;

    // Check for token in header
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    // Also check for token in query string (for testing)
    if (!token && req.query.token) {
      token = req.query.token;
    }

    if (!token) {
      return next(new AppError('You are not logged in. Please log in to access.', 401));
    }

    // Verify token with proper error handling
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-fallback-secret-for-development');
    } catch (jwtError) {
      console.log('JWT Verification Error:', jwtError.message);
      return next(new AppError('Invalid token. Please log in again.', 401));
    }

    // Check if user still exists
    const currentUser = await User.findById(decoded.id);
    if (!currentUser) {
      return next(new AppError('The user belonging to this token no longer exists.', 401));
    }

    // Check if user changed password after token was issued
    if (currentUser.changedPasswordAfter && currentUser.changedPasswordAfter(decoded.iat)) {
      return next(new AppError('User recently changed password. Please log in again.', 401));
    }

    // Grant access to protected route
    req.user = currentUser;
    console.log(`✅ User authenticated: ${currentUser.email} (${currentUser.role})`);
    next();
  } catch (error) {
    console.log('Auth middleware error:', error);
    return next(new AppError('Authentication failed. Please log in again.', 401));
  }
};

// Restrict to certain roles
exports.restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('You are not logged in.', 401));
    }

    if (!roles.includes(req.user.role)) {
      return next(new AppError('You do not have permission to perform this action', 403));
    }
    next();
  };
};

// Grant access to specific user or admin
exports.restrictToUser = (req, res, next) => {
  if (req.user.role === 'admin' || req.user._id.toString() === req.params.id) {
    return next();
  }
  return next(new AppError('You do not have permission to access this resource', 403));
};