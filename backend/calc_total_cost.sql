CREATE OR REPLACE FUNCTION calc_total_cost(
    p_order_no order_table.order_no%TYPE
) RETURN DECIMAL IS
    v_pizza_cost DECIMAL(10, 2);
    v_base_cost DECIMAL(10, 2);
    v_topping_cost DECIMAL(10, 2);
    v_total_cost DECIMAL(10, 2) := 0;
BEGIN
    FOR order_detail IN (SELECT * FROM order_details WHERE order_no = p_order_no) LOOP
            v_topping_cost := 0;

            SELECT Cost INTO v_pizza_cost
            FROM Pizza
            WHERE pizza_code = order_detail.pizza_code;

            SELECT extra_cost INTO v_base_cost
            FROM Pizza_Base
            WHERE Base_Code = order_detail.base_code;

            SELECT NVL(SUM(extra_cost), 0) INTO v_topping_cost
            FROM Topping
            WHERE Ingredient_Code IN (
                SELECT Ingredient_Code
                FROM order_details_topping
                WHERE order_no = order_detail.order_no
                AND pizza_code = order_detail.pizza_code
            );

            v_total_cost := v_total_cost + (v_pizza_cost + v_base_cost + v_topping_cost) * order_detail.quantity;
            IF order_detail.pizza_size = 'L' THEN
                v_total_cost := v_total_cost + 0.5 * (v_pizza_cost + v_base_cost + v_topping_cost) * order_detail.quantity;
            END IF;
    END LOOP;
    RETURN v_total_cost;
END;
/
