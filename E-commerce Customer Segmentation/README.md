
# E-commerce RFM Customer Segmentation

### Dataset  
In this project, I use E-commerce transactions data (contains ~500.000 records) to perform segmentation with RFM metrics  
**Data scoure**: Actual transactions from UK retailer published on [Kaggle](https://www.kaggle.com/datasets/carrie1/ecommerce-data) by CARRIE

### Languages  
#### 1. SQL - BigQuery
- Perform data cleaning
- Perform RFM Segmetantion using [Putler](https://www.putler.com/rfm-analysis/)'s method  
[Link to query](https://console.cloud.google.com/bigquery?sq=931914805278:033d9213c35e4ae7aaa4a9d74c964924)  

- Use Cohort Analysis to Measure Customer Retention  
[Link to query](https://console.cloud.google.com/bigquery?sq=931914805278:9812ce884216404d9a0593b9bf7dce3c)  
[Link to visualization](https://public.tableau.com/views/CohortAnalysis-RetentionRate/CohortAnalysis?:language=en-US&:display_count=n&:origin=viz_share_link)

<img src="https://user-images.githubusercontent.com/55086588/191474061-2a5c83c7-ba2c-43cf-97ae-ca8b337ab12a.png" width="1072" height="603">

#### 2. Python
- Perform data cleaning, EDA
- Use KMeans to classify customer to k=5 clusters
- Visualize 3D plot
Notebook: [E-commerce - RFM segmentation using Kmeans.ipynb](https://github.com/thaitruong-lab/data-analyst/blob/main/E-commerce%20Customer%20Segmentation/E-commerce%20-%20RFM%20segmentation%20using%20Kmeans.ipynb)
## Author

Truong Hong Thai
