const express = require("express");
const router = express.Router();
const db = require("../db");


router.post("/register", (req,res)=>{
    const {name,email,password} = req.body;
    const account_number = "AC"+Math.floor(Math.random()*1000000);

    const sql = "INSERT INTO users (name,email,password,account_number) VALUES (?,?,?,?)";
    db.query(sql,[name,email,password,account_number],(err,result)=>{
        if(err) res.send(err);
        else res.send({message:"User registered", account_number});
    });
});


router.post("/login",(req,res)=>{
    const {email,password} = req.body;
    const sql = "SELECT * FROM users WHERE email=? AND password=?";
    db.query(sql,[email,password],(err,result)=>{
        if(err) res.send(err);
        else if(result.length>0) res.send(result[0]);
        else res.send({message:"Invalid credentials"});
    });
});

module.exports = router;