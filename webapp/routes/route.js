const express = require('express');
const router = express.Router();
const { healthz, 
    getHttpCheck, 
    postHttpCheck, 
    getHttpCheckId, 
    putHttpCheckId, 
    deleteHttpCheckId } = require('../controllers/controller');

router.get("/healthz", healthz);

router.get("/v1/http-check", getHttpCheck);

router.post("/v1/http-check", postHttpCheck);

router.get("/v1/http-check/:id", getHttpCheckId);

router.put("/v1/http-check/:id", putHttpCheckId);

router.delete("/v1/http-check/:id", deleteHttpCheckId);

module.exports = router;