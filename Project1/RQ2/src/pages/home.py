import os
import pandas as pd
import streamlit as st
import matplotlib.pyplot as plt
import seaborn as sns
#
from src.utils import *


def aggregate():
    """Function to aggreate data"""
    df_country = st.session_state.data['country']
    df = st.session_state.data['df']

    df_all = []
    for selected_year in df['year'].unique():
        df_host = df[df['year'] == selected_year]

        df_host_result = df_country[df_country['country']==df_host['country'].values[0]]
        df_host_result['performance_sum'] = df_host_result.iloc[:, 5:11].sum(axis=1)
        df_host_result = df_host_result.merge(
            df[['year', 'avg_temperature']], 
                on=['year'], 
                how='left'
        )
        df_host_result_clean = df_host_result[(df_host_result['performance_sum'] != 0) \
                                              & (df_host_result['avg_temperature'].notna())]
        df_all.append(df_host_result_clean)


    df_all = pd.concat(df_all, axis=0)
    return df_all



#######################
def write():
    """main"""

    # TITLE
    st.subheader("Data Visualization")
    st.sidebar.info(
        "This is the platform for internal usage"
    )
    map_column, data_column = st.columns(2)

    # df = get_location_cities()
    # for _, row in df.iterrows():
    #     st.write(">>>Fechting: ", row['year'], row['city'])
    #     df.loc[_,'avg_temperature'] =  get_temperature(row)
    # df.to_csv("refs/df_timeline_temperature.csv")


    df = st.session_state.data['df']

    ## 
    with map_column:

        # Year selection slider
        df['year'] = pd.to_datetime(df['start_date']).dt.year
        available_years = sorted(df['year'].unique())

        selected_year = st.slider(
            "Select Year", 
            min(available_years), 
            max(available_years), 
            step=1
        )

        # Filter data for the selected year
        df_host = df[df['year'] == selected_year]
        st.write(df_host[['edition', 'country', 'city']])

        plot_folium(df_host)




    #########
    with data_column:

        df_all = aggregate()
        country = df_host['country'].values[0]
        year = df_host['year'].values[0]
        df_all = df_all[df_all['country'] == country]
        
        df_all_spot = df_all[df_all['year'] == year]

        # # Scatter plot with Seaborn for color mapping
        fig, ax = plt.subplots(figsize=(8,6))
        st.title("Scatter Plot with Regression Line and Correlation")

        # Plot regression line and scatter points using seaborn
        sns.regplot(
            x="avg_temperature", 
            y="performance_sum", 
            data=df_all, 
            scatter_kws={'s': 100}, 
            ax=ax, 
            color="blue", 
            line_kws={"color": "red"}
        )
        ax.scatter(
            df_all_spot['avg_temperature'], 
            df_all_spot['performance_sum'], 
            color="green", 
            s=300, 
            label=f"host at {year}"
        )
        # CONFIG
        ax.set_title(f"Results of Country: [{country}]", fontsize=16)
        ax.set_xlabel("Average Temperature of the attending location (°C)", fontsize=12)
        ax.set_ylabel("Country Performance Results", fontsize=12)
        ax.legend()
        ax.grid(True)
        ax.set_xlim(0, 35)
        ax.set_ylim(0, 400)

        # Display plot
        st.pyplot(fig)
                
        
    ## DEBUG LOG
    st.write(df_all)