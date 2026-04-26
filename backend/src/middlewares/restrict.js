const restrictto = (...roles) => {
  return (req, res, next) => {
    const userrole = req.user.role;
    if (!roles.includes(userrole)) {
      res.status(403).json({
        message: "you dont have permission for this .... forbidden",
      });
    } else {
      next();
    }
  };
};
module.exports = restrictto;
