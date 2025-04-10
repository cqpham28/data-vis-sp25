import requests
import pandas as pd
import streamlit as st
import streamlit.components.v1 as components
import pydeck as pdk
import folium


#######################
def get_location_cities():
    df_world_cities = pd.read_csv("../external_data/simplemaps_worldcities_basicv1.77/worldcities.csv")
    df = st.session_state.data['timeline'].copy()\
            .merge(
                df_world_cities[['city', 'country', 'lat', 'lng']], 
                on=['city', 'country'], 
                how='left'
            )
    
    df.dropna(inplace=True)
    df = df.drop_duplicates(subset=['country', 'city'], keep='first')
    return df



#######################
def fetch_weather_data(city, lat, lon, start_date, end_date):
    """
    Function to fetch weather data for each city based on lat and lon
    """
    # API endpoint
    url = (
        f"https://archive-api.open-meteo.com/v1/era5?"
        f"latitude={lat}&longitude={lon}&"
        f"start_date={start_date}&end_date={end_date}&"
        f"hourly=temperature_2m&timezone=UTC"
    )
    
    # Send GET request
    response = requests.get(url)
    
    # If the request is successful
    if response.status_code == 200:
        json_data = response.json()

        # Extract time and temperature data
        times = json_data['hourly']['time']
        temperatures = json_data['hourly']['temperature_2m']

        # Create DataFrame for this city
        df_city = pd.DataFrame({
            "city": city,
            "datetime": times,
            "temperature_2m": temperatures,
        })

        return df_city
    else:
        print(f"Failed to fetch data for {city}. Status code: {response.status_code}")
        return None
    

######################
def get_temperature(row):

    city = row['city']
    lat = row['lat']
    lon = row['lng']
    start_date = row['start_date']
    end_date = row['end_date']
    
    # Fetch weather data for this city
    df_city = fetch_weather_data(city, lat, lon, start_date, end_date)

    # Extract the date and time from the datetime column
    df_city['datetime'] = pd.to_datetime(df_city['datetime'])
    df_city['date'] = df_city['datetime'].dt.date
    df_city['hour'] = df_city['datetime'].dt.hour

    # Filter data to include only times between 8 am and 5 pm
    df_city = df_city[(df_city['hour'] >= 8) & (df_city['hour'] <= 17)]

    # Group by the date and calculate the average temperature
    average_temps = df_city.groupby('date')['temperature_2m'].mean().reset_index()
    average_temps = average_temps['temperature_2m'].mean()

    return average_temps



######################
def plot_folium(df):

    if not df.empty:
        lat = df.iloc[0]['lat']  # Take the latitude of the first city in the filtered data
        lng = df.iloc[0]['lng']  # Take the longitude of the first city in the filtered data
    else:
        lat, lng = 20, 0  # Default to some global center if no data found for the year


    # Create a Folium map centered at a global location
    world_map = folium.Map(location=[lat, lng], zoom_start=4)

    # Add markers for the filtered cities
    marker_group = folium.FeatureGroup(name="Markers")
    for _, row in df.iterrows():
        folium.Marker(
            location=[row['lat'], row['lng']],
            popup=f"City: {row['city']}<br>Year: {row['year']}",
            icon=folium.Icon(color="blue", icon="info-sign"),
            tooltip=f"City: {row['city']}"  # Show information on hover
        ).add_to(marker_group)

    # Add marker group to the map
    marker_group.add_to(world_map)

    # Save the map as an HTML file
    world_map.save("map.html")
    # st_folium(world_map, width=800, height=600)

    # Display the map in Streamlit using components
    st.markdown("### Interactive Map")
    components.html(open("map.html", "r").read(), height=600)



