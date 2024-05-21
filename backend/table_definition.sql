CREATE TABLE Pizza (
    pizza_code NUMBER constraint pk_pizza PRIMARY KEY,
    Name VARCHAR(100),
    Description VARCHAR(100),
    Cost DECIMAL(10, 2)
);

CREATE TABLE Ingredient (
    Ingredient_Code NUMBER constraint pk_ingredient PRIMARY KEY,
    Ingredient_Name VARCHAR(100),
    stock NUMBER
);

CREATE TABLE Topping (
    Ingredient_Code NUMBER
	constraint pk_topping PRIMARY KEY
	constraint fk_topping_ingredient REFERENCES Ingredient,
    quantity NUMBER,
    extra_cost DECIMAL(10, 2)
);

CREATE TABLE Pizza_Base (
    Base_Code NUMBER constraint pk_pizza_base PRIMARY KEY,
    Base_Name VARCHAR(100),
    extra_cost DECIMAL(10, 2)
);

CREATE TABLE Pizza_Ingredient (
    Pizza_Code NUMBER constraint fk_pizza_pingredient 
	REFERENCES Pizza on delete cascade,
    Ingredient_Code NUMBER constraint fk_ingredient_pingredient REFERENCES Ingredient,
    Quantity NUMBER,
    constraint pk_pingredient PRIMARY KEY (Pizza_Code, Ingredient_Code)
);

CREATE TABLE base_ingredient (
    Base_code NUMBER constraint fk_base_bingredient 
	REFERENCES Pizza_Base on delete cascade,
    ingredient_code NUMBER constraint fk_ingredient_bingredient REFERENCES Ingredient,
    quantity NUMBER,
    constraint pk_bingredient PRIMARY KEY (Base_code, ingredient_code)
);

CREATE TABLE order_table (
    order_no NUMBER constraint pk_order PRIMARY KEY,
    table_no NUMBER,
    date_time date,
    cust_name VARCHAR(100),
    status VARCHAR(100) constraint inv_status check(status in('Active', 'Complete', 'New')),
    total_cost number
);

CREATE TABLE order_details (
    order_no NUMBER REFERENCES order_table,
    pizza_code NUMBER REFERENCES Pizza,
    pizza_size CHAR(1) constraint inv_pizza_size check(pizza_size in('L', 'R')),
    base_code NUMBER REFERENCES Pizza_Base,
    quantity NUMBER,
    constraint pk_order_details PRIMARY KEY (order_no, pizza_code)
);

CREATE TABLE order_details_topping (
    order_no NUMBER constraint fk_odt_order REFERENCES order_table,
    pizza_code NUMBER constraint fk_odt_pizza REFERENCES Pizza,
    Ingredient_code NUMBER constraint fk_odt_ingredient REFERENCES Topping,
    constraint pk_order_details_topping PRIMARY KEY (order_no, pizza_code, Ingredient_code)
);

INSERT ALL
    INTO Pizza VALUES (1, 'Margherita', 'Classic Italian pizza with tomato sauce and mozzarella cheese', 120, 'Yes')
    INTO Pizza VALUES (2, 'Chicken', 'Pizza topped with chicken chunks and mozzarella cheese', 200, 'Yes')
    INTO Pizza VALUES (3, 'Vegetarian', 'Pizza loaded with assorted vegetables and mozzarella cheese', 140, 'Yes')
    INTO Pizza VALUES (4, 'Mushroom', 'Pizza topped with mushrooms and mozzarella cheese', 150, 'Yes')
    INTO Pizza VALUES (5, 'Paneer', 'Pizza topped with paneer and mozzarella cheese', 170, 'Yes')
    INTO Ingredient VALUES (1, 'Tomato Sauce', 100)
    INTO Ingredient VALUES (2, 'Mozzarella Cheese', 200)
    INTO Ingredient VALUES (3, 'Chicken', 50)
    INTO Ingredient VALUES (4, 'Assorted Vegetables', 80)
    INTO Ingredient VALUES (5, 'Paneer', 200)
    INTO Ingredient VALUES (6, 'Mushrooms', 50)
    INTO Topping VALUES (3, 10, 40)
    INTO Topping VALUES (4, 10, 10)
    INTO Topping VALUES (5, 10, 20)
    INTO Topping VALUES (6, 10, 20)
    INTO Pizza_Base VALUES (1, 'Thin Crust', 0)
    INTO Pizza_Base VALUES (2, 'Regular Crust', 10)
    INTO Pizza_Base VALUES (3, 'Thick Crust', 20)
    INTO Pizza_Ingredient VALUES (2, 3, 30)
    INTO Pizza_Ingredient VALUES (3, 4, 30)
    INTO Pizza_Ingredient VALUES (4, 6, 30)
    INTO Pizza_Ingredient VALUES (5, 5, 30)
    INTO base_ingredient VALUES (1, 1, 20)
    INTO base_ingredient VALUES (1, 2, 20)
    INTO base_ingredient VALUES (2, 1, 30)
    INTO base_ingredient VALUES (2, 2, 30)
    INTO base_ingredient VALUES (3, 1, 40)
    INTO base_ingredient VALUES (3, 2, 40)
