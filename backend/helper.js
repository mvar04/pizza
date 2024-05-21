const { json } = require('express');
const oracledb = require('oracledb');
oracledb.autoCommit = true
// Connection credentials
const dbConfig = {
    user: 'system',
    password: '1234',
    connectString: 'localhost:1521/orcl'
};

  function convertToJson(resultSet) {
    return resultSet.rows.map(row => {
        let obj = {};
        resultSet.metaData.forEach((meta, index) => {
        obj[meta.name.toLowerCase()] = row[index];
        });
        return obj;
    });
}

async function fetchAndConvert(query) {
    try {
        const conn = await oracledb.getConnection(dbConfig);
        const resultSet = await conn.execute(query);
        const jsonData = await convertToJson(resultSet);
        return jsonData;

    } catch (error) {
        console.error('Error fetching and converting:', error);
    }
}


async function createOrder(jsonData) {
    /*
    JSON in the form
    TableNo: 2
    CustName: John Doe
    Items : [
        {
            pizzaCode: 1
            size: L
            baseCode: 2
            quantity: 3
            toppings : [a, b]
        },
        {
            pizzaCode: 1
            size: L
            baseCode: 2
            quantity: 3
            toppings : [a, b]
        }

    ]
    */
   try {
    const conn = await oracledb.getConnection(dbConfig);
    const next_order = (await conn.execute('select count(*) from order_table')).rows[0][0] + 1
    // Insert into order_table
    await conn.execute(`insert into order_table values(:order_no, :table_no, sysdate, :cust_name, 'New', 0)`, {
        order_no: next_order,
        table_no: jsonData.TableNo,
        cust_name: jsonData.CustName
    });

    // Insert into order_details for each pizza
    for (const pizza of jsonData.Items) {
        await conn.execute(`insert into order_details values(:order_no, :pizza_code, :pizza_size, :base_code, :quantity)`, {
            order_no: next_order,
            pizza_code: pizza.pizzaCode,
            pizza_size: pizza.size,
            base_code: pizza.baseCode,
            quantity: pizza.quantity
        });
        // Insert into order_details_topping for each topping of each pizza
        for (const topping of pizza.toppings) {
            await conn.execute(`insert into order_details_topping values(:order_no, :pizza_code, :topping)`, {
                order_no: next_order,
                pizza_code: pizza.pizzaCode,
                topping: topping
            });
        }
    }

    console.log('Data inserted successfully');
    return 

    } catch (error) {
    console.error('Error inserting data:', error);
    }

}

async function addPizza(jsonData){
    try{
    const conn = await oracledb.getConnection(dbConfig);
    const next_pizza = (await conn.execute('select count(*) from pizza')).rows[0][0]
    await conn.execute(`insert into pizza values(:pizza_code, :name, :description, :cost)`, {
        pizza_code: next_pizza + 1, 
        name: jsonData.Name, 
        description: jsonData.Description, 
        cost: jsonData.Cost
    })
    console.log(`Pizza number ${next_pizza + 1} inserted`)

    } catch (error) {
        console.error('Error inserting data:', error);
    }
}

async function addBase(jsonData){
    try{
    const conn = await oracledb.getConnection(dbConfig);
    const next_base = (await conn.execute('select count(*) from pizza_base')).rows[0][0]
    await conn.execute(`insert into pizza_base values(:base_code, :base_name, :extra_cost)`, {
        base_code: next_base + 1, 
        base_name: jsonData.name, 
        extra_cost: jsonData.extra_cost
    })
    console.log(`Pizza base number ${next_base + 1} inserted`)

    } catch (error) {
        console.error('Error inserting data:', error);
    }
}

async function addTopping(jsonData){
    try {
    const conn = await oracledb.getConnection(dbConfig);
    await conn.execute(`insert into topping values(:ingredient_code, :quantity, :extra_cost)`, {
        ingredient_code: jsonData.ingredient_code, 
        quantity: jsonData.quantity, 
        extra_cost: jsonData.extra_cost
    })
    console.log(`Pizza topping inserted`)

    } catch (error) {
        console.error('Error inserting data:', error);
    }
}

async function addIngredient(jsonData){
    try {
        const conn = await oracledb.getConnection(dbConfig);
        const next_ingredient = (await conn.execute('select count(*) from ingredient')).rows[0][0]
        await conn.execute(`insert into ingredient values(:ingredient_code, :ingredient_name, :stock)`, {
            ingredient_code: next_ingredient + 1, 
            ingredient_name: jsonData.Ingredient_Name, 
            stock: jsonData.Stock
        })
        console.log(`Pizza ingredient number ${next_ingredient + 1} inserted`)
    
    } catch (error) {
        console.error('Error inserting data:', error);
    }
}

async function deleteRecord(jsonData){
    try{
        const conn = await oracledb.getConnection(dbConfig);
        if(jsonData.table === "pizza"){
            await conn.execute(`delete from pizza where pizza_code = ${jsonData.value}`)
        }else if(jsonData.table === "pizza_base"){
            await conn.execute(`delete from pizza_base where base_code = ${jsonData.value}`)
        } else if(jsonData.table === "topping"){
            await conn.execute(`delete from topping where ingredient_code = ${jsonData.value}`)
        }
    } catch(error) {
        console.error("Error when deleting record: ", error)
    }
}

async function displayOrder(order_no) {
    try {
        const conn = await oracledb.getConnection(dbConfig);
        let result = await conn.execute(`select o.order_no, p.name, o.pizza_size, b.base_name, o.quantity from order_details o natural join pizza p natural join pizza_base b where order_no = ${order_no}`);
        let converted = convertToJson(result)
        for(i = 0; i < result.rows.length; i++){
            converted[i].toppings = (await conn.execute(`select ingredient_name from ingredient where ingredient_code in (select ingredient_code from order_details_topping where order_no = ${order_no} and pizza_code = (select pizza_code from pizza where name = '${result.rows[i][1]}'))`)).rows.flat()
            converted[i].status = (await conn.execute(`select status from order_table where order_no = ${order_no}`)).rows[0][0]
        }
        return(converted)
    } catch (error) {
        console.error(error);
    }
}

async function displayAllOrders(status){
    try{
        const conn = await oracledb.getConnection(dbConfig);
        let all_orders = (await conn.execute(`select order_no from order_table where status = '${status}'`)).rows.flat()
        
        let all_details = []
        for(let i = 0; i < all_orders.length; i++){
            all_details.push(await displayOrder(all_orders[i]))
        }
        return(all_details)
    } catch(error){
        console.error(error)
    }
    
}

async function update_to_active(jsonData){
    try {
        const conn = await oracledb.getConnection(dbConfig);
        await conn.execute(`update order_table set status = 'Active' where order_no = ${parseInt(jsonData.orderNumber)}`);
    } catch (error) {
        console.error(error)
    }
}

async function update_to_complete(jsonData){
    try {
        const conn = await oracledb.getConnection(dbConfig);
        await conn.execute(`update order_table set status = 'Complete' where order_no = ${parseInt(jsonData.orderNumber)}`);
        await conn.execute(`update order_table set total_cost = calc_total_cost(${jsonData.orderNumber}) where order_no = ${parseInt(jsonData.orderNumber)}`);

    } catch (error) {
        console.error(error)
    }
}

module.exports = {
    fetchAndConvert,
    createOrder,
    addPizza,
    addBase,
    addTopping,
    addIngredient,
    deleteRecord,
    displayOrder,
    displayAllOrders,
    update_to_active,
    update_to_complete
};