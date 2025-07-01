import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
import joblib


def prepare_monthly_data(data):
    """Convert daily transactions to monthly aggregated sales data."""
    print("Preparing monthly sales data...")

    # Ensure datetime
    if not pd.api.types.is_datetime64_any_dtype(data['transaction_time']):
        data['transaction_time'] = pd.to_datetime(data['transaction_time'], errors='coerce')
    
    data = data.dropna(subset=['transaction_time'])
    data['year_month'] = data['transaction_time'].dt.to_period('M')

    # Aggregate
    monthly_sales = data.groupby(['product_id', 'shop_id', 'year_month']).agg({
        'quantity': 'sum',
        'total_amount': 'sum',
        'unit_price': 'mean',
        'product_name': 'first',
        'category': 'first',
        'city': 'first',
        'standard_price': 'first'
    }).reset_index()

    # Rename
    monthly_sales.rename(columns={
        'quantity': 'monthly_quantity',
        'total_amount': 'monthly_revenue',
        'unit_price': 'avg_price'
    }, inplace=True)

    monthly_sales = monthly_sales.sort_values(['product_id', 'shop_id', 'year_month'])

    print(f"✅ Created {len(monthly_sales)} monthly records.")
    return monthly_sales


def create_features(monthly_data):
    """Create lag, trend, and encoded features."""
    print("Creating features...")

    if not isinstance(monthly_data['year_month'].dtype, pd.PeriodDtype):
        monthly_data['year_month'] = monthly_data['year_month'].astype('period[M]')

    monthly_data['month_date'] = monthly_data['year_month'].dt.to_timestamp()
    monthly_data['month'] = monthly_data['month_date'].dt.month
    monthly_data['year'] = monthly_data['month_date'].dt.year

    # Lag features
    monthly_data['last_month_qty'] = monthly_data.groupby(['product_id', 'shop_id'])['monthly_quantity'].shift(1)
    monthly_data['last_2_months_qty'] = monthly_data.groupby(['product_id', 'shop_id'])['monthly_quantity'].shift(2)
    monthly_data['last_3_months_qty'] = monthly_data.groupby(['product_id', 'shop_id'])['monthly_quantity'].shift(3)

    monthly_data['avg_last_3_months'] = monthly_data[['last_month_qty', 'last_2_months_qty', 'last_3_months_qty']].mean(axis=1)
    monthly_data['trend'] = monthly_data['last_month_qty'] - monthly_data['last_2_months_qty']
    monthly_data['price_difference'] = monthly_data['avg_price'] - monthly_data['standard_price']

    monthly_data['is_holiday_month'] = monthly_data['month'].isin([1, 4, 10, 11, 12]).astype(int)
    monthly_data['is_summer'] = monthly_data['month'].isin([3, 4, 5, 6]).astype(int)

    # Encoding
    monthly_data['category_code'] = pd.Categorical(monthly_data['category']).codes
    monthly_data['city_code'] = pd.Categorical(monthly_data['city']).codes

    # Drop NA from lags
    monthly_data = monthly_data.dropna(subset=['last_month_qty', 'last_2_months_qty', 'last_3_months_qty'])

    print(f"✅ Feature set created with {len(monthly_data)} rows.")
    return monthly_data


def train_model(data, target_col='monthly_quantity'):
    """Train a basic RandomForest model."""
    print("Training model...")

    # Define features to use
    features = [
        'last_month_qty', 'last_2_months_qty', 'last_3_months_qty',
        'avg_last_3_months', 'trend', 'price_difference',
        'is_holiday_month', 'is_summer', 'category_code', 'city_code'
    ]

    X = data[features]
    y = data[target_col]

    # Split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Model
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)

    # Evaluate
    y_pred = model.predict(X_test)
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    r2 = r2_score(y_test, y_pred)

    print(f"✅ Model trained. RMSE: {rmse:.2f}, R²: {r2:.2f}")

    return model


def predict_next_month(model, data):
    """Use trained model to predict future month sales."""
    print("Predicting next month's sales...")

    features = [
        'last_month_qty', 'last_2_months_qty', 'last_3_months_qty',
        'avg_last_3_months', 'trend', 'price_difference',
        'is_holiday_month', 'is_summer', 'category_code', 'city_code'
    ]

    data['predicted_quantity'] = model.predict(data[features])
    print(f"✅ Predictions added to dataframe.")
    return data


# Example usage
if __name__ == '__main__':
    # Load your dataset here (CSV, database, etc.)
    try:
        df = pd.read_csv('data/retail_data.csv')  # change path if needed

        # Step-by-step pipeline
        monthly = prepare_monthly_data(df)
        features = create_features(monthly)
        model = train_model(features)
        result = predict_next_month(model, features)

        # Save result
        result.to_csv("data/monthly_predictions.csv", index=False)
        joblib.dump(model, "models/sales_forecast_model.pkl")
        print("✅ Finished pipeline and saved predictions & model.")
    except Exception as e:
        print("❌ Error occurred:", e)
        