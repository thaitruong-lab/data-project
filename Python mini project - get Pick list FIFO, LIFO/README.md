# Python mini project

This is my small project which I using python so solve an online challenge

The challenger requests to:
- Create pick list from stock data; and a sales orders data which may includes 4 types of pick method [FIFO, LIFO, FEFO, by EXP date]
- Create a file which contains remaining stock so that could be used for the next pick

[See detail](https://docs.google.com/spreadsheets/d/1IDIVTf36hZqxltg_MYOjsWvSmDxp1pb4gkAzJI64eaU/edit?fbclid=IwAR1NOS6M5FLrUMD2MU60OLllT97n9ezj4axKOXl5Dweghx7s9_zcgkrVoA4#gid=843431074)

Base on that, I upgraded a bit and created a class to do the job
- Use csv file
- Use pandas dataframe to handle tabular data
- Add <code>case_no</code> and <code>created_at</code> to get detail information for pick_list
- Funtion to check item code and quantity
- Funtion to pick by order
- And many other things to make the code easy to understing I hope :))))))

### How it works
First you need to initialize the object  
<code>stockMgt = StockManager([your_stock_data_path])</code>

Then when you want a picklist, just put in a sales orders  
<code>stockMgt.pickBySalesOrder([your_sales_order_path])</code>  
If all the item_code are true, and the remaing quality and fullfill the whole order, you can get a picklist result  
If not, it will show you what was wrong  

After picking, you can get:
- <code>stockMgt.pick_list</code>: pick list for the sales order you put in <code>pickBySalesOrder</code>
- <code>stockMgt.pick_history</code>: picking history
- <code>stockMgt.remaining_report</code>: view current stock

See doc string for more infor

### Author
Truong Hong Thai
