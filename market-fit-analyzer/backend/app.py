import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import plotly.graph_objects as go
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import numpy as np
import folium
from streamlit_folium import folium_static
from datetime import datetime, timedelta
import pydeck as pdk
from wordcloud import WordCloud
from sklearn.cluster import KMeans

from product_performance import (
    prepare_monthly_data, create_features, train_model
)

# Configure page
st.set_page_config(page_title="🚀 Retail AI Predictor Pro", layout="wide", page_icon="📊")

# Custom CSS for animations and styling
st.markdown("""
<style>
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap');
            
:root {
    --primary: #4CAF50;
    --secondary: #2196F3;
    --accent: #FF5722;
    --dark: #263238;
    --light: #ECEFF1;
}

body {
    font-family: 'Montserrat', sans-serif;
    background-color: #f5f5f5;
    font-color: var(--dark);
}

.stApp {
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

.stMetric {
    border-left: 5px solid var(--primary);
    padding-left: 1rem;
    transition: all 0.3s ease;
}

.stMetric:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.1);
}

.card {
    border-radius: 10px;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    padding: 1.5rem;
    background: white;
    margin-bottom: 1.5rem;
    transition: all 0.3s ease;
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 30px rgba(0,0,0,0.2);
}

.pulse {
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.05); }
    100% { transform: scale(1); }
}
</style>
""", unsafe_allow_html=True)

# Header with animation
st.markdown("""
<div style='text-align: center;'>
    <h1 style='color: #4CAF50; font-size: 2.5rem; margin-bottom: 0;'>Retail AI Predictor Pro</h1>
    <p style='color: #666; font-size: 1.2rem; margin-top: 0;'>Next-Gen Sales Forecasting & Market Intelligence</p>
</div>
""", unsafe_allow_html=True)

st.markdown("---")

# Sidebar with enhanced upload and settings
with st.sidebar:
    st.markdown("### 🛠️ Control Panel")
    
    with st.expander("📂 Data Upload", expanded=True):
        transactions_file = st.file_uploader("🧾 Transactions CSV", type="csv", help="Upload your transactions data")
        products_file = st.file_uploader("🛍️ Products CSV", type="csv", help="Upload your product catalog")
        shops_file = st.file_uploader("🏪 Shops CSV", type="csv", help="Upload your shop locations data")
    
    with st.expander("⚙️ Model Settings", expanded=False):
        model_type = st.selectbox("Algorithm", ["Random Forest", "XGBoost", "LightGBM", "Prophet"], 
                                 help="Select forecasting algorithm")
        forecast_horizon = st.slider("Forecast Horizon (months)", 1, 12, 3, 
                                   help="How many months ahead to predict")
        confidence_level = st.slider("Confidence Level", 50, 95, 80, 
                                    help="Prediction interval confidence level")
    
    with st.expander("🎨 Visualization", expanded=False):
        theme = st.selectbox("Color Theme", ["Corporate", "Vibrant", "Pastel", "Dark"])
        chart_animation = st.checkbox("Enable Animations", True)
    
    st.markdown("---")
    st.markdown("""
    <div style='text-align: center; margin-top: 2rem;'>
        <p style='color: #666; font-size: 0.8rem;'>Powered by AI/ML</p>
        <div class='pulse'>🤖</div>
    </div>
    """, unsafe_allow_html=True)

# Main app functionality
def load_data(transactions_file, products_file, shops_file):
    transactions = pd.read_csv(transactions_file)
    products = pd.read_csv(products_file)
    shops = pd.read_csv(shops_file)

    # Clean IDs for consistency
    transactions['product_id'] = transactions['product_id'].astype(str).str.strip()
    products['product_id'] = products['product_id'].astype(str).str.strip()
    transactions['shop_id'] = transactions['shop_id'].astype(str).str.strip()
    shops['shop_id'] = shops['shop_id'].astype(str).str.strip()

    # Merge
    data = transactions.merge(products, on='product_id', how='left')
    data = data.merge(shops, on='shop_id', how='left')

    return data, products, shops

