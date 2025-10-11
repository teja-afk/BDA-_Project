# 💬 WhatsApp Chat Sentiment Analyzer (v4)

<p align="left">
  <img src="https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg" alt="WhatsApp Logo" width="60"/>
</p>

> **Version 4.0** – Faster, Interactive, and Insightful  
> Built with **R Shiny** for real-time sentiment visualization and chat insights.

---

## 📘 Project Overview

The **WhatsApp Chat Sentiment Analyzer (v4)** is an advanced R Shiny web application that performs **comprehensive sentiment analysis and activity visualization** on exported WhatsApp chat data.

It combines **data cleaning, NLP-based sentiment extraction**, and **rich visualizations** to provide an interactive analytical dashboard.  
This version introduces **faster processing**, a **textual summary panel**, **user filtering**, and an **improved UI** with progress indicators.

---

## 🚀 Key Features

### 🧹 1. Smart Data Cleaning & Preprocessing
- Handles both **12-hour (AM/PM)** and **24-hour** chat formats.
- Removes media placeholders (`<Media omitted>`, `image omitted`, etc.).
- Parses timestamps and usernames accurately.
- Filters deleted messages automatically.

### 🧠 2. Sentiment Analysis (NRC Lexicon)
- Uses **NRC Emotion Lexicon** via the `syuzhet` package.
- Detects 10 emotions including:  
  `anger`, `anticipation`, `disgust`, `fear`, `joy`, `sadness`, `surprise`, `trust`, `positive`, and `negative`.
- Calculates **positive vs negative ratios** for chat tone summary.

### 📊 3. Interactive Visualizations
- **Sentiment Bar Chart:** Overall emotion distribution.  
- **Positive vs Negative Comparison:** Quick mood snapshot.  
- **Word Cloud:** Most frequent and meaningful words.  
- **Daily Activity Line Chart:** Message frequency trends.  
- **Heatmap (Weekday × Hour):** Peak activity times.  
- **Top Active Users Chart:** Identifies most engaged participants.  
- **Daily Sentiment Trend Line:** Tracks emotional flow over time.

### 🧾 4. Textual Summary Dashboard
A new **“Chat Summary”** tab displays:
- Total messages and participants  
- Media messages omitted  
- Chat duration (start to end)  
- Most active user and busiest day  
- Overall positive vs negative sentiment ratio

### ⚡ 5. Optimized Performance
- Uses `withProgress()` for live progress updates.
- Faster word frequency analysis using `tidytext`.
- Efficient filtering by selected users.

---

## 🧩 Technologies Used

| Component | Purpose |
|------------|----------|
| **R Shiny** | Interactive web UI |
| **bslib (Cerulean theme)** | Modern responsive theme |
| **syuzhet** | NRC-based sentiment analysis |
| **ggplot2** | Charts and data visualizations |
| **tidytext** | Word frequency analysis |
| **wordcloud & RColorBrewer** | Word cloud generation |
| **lubridate & stringr** | Date-time and text parsing |
| **dplyr** | Data manipulation |
| **pheatmap** | Activity heatmap generation |

---

## 🧭 How to Use

### 📥 1. Export Your WhatsApp Chat  
To analyze a chat, you need to **export it from WhatsApp without media**:  

- **On Android:**  
  1. Open the chat (individual or group).  
  2. Tap the **three dots → More → Export chat**.  
  3. Select **Without Media**.  
  4. Save or send the `.txt` file to your computer.  

- **On iPhone:**  
  1. Open the chat → Tap on **Contact name / Group info**.  
  2. Tap **Export Chat**.  
  3. Choose **Without Media**.  
  4. Save the `.txt` file via Mail or Files app.

📄 **Example file name:**  

GroupName.txt

---

### 🧩 2. Launch the Application  

Open the R project or run the Shiny app directly:

```
library(shiny)
runApp("path_to_project_folder")
```

OR if your main app file is named app.R, run:

```
shiny::runApp("app.R")
```

This will start a local Shiny server and open the dashboard in your browser.

---

### 📊 3. Upload the Chat File

Once the dashboard loads:

Click the “Browse” / “Upload Chat File” button.

Select your exported .txt WhatsApp chat file.

Wait a few seconds — progress indicators will show while your data is processed.

✅ The analyzer will automatically:

Parse timestamps, usernames, and message content

Remove deleted and media messages

Detect chat language and sentiment

Display interactive visualizations

---

### 📈 4. Explore the Dashboard

You can navigate through multiple interactive tabs:

Tab	Description
Overview	Quick summary of messages, participants, and sentiment ratio
Sentiment Analysis	Bar and line charts of emotional distribution
Word Cloud	Visualization of most used words
Activity Trends	Hourly, daily, and weekly activity patterns
Chat Summary	Textual insights with key highlights

---

### 💡 5. Tips

Works best with English chats.

Avoid exporting very large chats (>50,000 messages) for faster performance.

For group chats, use the user filter to analyze messages per participant.

---

🧑‍💻 Author

👤 Teja Poosa
📍 Third-Year Computer Science Student


🏁 License

This project is licensed under the MIT License – feel free to use and modify it with proper credit.


---