SELECT * FROM dual;

-- Order 1
INSERT INTO order_table VALUES (1, 4, TO_DATE('10-mar-2024', 'dd-mon-yyyy'), 'Customer1', 'Complete', 420);
INSERT INTO order_details VALUES (1, 2, 'L', 2, 3);
INSERT INTO order_details_topping VALUES (1, 2, 3);
INSERT INTO order_details_topping VALUES (1, 2, 6);

-- Order 2
INSERT INTO order_table VALUES (2, 7, TO_DATE('05-mar-2024', 'dd-mon-yyyy'), 'Customer2', 'Complete', 510);
INSERT INTO order_details VALUES (2, 3, 'R', 1, 2);
INSERT INTO order_details VALUES (2, 4, 'L', 2, 1);
INSERT INTO order_details_topping VALUES (2, 3, 4);

-- Order 3
INSERT INTO order_table VALUES (3, 9, TO_DATE('01-mar-2024', 'dd-mon-yyyy'), 'Customer3', 'Complete', 560);
INSERT INTO order_details VALUES (3, 1, 'L', 1, 1);
INSERT INTO order_details_topping VALUES (3, 1, 4);
INSERT INTO order_details_topping VALUES (3, 1, 5);

-- Order 4
INSERT INTO order_table VALUES (4, 8, TO_DATE('25-mar-2024', 'dd-mon-yyyy'), 'Customer4', 'Complete', 290);
INSERT INTO order_details VALUES (4, 5, 'R', 2, 2);
INSERT INTO order_details VALUES (4, 1, 'L', 1, 1);
INSERT INTO order_details_topping VALUES (4, 5, 3);

-- Order 5
INSERT INTO order_table VALUES (5, 3, TO_DATE('20-mar-2024', 'dd-mon-yyyy'), 'Customer5', 'Complete', 370);
INSERT INTO order_details VALUES (5, 2, 'L', 2, 1);
INSERT INTO order_details VALUES (5, 3, 'R', 1, 2);
INSERT INTO order_details_topping VALUES (5, 2, 6);
INSERT INTO order_details_topping VALUES (5, 3, 5);

-- Order 6
INSERT INTO order_table VALUES (6, 10, TO_DATE('15-mar-2024', 'dd-mon-yyyy'), 'Customer6', 'Complete', 610);
INSERT INTO order_details VALUES (6, 4, 'L', 3, 1);
INSERT INTO order_details VALUES (6, 5, 'R', 2, 1);
INSERT INTO order_details_topping VALUES (6, 4, 4);
INSERT INTO order_details_topping VALUES (6, 5, 3);
INSERT INTO order_details_topping VALUES (6, 5, 5);

-- Order 7
INSERT INTO order_table VALUES (7, 5, TO_DATE('10-mar-2024', 'dd-mon-yyyy'), 'Customer7', 'Complete', 420);
INSERT INTO order_details VALUES (7, 2, 'R', 1, 3);
INSERT INTO order_details_topping VALUES (7, 2, 4);
INSERT INTO order_details_topping VALUES (7, 2, 5);
INSERT INTO order_details_topping VALUES (7, 2, 6);

-- Order 8
INSERT INTO order_table VALUES (8, 2, TO_DATE('05-apr-2024', 'dd-mon-yyyy'), 'Customer8', 'Complete', 310);
INSERT INTO order_details VALUES (8, 1, 'R', 2, 2);
INSERT INTO order_details_topping VALUES (8, 1, 3);
INSERT INTO order_details_topping VALUES (8, 1, 5);

-- Order 9
INSERT INTO order_table VALUES (9, 6, TO_DATE('01-apr-2024', 'dd-mon-yyyy'), 'Customer9', 'Complete', 270);
INSERT INTO order_details VALUES (9, 3, 'L', 1, 1);

