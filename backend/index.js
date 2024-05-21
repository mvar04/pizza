const oracledb = require('oracledb');
const dbConfig = {
    user: 'system',
    password: '1234',
    connectString: 'localhost:1521/orcl'
};
oracledb.autoCommit = true
const { 
    fetchAndConvert, 
    createOrder, 
    addPizza, 
    addBase, 
    addTopping, 
    addIngredient,
    deleteRecord, 
    displayOrder, 
    displayAllOrders,
    update_to_active ,
    update_to_complete
} = require('./helper.js');

const express = require('express');
const cors = require('cors')

const port = 3000;
const app = express();
app.use(express.json());
app.use(cors());
app.use(express.urlencoded({
    extended: true,
}))

app.use((req, res, next) => {
    req.time = new Date(Date.now()).toString();
    console.log(req.method, req.hostname, req.path, req.time);
    next();
});

app.get('/menu', async (req, res) => {
    try {
        const pizza = await fetchAndConvert('select * from pizza');
        const pizza_base = await fetchAndConvert('select * from pizza_base');
        const topping = await fetchAndConvert(`select ingredient_code, i.ingredient_name, t.extra_cost from ingredient i natural join topping t`);
        res.json({
            'pizza': pizza,
            'pizza_base': pizza_base,
            'topping': topping
        });
  
    } catch (error) {

        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }
});

app.get('/order/:id', async(req, res) => {
    res.json(await displayOrder(req.params.id))
})

app.get('/orderByTable/:table', async(req, res) => {
    try{
        const final = []
        const conn = await oracledb.getConnection(dbConfig);
        let orders = await conn.execute(`select order_no from order_table where table_no = ${req.params.table} and status != 'Complete'`);
        orders = await orders.rows.flat()
        for(let i = 0; i < orders.length; i++){
            let temp = await displayOrder(orders[i])
            for(let j = 0; j < temp.length; j++){
                temp[j]['cost'] = (await conn.execute(`select calc_total_cost(${orders[i]}) from dual`)).rows[0][0]
            }
            console.log(temp)
            final.push(temp)

        }
        res.json(final.flat())
    } catch (error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }

})

app.get('/all_orders/:status', async(req, res) => {
    res.json(await displayAllOrders(req.params.status))
})

app.post('/new_order', async(req, res) => {
    try {
        res.json(createOrder(req.body))
    } catch (error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }
})


app.post('/pizza_add', async (req, res) => {
    try {
        res.json(addPizza(req.body))
    } catch (error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }
})

app.post('/base_add', async (req, res) => {
    try {
        res.json(addBase(req.body))
    } catch (error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }
})

app.post('/topping_add', async (req, res) => {
    try {
        res.json(addTopping(req.body))
    } catch (error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }
})

app.post('/ingredient_add', async (req, res) => {
    try {
        res.json(addIngredient(req.body))
    } catch (error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }
})

app.post('/delete', async (req, res) => {
    try {
        res.json(deleteRecord(req.body))
    } catch (error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }
})

app.post('/set_active', async (req, res) => {
    try {
        res.json(update_to_active(req.body))
    } catch (error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }

})

app.post('/set_complete', async (req, res) => {
    try {
        res.json(update_to_complete(req.body))
    } catch (error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }

})

app.get('/stats', async (req, res) => {
    try{
        let jsonData = {}
        jsonData.a = await fetchAndConvert('SELECT COUNT(*) total_pizzas_ordered FROM order_details')
        jsonData.b = await fetchAndConvert('SELECT SUM(total_cost) total_revenue FROM order_table')
        jsonData.c = await fetchAndConvert(`SELECT p.Name, COUNT(*) total_orders
        FROM order_details od
        JOIN Pizza p ON od.pizza_code = p.pizza_code
        GROUP BY p.Name
        ORDER BY total_orders DESC`)
        jsonData.d = await fetchAndConvert('SELECT AVG(total_cost) average_order_cost FROM order_table')
        jsonData.e = await fetchAndConvert('SELECT Ingredient_Name, stock FROM Ingredient')
        jsonData.f = await fetchAndConvert(`SELECT order_no, table_no, to_char(date_time, 'dd/mm/yy'), cust_name, total_cost 
        FROM order_table
        WHERE total_cost = (SELECT MAX(total_cost) FROM order_table)`)
        jsonData.g = await fetchAndConvert(`
        SELECT cust_name, SUM(total_cost) AS total_spent
        FROM order_table
        GROUP BY cust_name
        ORDER BY total_spent DESC
        FETCH FIRST ROW ONLY`)
        jsonData.h = await fetchAndConvert(`SELECT AVG(total_pizzas_ordered) average_pizzas_per_order
      FROM (SELECT order_no, COUNT(*) AS total_pizzas_ordered
            FROM order_details
            GROUP BY order_no)`)
        jsonData.i = await fetchAndConvert('SELECT sum_of_week(sysdate - 7) previous_Week_sales from dual')
        res.json(jsonData)

    } catch(error) {
        console.error('Error processing menu request:', error);
        res.status(500).json({ error: 'Internal server error'});
    }
})

app.post('/update-stock', async (req, res) => {
    try {
        const ingredientName = req.body.ingredientName;
        const newStock = req.body.newStock;

        // Connect to the OracleDB database
        const connection = await oracledb.getConnection(dbConfig);

        // Update the stock in the database
        const query = `UPDATE Ingredient SET stock = :newStock WHERE Ingredient_Name = :ingredientName`;
        const result = await connection.execute(query, {
            newStock: newStock,
            ingredientName: ingredientName
        }, { autoCommit: true });

        // Release the connection
        await connection.close();

        res.status(200).json({ message: 'Stock updated successfully' });
    } catch (error) {
        console.error('Error updating stock:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});


app.listen(port, () => {
    console.log('Listening on port 3000');
});
