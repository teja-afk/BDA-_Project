WhatsApp Chat Sentiment Analysis in R
An R script for comprehensive analysis of WhatsApp chat exports. This project extracts valuable insights from your chat history, performing sentiment analysis, visualizing communication patterns, identifying key contributors, and much more.

Description
This project takes a standard WhatsApp chat .txt export file and transforms it into a rich dataset for analysis. It uses a robust regular expression to parse messages, timestamps, and authors, even handling different timestamp formats (e.g., 12-hour AM/PM). The script then leverages several powerful R libraries to generate a variety of analytical outputs and visualizations, providing a deep dive into the dynamics and emotional tone of the conversation.

Features
Sentiment Analysis: Uses the NRC Word-Emotion Association Lexicon to categorize messages into 8 emotions (anger, anticipation, disgust, fear, joy, sadness, surprise, trust) and 2 sentiments (positive, negative).

Data Visualization: Generates a suite of plots to visualize the findings:

Bar charts for overall sentiment distribution.

Pie charts for sentiment proportions.

Line charts showing daily message activity.

Heatmaps displaying message frequency by weekday and hour.

Bar plots of the most active users.

Word Cloud: Creates a word cloud of the most frequently used words in the chat.

Trend Analysis: Tracks and plots the trends of positive and negative sentiment over time.

Data Export: Saves the summarized sentiment data to a Sentiment_Output.csv file.

Technologies Used
R: The primary language for the analysis.

R Libraries:

syuzhet: For sentiment analysis using the NRC lexicon.

ggplot2: For creating high-quality, aesthetic plots.

dplyr: For efficient data manipulation and transformation.

stringr: For robust string and regular expression operations.

tm: For text mining tasks and corpus creation.

wordcloud: For generating word clouds.

lubridate: For easy and powerful date-time parsing.

pheatmap: For generating the activity heatmap.

Getting Started
Follow these steps to get the analysis running on your own WhatsApp chat data.

Prerequisites
R installed on your system.

RStudio is highly recommended for a better user experience.

1. Export Your WhatsApp Chat
First, you need to get the .txt file from WhatsApp.

Open the individual or group chat you want to analyze.

Tap the three dots (⋮) in the top-right corner.

Select More > Export chat.

Choose Without Media.

Save or send the .txt file to the computer where you have R installed.

2. Installation & Setup
Clone this repository or download the R script to your project folder.

Open the R script in RStudio.

Install the required packages by running the following command in the R console:

R

install.packages(c("syuzhet", "ggplot2", "tm", "wordcloud", "RColorBrewer", "lubridate", "dplyr", "pheatmap", "stringr"))
In the script, update the working directory to your project folder's path:

R

# Change this path to your project folder
setwd("C:/path/to/your/project/folder")
3. Usage
Run the entire script in RStudio (you can use the "Source" button or Ctrl+Shift+Enter).

A file selection window will pop up. Navigate to and select the WhatsApp chat .txt file you exported.

The script will process the data and generate the analyses.

Plots will appear in the "Plots" pane in RStudio.

The summarized sentiment data will be saved as Sentiment_Output.csv in your working directory.

Troubleshooting
"0 Messages Processed" or "Subscript out of bounds" Error
This is the most common issue and it occurs when the script fails to parse any messages.

Cause: The regular expression pattern in Step 4 of the script does not match the timestamp format in your specific WhatsApp .txt file. WhatsApp's export format can vary based on your phone's OS, language, and region settings (e.g., 12-hour vs. 24-hour clock, dd/mm/yy vs. mm/dd/yy).

Solution:

Open your .txt file and examine the first few lines to see the exact timestamp format.

In the R script, go to the "Define the Correct Regex Pattern" section.

Several common patterns are provided in comments. Uncomment the pattern that matches your file format and comment out the others.

If none of the provided patterns work, you may need to create a custom one based on your file's format.

Sample Outputs
Here are some examples of the visualizations this script can generate:

Sentiment Distribution Bar Chart

Daily Message Activity

Word Cloud

Activity Heatmap (Weekday vs. Hour)

Author
Teja Poosa

License
This project is licensed under the MIT License - see the LICENSE.md file for details.