-- Order 10
INSERT INTO order_table VALUES (10, 1, TO_DATE('25-mar-2024', 'dd-mon-yyyy'), 'Customer10', 'Complete', 570);
INSERT INTO order_details VALUES (10, 5, 'R', 3, 1);
INSERT INTO order_details_topping VALUES (10, 5, 4);

-- Order 11
INSERT INTO order_table VALUES (11, 8, TO_DATE('20-mar-2024', 'dd-mon-yyyy'), 'Customer11', 'Complete', 490);
INSERT INTO order_details VALUES (11, 4, 'L', 2, 2);
INSERT INTO order_details VALUES (11, 5, 'R', 1, 1);
INSERT INTO order_details_topping VALUES (11, 4, 6);
INSERT INTO order_details_topping VALUES (11, 5, 3);

-- Order 12
INSERT INTO order_table VALUES (12, 3, TO_DATE('15-mar-2024', 'dd-mon-yyyy'), 'Customer12', 'Complete', 390);
INSERT INTO order_details VALUES (12, 1, 'R', 3, 2);
INSERT INTO order_details_topping VALUES (12, 1, 4);

-- Order 13
INSERT INTO order_table VALUES (13, 9, TO_DATE('10-mar-2024', 'dd-mon-yyyy'), 'Customer13', 'Complete', 350);
INSERT INTO order_details VALUES (13, 2, 'R', 1, 3);
INSERT INTO order_details_topping VALUES (13, 2, 3);
INSERT INTO order_details_topping VALUES (13, 2, 5);

-- Order 14
INSERT INTO order_table VALUES (14, 5, TO_DATE('05-mar-2024', 'dd-mon-yyyy'), 'Customer14', 'Complete', 660);
INSERT INTO order_details VALUES (14, 3, 'L', 2, 1);
INSERT INTO order_details VALUES (14, 4, 'R', 3, 1);
INSERT INTO order_details_topping VALUES (14, 3, 5);
INSERT INTO order_details_topping VALUES (14, 4, 6);

-- Order 15
INSERT INTO order_table VALUES (15, 10, TO_DATE('01-mar-2024', 'dd-mon-yyyy'), 'Customer15', 'Complete', 340);
INSERT INTO order_details VALUES (15, 1, 'L', 2, 2);
INSERT INTO order_details VALUES (15, 2, 'R', 3, 1);
INSERT INTO order_details_topping VALUES (15, 1, 5);
INSERT INTO order_details_topping VALUES (15, 2, 4);

-- Order 16
INSERT INTO order_table VALUES (16, 2, TO_DATE('25-mar-2024', 'dd-mon-yyyy'), 'Customer16', 'Complete', 460);
INSERT INTO order_details VALUES (16, 5, 'R', 1, 3);
INSERT INTO order_details_topping VALUES (16, 5, 3);
INSERT INTO order_details_topping VALUES (16, 5, 6);

-- Order 17
INSERT INTO order_table VALUES (17, 1, TO_DATE('20-mar-2024', 'dd-mon-yyyy'), 'Customer17', 'Complete', 390);
INSERT INTO order_details VALUES (17, 4, 'L', 3, 2);
INSERT INTO order_details_topping VALUES (17, 4, 3);
INSERT INTO order_details_topping VALUES (17, 4, 6);

-- Order 18
INSERT INTO order_table VALUES (18, 8, TO_DATE('15-mar-2024', 'dd-mon-yyyy'), 'Customer18', 'Complete', 590);
INSERT INTO order_details VALUES (18, 1, 'R', 2, 3);
INSERT INTO order_details_topping VALUES (18, 1, 3);
INSERT INTO order_details_topping VALUES (18, 1, 5);
INSERT INTO order_details_topping VALUES (18, 1, 6);

-- Order 19
INSERT INTO order_table VALUES (19, 5, TO_DATE('10-mar-2024', 'dd-mon-yyyy'), 'Customer19', 'Complete', 480);
INSERT INTO order_details VALUES (19, 2, 'R', 1, 2);
INSERT INTO order_details VALUES (19, 3, 'L', 2, 1);
INSERT INTO order_details_topping VALUES (19, 2, 4);
INSERT INTO order_details_topping VALUES (19, 2, 5);

-- Order 20
INSERT INTO order_table VALUES (20, 1, TO_DATE('05-mar-2024', 'dd-mon-yyyy'), 'Customer20', 'Complete', 530);
INSERT INTO order_details VALUES (20, 5, 'R', 2, 3);
INSERT INTO order_details_topping VALUES (20, 5, 3);
INSERT INTO order_details_topping VALUES (20, 5, 4);
INSERT INTO order_details_topping VALUES (20, 5, 5);
