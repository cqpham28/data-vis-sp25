"""
Cuong Pham
"""
import os
import pandas as pd
import streamlit as st
from src.pages import home
from src.utils import *

st.set_page_config(
    page_title="app",
    layout="wide",
)


#######################
PAGES = {
    "Home": home,
}

#######################
def standardize_name(df):

    # Mapping dictionaries for countries and cities
    country_mapping = {
        "Russian Federation": "Russia",
        "United States of America": "United States",
        "Republic of Korea": "Korea, South",
        "Türkiye": "Turkey",
        "People's Republic of China": "China",
        "Czechoslovakia": "Czechia",
        "German Democratic Republic": "Germany",
        "Union of Soviet Socialist Republics": "Russia",
    }

    city_mapping = {
        "A distributed IMO administered from St Petersburg": "Saint Petersburg",
        "Taejon": "Daejeon",
        "Havanna": "Havana",
        "Taipeh": "Taipei",
    }

    # Apply the mappings to standardize names
    if 'country' in df.columns:
        df['country'] = df['country'].replace(country_mapping)
    if 'city' in df.columns:
        df['city'] = df['city'].replace(city_mapping)
    return df


#######################
if "data" not in st.session_state: 
    st.session_state.data = {
        "country": standardize_name(pd.read_csv("../data/country_results_df.csv")),
        "individual": standardize_name(pd.read_csv("../data/individual_results_df.csv")),
        "timeline": standardize_name(pd.read_csv("../data/timeline_df.csv")),
        "df": pd.read_csv("refs/df_timeline_temperature.csv"),
    }


#######################
def main():

    selection = st.sidebar.radio("Select pages", 
                    list(PAGES.keys()))
    os.makedirs("refs", exist_ok=True)
    
    page = PAGES[selection]
    with st.spinner(f"Loading {selection} ..."):
        page.write()




#######################
if __name__ == "__main__":
    main()