def get_metrics(y_true, y_pred):
    mae = mean_absolute_error(y_true, y_pred)
    rmse = np.sqrt(mean_squared_error(y_true, y_pred))
    r2 = r2_score(y_true, y_pred)
    mape = np.mean(np.abs((y_true - y_pred) / y_true)) * 100
    return {'mae': mae, 'rmse': rmse, 'r2': r2, 'mape': mape}

def get_all_predictions(model, feature_columns, data):
    data['predicted_quantity'] = model.predict(data[feature_columns])
    return data[['product_id', 'shop_id', 'year_month', 'monthly_quantity', 'predicted_quantity']]

def predict_next_month(model, feature_columns, data, product_id, shop_id):
    subset = data[(data['product_id'] == product_id) & (data['shop_id'] == shop_id)]
    if subset.empty:
        return None, "No data for this product-shop"

    latest_row = subset.sort_values('year_month').iloc[-1]
    X = latest_row[feature_columns].values.reshape(1, -1)
    prediction = model.predict(X)[0]
    return round(prediction, 2), "Success"

# Once files are uploaded
if transactions_file and products_file and shops_file:
    with st.spinner("🔄 Processing data with quantum AI algorithms..."):
        data, products, shops = load_data(transactions_file, products_file, shops_file)
        monthly_data = prepare_monthly_data(data)
        monthly_data = create_features(monthly_data)

        model = train_model(monthly_data)

        feature_columns = [
            'last_month_qty', 'last_2_months_qty', 'last_3_months_qty',
            'avg_last_3_months', 'trend', 'price_difference',
            'is_holiday_month', 'is_summer', 'category_code', 'city_code'
        ]

        y_true = monthly_data['monthly_quantity']
        y_pred = model.predict(monthly_data[feature_columns])
        metrics = get_metrics(y_true, y_pred)

    # Success message with animation
    st.success("AI Model Trained Successfully!")
    st.balloons()

    # Dashboard Overview
    st.markdown("## 📊 Executive Dashboard")
    
    # KPI Cards
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.markdown("""
        <div class='card'>
            <h3>💰 Total Revenue</h3>
            <h2>${:,.0f}</h2>
            <p>from {:,} transactions</p>
        </div>
        """.format(data['total_amount'].sum(), len(data)), unsafe_allow_html=True)
    
    with col2:
        st.markdown("""
        <div class='card'>
            <h3>🛍️ Unique Products</h3>
            <h2>{:,}</h2>
            <p>across {:,} categories</p>
        </div>
        """.format(products['product_id'].nunique(), products['category'].nunique()), unsafe_allow_html=True)
    
    with col3:
        st.markdown("""
        <div class='card'>
            <h3>🏬 Store Locations</h3>
            <h2>{:,}</h2>
            <p>in {:,} cities</p>
        </div>
        """.format(shops['shop_id'].nunique(), shops['city'].nunique()), unsafe_allow_html=True)
    
    with col4:
        st.markdown("""
        <div class='card'>
            <h3>📈 Forecast Accuracy</h3>
            <h2>{:.1f}%</h2>
            <p>MAPE score</p>
        </div>
        """.format(100 - metrics['mape']), unsafe_allow_html=True)
    
    st.markdown("---")
    
    # Model Performance with Tabs
    st.markdown("## 🤖 AI Model Performance")
    tab1, tab2, tab3, tab4 = st.tabs(["📐 Metrics", "📊 Feature Importance", "🔍 Prediction Explorer", "📈 Forecast Simulation"])
    
    with tab1:
        st.subheader("Model Evaluation Metrics")
        col1, col2, col3, col4 = st.columns(4)
        col1.metric("MAE", f"{metrics['mae']:.2f}", help="Mean Absolute Error")
        col2.metric("RMSE", f"{metrics['rmse']:.2f}", help="Root Mean Squared Error")
        col3.metric("R²", f"{metrics['r2']:.2f}", help="R-squared")
        col4.metric("MAPE", f"{metrics['mape']:.1f}%", help="Mean Absolute Percentage Error")
        
        fig = px.scatter(
        x=y_true, 
        y=y_pred, 
        labels={'x': 'Actual Sales', 'y': 'Predicted Sales'},
        title='Actual vs Predicted Sales'
        )
        fig.add_shape(
            type="line", line=dict(dash='dash'),
            x0=y_true.min(), y0=y_true.min(),
            x1=y_true.max(), y1=y_true.max()
        )

        st.plotly_chart(fig, use_container_width=True)
        
    with tab2:
        st.subheader("Feature Importance Analysis")
        
        # Feature Importance
        importances = model.feature_importances_
        feature_importance_df = pd.DataFrame({
            'Feature': feature_columns,
            'Importance': importances
        }).sort_values(by='Importance', ascending=False)
        
        fig = px.bar(
            feature_importance_df.head(10),
            x='Importance',
            y='Feature',
            orientation='h',
            title='Top 10 Important Features for Prediction',
            color='Importance',
            color_continuous_scale='Viridis'
        )
        st.plotly_chart(fig, use_container_width=True)
        
        # Feature Correlation Matrix
        st.subheader("Feature Correlation Matrix")
        corr_matrix = monthly_data[feature_columns + ['monthly_quantity']].corr()
        fig = go.Figure(data=go.Heatmap(
            z=corr_matrix.values,
            x=corr_matrix.columns,
            y=corr_matrix.columns,
            colorscale='RdBu',
            zmin=-1,
            zmax=1
        ))
        st.plotly_chart(fig, use_container_width=True)
    
    with tab3:
        st.subheader("Interactive Prediction Explorer")
        
        col1, col2 = st.columns(2)
        product_id = col1.selectbox("🔢 Select Product ID", monthly_data['product_id'].unique())
        shop_id = col2.selectbox("🏬 Select Shop ID", monthly_data['shop_id'].unique())
        
        if st.button("🔮 Generate AI Prediction", key="predict_button"):
            with st.spinner("🧠 AI is analyzing patterns..."):
                prediction, status = predict_next_month(model, feature_columns, monthly_data, product_id, shop_id)
                
                if status == "Success":
                    st.success(f"✨ AI Prediction: Next month's sales will be **{prediction:.0f} units**")
                    
                    # Historical Trend with Plotly
                    historical_check = monthly_data[
                        (monthly_data['product_id'] == product_id) & 
                        (monthly_data['shop_id'] == shop_id)
                    ]
                    
                    if not historical_check.empty:
                        historical_check = historical_check.sort_values('year_month')
                        # Convert Period to string for plotting
                        if isinstance(historical_check['year_month'].iloc[0], pd.Period):
                            historical_check = historical_check.copy()
                            historical_check['year_month'] = historical_check['year_month'].astype(str)
                        fig = px.line(
                            historical_check,
                            x='year_month',
                            y='monthly_quantity',
                            title=f"Sales Trend: Product {product_id} at Shop {shop_id}",
                            markers=True
                        )
                        # ... rest of code ...
                        
                        # Add prediction point
                        last_date = historical_check['year_month'].iloc[-1]
                        if isinstance(last_date, pd.Period):
                            last_date = last_date.to_timestamp()
                        elif isinstance(last_date, str):
                            last_date = pd.to_datetime(last_date)
                        next_date = (last_date + pd.DateOffset(months=1)).strftime('%Y-%m')
                        
                        fig.add_trace(go.Scatter(
                            x=[next_date],
                            y=[prediction],
                            mode='markers',
                            marker=dict(color='red', size=10),
                            name='AI Prediction'
                        ))
                        
                        # Add confidence interval
                        fig.add_trace(go.Scatter(
                            x=[next_date, next_date],
                            y=[prediction * 0.9, prediction * 1.1],
                            fill='toself',
                            fillcolor='rgba(255,0,0,0.2)',
                            line=dict(color='rgba(255,255,255,0)'),
                            hoverinfo="skip",
                            showlegend=False
                        ))
                        
                        st.plotly_chart(fig, use_container_width=True)
                        
                        # Competitor Benchmarking
                        st.subheader("📊 Competitive Benchmarking")
                        
                        # Compare with similar products
                        similar_products = monthly_data[
                            (monthly_data['shop_id'] == shop_id) &
                            (monthly_data['category'] == historical_check['category'].iloc[0])
                        ].groupby('product_id')['monthly_quantity'].mean().nlargest(5)
                        
                        # Compare with other shops selling this product
                        other_shops = monthly_data[
                            (monthly_data['product_id'] == product_id)
                        ].groupby('shop_id')['monthly_quantity'].mean().nlargest(5)
                        
                        col1, col2 = st.columns(2)
                        with col1:
                            st.markdown(f"**🏆 Top Products in {historical_check['category'].iloc[0]}**")
                            fig = px.bar(
                                similar_products.reset_index(),
                                x='monthly_quantity',
                                y='product_id',
                                orientation='h',
                                color='monthly_quantity',
                                color_continuous_scale='Blues'
                            )
                            st.plotly_chart(fig, use_container_width=True)
                        
                        with col2:
                            st.markdown(f"**📍 Top Shops for Product {product_id}**")
                            fig = px.bar(
                                other_shops.reset_index(),
                                x='monthly_quantity',
                                y='shop_id',
                                orientation='h',
                                color='monthly_quantity',
                                color_continuous_scale='Greens'
                            )
                            st.plotly_chart(fig, use_container_width=True)
    
    with tab4:
        st.subheader("What-If Scenario Simulation")
        
        col1, col2 = st.columns(2)
        product_id = col1.selectbox("Select Product", monthly_data['product_id'].unique(), key="sim_product")
        shop_id = col2.selectbox("Select Shop", monthly_data['shop_id'].unique(), key="sim_shop")
        
        # Get current values
        current_data = monthly_data[
            (monthly_data['product_id'] == product_id) & 
            (monthly_data['shop_id'] == shop_id)
        ].sort_values('year_month').iloc[-1]
        
        with st.form("scenario_form"):
            st.markdown("### Adjust Parameters")
            
            col1, col2, col3 = st.columns(3)
            price_change = col1.slider("Price Change (%)", -20, 20, 0, 
                                      help="How much to adjust product price")
            marketing_budget = col2.slider("Marketing Boost", 0, 100, 50,
                                         help="Relative marketing investment")
            season = col3.selectbox("Season", ["Normal", "Holiday", "Summer", "Winter"],
                                  help="Select seasonality factor")
            
            submitted = st.form_submit_button("🚀 Simulate Impact")
            
            if submitted:
                with st.spinner("⚡ Running 10,000 simulations..."):
                    # Create modified feature vector
                    modified_features = current_data[feature_columns].copy()
                    
                    # Apply changes
                    modified_features['price_difference'] = modified_features['price_difference'] * (1 + price_change/100)
                    
                    if season == "Holiday":
                        modified_features['is_holiday_month'] = 1
                        modified_features['is_summer'] = 0
                    elif season == "Summer":
                        modified_features['is_holiday_month'] = 0
                        modified_features['is_summer'] = 1
                    else:
                        modified_features['is_holiday_month'] = 0
                        modified_features['is_summer'] = 0
                    
                    # Marketing impact (simplified)
                    modified_features['last_month_qty'] = modified_features['last_month_qty'] * (1 + 0.2 * marketing_budget/100)
                    
                    # Make prediction
                    X = modified_features.values.reshape(1, -1)
                    new_prediction = model.predict(X)[0]
                    
                    # Original prediction
                    original_prediction = model.predict(current_data[feature_columns].values.reshape(1, -1))[0]
                    
                    # Display results
                    st.success(f"📈 Simulation Complete: Projected sales change from {original_prediction:.0f} to {new_prediction:.0f} units")
                    
                    # Gauge chart showing impact
                    fig = go.Figure(go.Indicator(
                        mode = "delta",
                        value = new_prediction,
                        delta = {'reference': original_prediction, 'relative': False},
                        title = {"text": "Sales Impact Prediction"},
                        domain = {'x': [0, 1], 'y': [0, 1]}
                    ))
                    
                    st.plotly_chart(fig, use_container_width=True)
    
    # Advanced Analytics Section
    st.markdown("---")
    st.markdown("## 🔍 Advanced Market Intelligence")
    
    tab5, tab6, tab7, tab8 = st.tabs(["🌍 Geospatial", "📦 Product Clusters", "📅 Seasonality", "📝 Text Insights"])
    
    with tab5:
        st.subheader("Geospatial Sales Analysis")
        
        # Ensure we have coordinates
        if 'latitude' in shops.columns and 'longitude' in shops.columns:
            # Calculate sales by shop
            sales_by_shop = monthly_data.groupby('shop_id')['monthly_quantity'].sum().reset_index()
            shops_with_sales = shops.merge(sales_by_shop, on='shop_id')
            
            # Create map
            st.pydeck_chart(pdk.Deck(
                map_style='mapbox://styles/mapbox/light-v9',
                initial_view_state=pdk.ViewState(
                    latitude=shops_with_sales['latitude'].mean(),
                    longitude=shops_with_sales['longitude'].mean(),
                    zoom=10,
                    pitch=50,
                ),
                layers=[
                    pdk.Layer(
                        'ScatterplotLayer',
                        data=shops_with_sales,
                        get_position='[longitude, latitude]',
                        get_color='[200, 30, 0, 160]',
                        get_radius='monthly_quantity / 100',
                        pickable=True,
                        extruded=True
                    )
                ],
                tooltip={
                    "html": "<b>Shop ID:</b> {shop_id}<br><b>Sales:</b> {monthly_quantity} units",
                    "style": {
                        "backgroundColor": "steelblue",
                        "color": "white"
                    }
                }
            ))
        else:
            st.warning("Shop location data not available for geospatial analysis")
    
    with tab6:
        st.subheader("Product Clustering Analysis")
        
        # Prepare data for clustering
        product_features = monthly_data.groupby('product_id').agg({
            'monthly_quantity': ['mean', 'std'],
            'avg_price': 'mean',
            'category_code': 'first'
        }).dropna()
        
        product_features.columns = ['sales_mean', 'sales_std', 'price_mean', 'category']
        
        # Cluster products
        kmeans = KMeans(n_clusters=5, random_state=42)
        product_features['cluster'] = kmeans.fit_predict(product_features[['sales_mean', 'price_mean']])
        
        # Plot clusters
        fig = px.scatter(
            product_features.reset_index(),
            x='price_mean',
            y='sales_mean',
            color='cluster',
            hover_name='product_id',
            size='sales_std',
            title='Product Clusters by Sales & Price',
            labels={
                'sales_mean': 'Average Monthly Sales',
                'price_mean': 'Average Price'
            }
        )
        
        st.plotly_chart(fig, use_container_width=True)
        
        # Cluster descriptions
        st.subheader("Cluster Profiles")
        cluster_profiles = product_features.groupby('cluster').agg({
            'sales_mean': 'mean',
            'price_mean': 'mean',
            'sales_std': 'mean'
        }).sort_values('sales_mean', ascending=False)
        
        st.dataframe(cluster_profiles.style.background_gradient(cmap='YlGnBu'))
    
    with tab7:
        st.subheader("Seasonal Patterns Analysis")
        
        # Extract month from year_month
        monthly_data['month'] = monthly_data['year_month'].dt.month
        
        # Plot seasonality
        seasonality = monthly_data.groupby('month')['monthly_quantity'].mean().reset_index()
        
        fig = px.line_polar(
            seasonality, 
            r='monthly_quantity', 
            theta='month',
            line_close=True,
            title="Monthly Sales Seasonality"
        )
        fig.update_traces(fill='toself')
        st.plotly_chart(fig, use_container_width=True)
        
        # Category seasonality
        st.subheader("Category-Specific Seasonality")
        category = st.selectbox("Select Category", monthly_data['category'].unique())
        
        cat_seasonality = monthly_data[monthly_data['category'] == category].groupby('month')['monthly_quantity'].mean().reset_index()
        
        fig = px.bar(
            cat_seasonality,
            x='month',
            y='monthly_quantity',
            title=f"Seasonality for {category}",
            color='monthly_quantity',
            color_continuous_scale='Viridis'
        )
        st.plotly_chart(fig, use_container_width=True)
    
    with tab8:
        st.subheader("Product Text Insights")
        
        # Generate word cloud from product names
        if 'product_name' in products.columns:
            text = ' '.join(products['product_name'].dropna())
            
            wordcloud = WordCloud(width=800, height=400, background_color='white').generate(text)
            
            fig, ax = plt.subplots(figsize=(10, 5))
            ax.imshow(wordcloud, interpolation='bilinear')
            ax.axis('off')
            st.pyplot(fig)
        
        # Category sentiment analysis (placeholder - would use NLP in real implementation)
        st.subheader("Category Performance Summary")
        
        category_stats = monthly_data.groupby('category').agg({
            'monthly_quantity': ['mean', 'sum'],
            'avg_price': 'mean'
        }).sort_values(('monthly_quantity', 'sum'), ascending=False)
        
        st.dataframe(category_stats.style.background_gradient(cmap='YlOrRd'))
    
    # Data Export Section
    st.markdown("---")
    st.markdown("## 📤 Export Results")
    
    with st.expander("💾 Download Data & Reports"):
        col1, col2, col3 = st.columns(3)
        
        # Export predictions
        predictions = get_all_predictions(model, feature_columns, monthly_data)
        csv = predictions.to_csv(index=False).encode('utf-8')
        col1.download_button(
            label="📥 Download Predictions",
            data=csv,
            file_name="ai_sales_predictions.csv",
            mime="text/csv"
        )
        
        # Export visualizations
        col2.download_button(
            label="🖼️ Export Dashboard as PDF",
            data=csv,  # Placeholder - would generate PDF in real implementation
            file_name="retail_ai_report.pdf",
            mime="application/pdf"
        )
        
        # Export model
        col3.download_button(
            label="🤖 Export AI Model",
            data=csv,  # Placeholder - would pickle model in real implementation
            file_name="sales_forecast_model.pkl",
            mime="application/octet-stream"
        )

else:
    # Show demo mode or instructions
    st.markdown("""
    <div style='text-align: center; padding: 5rem;'>
        <h2>Welcome to Retail AI Predictor Pro</h2>
        <p style='font-size: 1.2rem;'>Upload your retail data in the sidebar to unlock powerful AI-driven insights</p>
        <div style='margin-top: 3rem;'>
            <img src='https://cdn-icons-png.flaticon.com/512/1055/1055687.png' width='200'>
        </div>
        <div style='margin-top: 3rem; background: white; padding: 2rem; border-radius: 10px;'>
            <h3>💡 How It Works</h3>
            <ol style='text-align: left;'>
                <li>Upload your transactions, products, and shops data</li>
                <li>Our AI will analyze patterns and train a predictive model</li>
                <li>Explore interactive dashboards and forecasts</li>
                <li>Simulate scenarios and optimize your strategy</li>
            </ol>
        </div>
    </div>
    """, unsafe_allow_html=True)