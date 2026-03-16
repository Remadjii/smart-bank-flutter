const express = require("express");
const router = express.Router();
const db = require("../db");


router.get("/", (req,res)=>{
    const sql = "SELECT id,name,email,account_number,balance FROM users";
    db.query(sql,(err,result)=>{
        if(err) res.send(err);
        else res.send(result);
    });
});

module.exports = router;