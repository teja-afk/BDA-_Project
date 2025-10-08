# WhatsApp Chat Sentiment Analysis

![WhatsApp Logo](https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg)

## Project Overview

This project performs **comprehensive sentiment analysis and activity visualization** on exported WhatsApp chat data. Using **R** and several data science libraries, it extracts insights such as:

- Overall sentiment distribution (anger, joy, sadness, positive, negative, etc.)  
- Daily message trends  
- Active user analysis  
- Hourly and weekday activity heatmaps  
- Word clouds of frequently used words  
- Daily sentiment trends (positive vs negative)  

It is designed for **researchers, data enthusiasts, and students** who want to explore communication patterns and emotions in WhatsApp chats.

---

## Features

1. **Data Cleaning & Preprocessing**  
   - Handles 12-hour (AM/PM) and 24-hour formats  
   - Removes media messages (`image omitted`, `video omitted`, etc.)  
   - Parses timestamps and usernames correctly  

2. **Sentiment Analysis**  
   - Uses NRC Lexicon (`syuzhet`) to compute 10 sentiment categories  
   - Generates overall sentiment counts and comparisons (positive vs negative)  

3. **Visualizations**  
   - Bar charts for sentiment distribution  
   - Word cloud for frequently used words  
   - Daily message trends over time  
   - Activity heatmap: weekdays vs hours  
   - Top active users  
   - Daily sentiment trend line chart  

4. **Emoji Analysis (Optional Extension)**  
   - Counts and visualizes top emojis used in chats  

5. **Exportable Results**  
   - Saves sentiment summary as CSV for further analysis  

---

## Installation & Setup

1. Install **R** (version ≥ 4.0 recommended)  
2. Install required packages (if not already installed):

```r
install.packages(c(
  "syuzhet", "ggplot2", "tm", "wordcloud", "RColorBrewer",
  "lubridate", "dplyr", "pheatmap", "stringr"
))
Set your working directory to the project folder:

r
Copy code
setwd("C:/path/to/your/project")
Run the R script WhatsApp_Sentiment_Analysis.R

Choose your exported WhatsApp .txt file when prompted.

How to Use
Export your WhatsApp chat

On Android/iOS: Open chat → More → Export Chat → Without Media (recommended)

Run the script in RStudio.

Wait for analysis to complete:

Sentiment summary will print in console

Visualizations will appear in RStudio plots panel

Sentiment_Output.csv will be saved in your working directory

Sample Output
Sentiment Bar Chart

Word Cloud

Daily Activity Line Chart

Weekday-Hour Heatmap

Top Active Users

Daily Sentiment Trend

Technologies Used
R – main programming language

Libraries: syuzhet, ggplot2, tm, wordcloud, lubridate, dplyr, pheatmap, stringr

Contributing
Contributions are welcome! You can:

Add support for iOS and Android chat formats

Include emoji sentiment analysis

Optimize visualization aesthetics

Add interactive dashboards using Shiny or Plotly

License
This project is licensed under the MIT License – see the LICENSE file for details.

Author
Teja Poosa
Computer Science Student | Big Data Analytics Enthusiast
GitHub Profile

Acknowledgements
NRC Emotion Lexicon

R syuzhet Package Documentation

ggplot2 Documentation

yaml
Copy code

---

If you want, I can also create a **shorter “project description” snippet** for GitHub homepage that looks **modern and professional** with **badges and screenshots**, so your repo looks more appealing to recruiters and visitors.  

Do you want me to do that too?
