const express = require("express");
const router = express.Router();
const db = require("../db");


router.post("/transfer", (req,res)=>{
    const {sender_id, receiver_id, amount} = req.body;

    const sqlTransaction = "INSERT INTO transactions (sender_id,receiver_id,amount,type) VALUES (?,?,?,'transfer')";
    db.query(sqlTransaction,[sender_id,receiver_id,amount], (err,result)=>{
        if(err) res.send(err);
        else res.send({message:"Transfer successful"});
    });
});


router.get("/:userId", (req,res)=>{
    const userId = req.params.userId;
    const sql = "SELECT * FROM transactions WHERE sender_id=? OR receiver_id=? ORDER BY created_at DESC";
    db.query(sql,[userId,userId], (err,result)=>{
        if(err) res.send(err);
        else res.send(result);
    });
});

module.exports = router;