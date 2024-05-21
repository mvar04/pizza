CREATE OR REPLACE TRIGGER update_ingredient_stock
BEFORE UPDATE OF status ON order_table
FOR EACH ROW
DECLARE
    v_ingredient_code NUMBER;
    v_quantity NUMBER;
    v_stock NUMBER;
BEGIN
    IF :NEW.status = 'Active' then
    FOR order_detail in (select * from order_details where order_no = :NEW.order_no) LOOP
        FOR ingredient_row IN (SELECT * FROM pizza_ingredient WHERE pizza_code = order_detail.pizza_code) LOOP
            v_ingredient_code := ingredient_row.Ingredient_Code;
            select stock into v_stock from ingredient where Ingredient_Code = v_ingredient_code;
            IF order_detail.pizza_size = 'L' THEN
                v_quantity := ingredient_row.Quantity * order_detail.quantity * 1.5; 
            ELSE
                v_quantity := ingredient_row.Quantity * order_detail.quantity;
            END IF;
            
            IF v_quantity >= v_stock THEN
                raise_application_error(-20020, ('Item ' || v_ingredient_code || ' not available'));
            END IF;

            UPDATE ingredient
            SET stock = stock - v_quantity
            WHERE Ingredient_Code = v_ingredient_code;
        END LOOP;
        
        FOR base_row IN (SELECT * FROM base_ingredient WHERE base_code = order_detail.base_code) LOOP
            v_ingredient_code := base_row.ingredient_code;
            
            IF order_detail.pizza_size = 'L' THEN
                v_quantity := base_row.quantity * order_detail.quantity * 1.5; 
            ELSE
                v_quantity := base_row.quantity * order_detail.quantity;
            END IF;
            
            UPDATE ingredient
            SET stock = stock - v_quantity
            WHERE Ingredient_Code = v_ingredient_code;
        END LOOP;
        
        FOR topping_row IN (SELECT * FROM order_details_topping WHERE order_no = order_detail.order_no AND pizza_code = order_detail.pizza_code) LOOP
            v_ingredient_code := topping_row.Ingredient_Code;
            
            IF order_detail.pizza_size = 'L' THEN
                SELECT quantity * order_detail.quantity * 1.5 INTO v_quantity
                FROM topping 
                WHERE topping.ingredient_code = topping_row.ingredient_code;
            ELSE
                SELECT quantity * order_detail.quantity INTO v_quantity
                FROM topping 
                WHERE topping.ingredient_code = topping_row.ingredient_code;       
            END IF;
            UPDATE ingredient
            SET stock = stock - v_quantity
            WHERE Ingredient_Code = v_ingredient_code;
        END LOOP;
    END LOOP;
    END IF;
END;
/