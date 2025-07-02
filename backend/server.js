const express = require('express');
const cors = require('cors');
const { sql, poolPromise } = require('./dbConfig');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// --- API Endpoints ---

// GET all products 
// -------------------------------------------------------
app.get('/api/products', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query('SELECT * FROM PRODUCTS');
        res.status(200).json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

// GET product by ID 
// -------------------------------------------------------
app.get('/api/products/:id', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('id', sql.Int, req.params.id)
            .query('SELECT * FROM PRODUCTS WHERE PRODUCTID = @id');
        if (result.recordset.length > 0) {
            res.status(200).json(result.recordset[0]);
        } else {
            res.status(404).send('Product not found');
        }
    } catch (err) {
        res.status(500).send(err.message);
    }
});

// POST a new product 
// -------------------------------------------------------
app.post('/api/products', async (req, res) => {
    const { PRODUCTNAME, PRICE, STOCK } = req.body;
    // Validation
    if (!PRODUCTNAME || PRICE <= 0 || STOCK < 0) {
        return res.status(400).json({ message: 'Validation failed: Name is required and price/stock must be positive.' });
    }
    try {
        const pool = await poolPromise;
        // Check for duplicate product name
        const checkDuplicate = await pool.request()
            .input('productName', sql.NVarChar(100), PRODUCTNAME)
            .query('SELECT COUNT(*) AS count FROM PRODUCTS WHERE PRODUCTNAME = @productName');

        if (checkDuplicate.recordset[0].count > 0) {
            return res.status(409).json({ message: `Product name '${PRODUCTNAME}' already exists.` });
        }
        await pool.request()
            .input('productName', sql.NVarChar, PRODUCTNAME)
            .input('price', sql.Decimal(10, 2), PRICE)
            .input('stock', sql.Int, STOCK)
            .query('INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK) VALUES (@productName, @price, @stock)');
        res.status(201).json({ message: 'Product created successfully' });
    } catch (err) {
        res.status(500).send(err.message);
    }
});

// PUT to update a product by ID 
// -------------------------------------------------------
app.put('/api/products/:id', async (req, res) => {
    const { PRODUCTNAME, PRICE, STOCK } = req.body;
    // Validation 
    if (!PRODUCTNAME || PRICE <= 0 || STOCK < 0) {
        return res.status(400).json({ message: 'Validation failed: Name is required and price/stock must be positive.' });
    }
    try {
        const pool = await poolPromise;
        await pool.request()
            .input('id', sql.Int, req.params.id)
            .input('productName', sql.NVarChar, PRODUCTNAME)
            .input('price', sql.Decimal(10, 2), PRICE)
            .input('stock', sql.Int, STOCK)
            .query('UPDATE PRODUCTS SET PRODUCTNAME = @productName, PRICE = @price, STOCK = @stock WHERE PRODUCTID = @id');
        res.status(200).json({ message: 'Product updated successfully' });
    } catch (err) {
        res.status(500).send(err.message);
    }
});

// DELETE a product by ID 
// -------------------------------------------------------
app.delete('/api/products/:id', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('id', sql.Int, req.params.id)
            .query('DELETE FROM PRODUCTS WHERE PRODUCTID = @id');

        if (result.rowsAffected[0] > 0) {
            res.status(200).json({ message: 'Product deleted successfully' });
        } else {
            res.status(404).send('Product not found');
        }
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});